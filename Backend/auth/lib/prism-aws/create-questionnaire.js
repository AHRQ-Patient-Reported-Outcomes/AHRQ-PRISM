const AWS = require('aws-sdk');
const documentClient = new AWS.DynamoDB.DocumentClient();
const uuid = require('uuid');

const { ENV } = require('../../config/environment');

module.exports = function(userAwsId, patient) {
  var queryParams = {
    TableName: ENV.dynamoDbTableName,
    KeyConditionExpression: 'primaryKey = :id AND begins_with(sortKey, :sortValue)',
    ExpressionAttributeValues: {
      ':id': userAwsId,
      ':sortValue': 'quest'
    }
  };

  return new Promise((resolve, reject) => {
    documentClient.query(queryParams, function(err, data) {
      if (err) {
        reject(err);
        return;
      }

      if (Array.isArray(data.Items) && data.Items.length > 0) {
        // The QuestionnaireResponse already exists
        resolve();
      } else {
        resolve(createQuestionnaireResponse(userAwsId, patient));
      }
    });
  });
}

const createQuestionnaireResponse = function(userAwsId, patient) {
  // If the user's first_name ends with 2, then use alternative questionnaire
  const first_name = patient['name'][0]['given'][0]
  const num = parseInt(first_name[first_name.length - 1])
  const questId = num === 2 ? ENV.alternativeQuestionnaireId : ENV.currentQuestionnaireId

  return findQuestionnaire(questId).then((quest) => {
    const responseParams = {
      Item: {
        resourceType: 'QuestionnaireResponse',
        primaryKey: userAwsId,
        sortKey: `questResp-${uuid.v4()}`,
        GSI_1_PK: userAwsId,
        GSI_1_SK: questId, // the questionnaire guid
        item: [],
        contained: [
          {
            id: questId,
            resourceType: 'Questionnaire',
            item: [],
            title: quest.title,
            description: quest.description,
            subjectType: ["Patient"],
            meta: {
              "versionId": "1",
              "lastUpdated": "2014-11-14T10:03:25",
              "profile": [
                  "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-adapt"
              ]
            }
          }
        ],
        extension: [],
        result_modal_data: {},
        status: 'in-progress',
        stdError: 0,
        theta: 0,
        authored: null,
        subject: { reference: "Patient/" + patient['id'] },
        meta: {"profile": ["http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaireresponse-adapt"]},
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      },
      TableName: ENV.dynamoDbTableName
    };

    return new Promise((resolve, reject) => {
      documentClient.put(responseParams, (err, data) => {
        if (err) {
          reject(err);
        } else {
          resolve(data);
        }
      });
    });
  });
}

const findQuestionnaire = function(questId) {
  return new Promise(function(resolve, reject) {
    documentClient.query({
      TableName: ENV.dynamoDbTableName,
      KeyConditionExpression: 'primaryKey = :id AND sortKey = :sortValue',
      ExpressionAttributeValues: {
        ':id': questId,
        ':sortValue': 'questionnaire'
      }
    }, (err, data) => {
      if (err) reject(err);
      else resolve(data.Items[0]);
    });
  });
}
