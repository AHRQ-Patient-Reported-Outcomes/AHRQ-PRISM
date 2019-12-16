'use strict'

const express = require('express');
const FHIR = require('./lib/fhir');
const prismAws = require('./lib/prism-aws');
const cors = require('cors');
const bodyParser = require('body-parser');

const { ENV } = require('./config/environment');

const app = express()

// Use cors
app.use(cors())
app.use(bodyParser.json()); // support json encoded bodies

app.get('/l', (req, res) => {
  console.log('Starting /l')
  res.writeHead(302, { 'Location': 'prismScoreAppPerk://' })
  res.end();
})

// Start authenticating
app.get('/launch', (req, res) => {
  console.log('Starting /launch')
  const data = ENV.oauthInfo;

  console.log('data: ', data)

  FHIR.authorize(data, null, function(uri) {
    res.writeHead(302, { 'Location': uri });

    res.end();
  });
})

app.post('/refresh', async (req, res) => {
  console.log('Starting /refresh')
  try {
    // The cognito identity pool id is burried in the request object.
    // This helper extracts it
    const cognitoIdentityId = prismAws.getIdentityId(req);
    console.log('cognito:', cognitoIdentityId);
    // At this point, you can use the cognitoIdentityId to lookup a patient
    // 1) Lookup Patient in dynamoDb where primaryKey = cognitoIdentityId
    //    and sortKey = 'patient'
    const patient = await prismAws.getDynamoPatient(cognitoIdentityId);
    console.log('Patient:', patient);
    // 2) Get the _fhir_access_data from the patient record
    if (patient._fhir_access_data) {
      // 3) make refresh token request
      const refreshResponse = await FHIR.getRefreshToken(
        patient._fhir_access_data.access_token,
        patient._fhir_access_data.refresh_token
      );
      console.log('Refresh data', refreshResponse);
      // 4) replace _fhir_access_data with response
      await prismAws.savePatient(cognitoIdentityId, patient, refreshResponse);

      // 5) return { id_token, expires_in } to client
      return res.status(200).send({
        success: true,
        awsIdentityId: cognitoIdentityId,
        fhirExpiresIn: refreshResponse.expires_in,
        fhirIdToken: refreshResponse.id_token,
      });
    }
    return res.status(400).send({ success: false, error: 'No access data' });
  } catch(err) {
    if (err.response && err.response.status === 400) {
      return res.status(400).send(err.response.data);
    } else {
      console.log(err)
      return res.status(500).send({error: 'Something went wrong'});
    }
  }
});

// This endpoint takes the code and state from the frontend, and safely and securly
// gets the access_token along with the refresh token.
app.post('/token', async (req, res) => {
  console.log('Starting /token')
  try {
    const { code, state } = req.body;

    // Get the FHIR access token from the code
    const fhirAccessData = await FHIR.getAccessToken(code, ENV.oauthInfo.client.client_id);

    // Use the fhir access data to get aws credentials.
    const awsAccessData = await prismAws.getAwsIdentity(fhirAccessData);

    // Get the patient record from FHIR server
    const patient = await FHIR.getPatient(fhirAccessData);

    // save the FHIR access data to DB
    await prismAws.savePatient(awsAccessData.IdentityId, patient, fhirAccessData);

    // create a questionnaire if needed
    await prismAws.createQuestionnaire(awsAccessData.IdentityId, patient);

    return res.status(200).send({
      awsIdentityId: awsAccessData.IdentityId,
      fhirAccessToken: fhirAccessData.id_token,
      fhirExpiresIn: fhirAccessData.expires_in,
      patient: patient
    });
  } catch(err) {
    if (err.response && err.response.status === 400) {
      return res.status(400).send(err.response.data);
    } else {
      console.log('Error in token endpoint')
      console.log(err)
      return res.status(500).send({error: 'Something went wrong'});
    }
  }
})

// Pass the url encoded items back to frontend to allow a /token request.
app.get('/callback', (req, res) => {
  console.log('Starting /callback')
  res.writeHead(302, {
    'Location': ENV.webappUrl + req._parsedUrl.search + '#/auth'
  })
  res.end();
})


module.exports = app
