const getAwsIdentity = require('./prism-aws/get-aws-identity');
const savePatient = require('./prism-aws/save-patient');
const createQuestionnaire = require('./prism-aws/create-questionnaire');
const getIdentityId = require('./prism-aws/get-identity-id');
const getDynamoPatient = require('./prism-aws/get-dynamo-patient');

module.exports = {
  getAwsIdentity: getAwsIdentity,
  savePatient: savePatient,
  createQuestionnaire: createQuestionnaire,
  getIdentityId: getIdentityId,
  getDynamoPatient,
};
