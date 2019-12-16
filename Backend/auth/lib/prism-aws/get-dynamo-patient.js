const AWS = require('aws-sdk');
const documentClient = new AWS.DynamoDB.DocumentClient();

const { ENV } = require('../../config/environment');

module.exports = function(userAwsId) {
  return new Promise(function(resolve, reject) {
    documentClient.query({
      TableName: ENV.dynamoDbTableName,
      KeyConditionExpression: 'primaryKey = :id AND sortKey = :sortValue',
      ExpressionAttributeValues: {
        ':id': userAwsId,
        ':sortValue': 'patient'
      }
    }, (err, data) => {
      if (err) reject(err);
      else resolve(data.Items[0]);
    });
  });
}
