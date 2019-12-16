const axios = require('axios');

var adapter;
var Adapter = module.exports =  {debug: true}

function stripTrailingSlash(str) {
    var _str = String(str || "");
    if(_str.substr(-1) === '/') {
        return _str.substr(0, _str.length - 1);
    }
    return _str;
}


Adapter.get = function (url) {
  return axios.get(url);
};
