var EMPTY = '00000000-0000-0000-0000-000000000000';
var uuid = require('uuid');

var create = function () {
  return uuid.v4();
};

module.exports =  {
  newGuid: create,
  empty: EMPTY
};
