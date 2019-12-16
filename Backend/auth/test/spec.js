const assert = require('assert');
const sinon = require('sinon');
const proxyquire = require('proxyquire');
const { ENV } = require('../config/environment');

let awsUserId = 'abc_123';

let putFunction;

const awsStub = {
  DynamoDB: {
    DocumentClient: function DocumentClient() {
      this.query = function(params, cb) {
        if (params.ExpressionAttributeValues[':id'] === awsUserId) {
          cb(null, { Items: []})
        } else if (params.ExpressionAttributeValues[':id'] === ENV.currentQuestionnaireId) {
          cb(null, { Items: [{title: 'Physical Function'}]})
        }
      }

      this.put = putFunction;
    }
  },
  '@noCallThru': true
};

describe('Create Questionnaire', function() {
  it('works', function() {
    putFunction = function(params, cb) {
      console.log('hi there')
      assert.equal(params.TableName, 'PrismApiTable', 'correct table name')
      assert.equal(params.Item.resourceType, 'QuestionnaireResponse')
      assert.equal(params.Item.primaryKey, awsUserId)
      assert.equal(params.Item.GSI_1_PK, awsUserId)
      assert.equal(params.Item.GSI_1_SK, ENV.currentQuestionnaireId)

      assert.equal(params.Item.contained[0].title, 'Physical Function')
      assert.equal(params.Item.contained[0].id, ENV.currentQuestionnaireId)

      cb(null, [])
    }

    const createQuestionnaire = proxyquire(
      '../lib/prism-aws/create-questionnaire', {
        'aws-sdk': awsStub
      }
    )

    createQuestionnaire(awsUserId)
  })
})
