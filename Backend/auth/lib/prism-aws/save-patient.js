const AWS = require('aws-sdk');
const documentClient = new AWS.DynamoDB.DocumentClient();
const { ENV } = require('../../config/environment');

module.exports = function(userId, patientData, fhirAccessData){
  const updateParams = {
    Item: {
      resourceType: 'Patient',
      primaryKey: userId,
      sortKey: 'patient',
      GSI_1_SK: 'patient',
      patientId: patientData['id'],
      meta: patientData['meta'],
      extension: patientData['extension'],
      identifier: patientData['identifier'],
      name: patientData['name'],
      telecom: patientData['telecom'],
      gender: patientData['gender'],
      birthDate: patientData['birthDate'],
      address: patientData['address'],
      maritalStatus: patientData['maritalStatus'],
      contact: patientData['contact'],
      communication : patientData['communication'],
      _fhir_access_data: {
        access_token: fhirAccessData.access_token,
        refresh_token: fhirAccessData.refresh_token,
        id_token: fhirAccessData.id_token,
        expires_in: fhirAccessData.expires_in,
        created_at: Date.now()
      }
    },
    TableName: ENV.dynamoDbTableName
  }

  return new Promise((resolve,reject) => {
    documentClient.put(updateParams, (err, data) => {
      if (err) { reject(err) }
      else { resolve(data) }
    })
  })
}
