function stripTrailingSlash(str) {
    var _str = String(str || "");
    if(_str.substr(-1) === '/') {
        return _str.substr(0, _str.length - 1);
    }
    return _str;
}

const providers = function (fhirServiceUrl, provider, callback, errback) {
  // Skip conformance statement introspection when overriding provider setting are available
  if (provider) {
    console.log('skipping')
    provider['url'] = fhirServiceUrl;
    process.nextTick(function(){
      callback && callback(provider);
    });
    return;
  }

  this.adapter.get(stripTrailingSlash(fhirServiceUrl) + "/metadata").then((response) => {
    var res = {
      "name": "SMART on FHIR Testing Server",
      "description": "Dev server for SMART on FHIR",
      "url": fhirServiceUrl,
      "oauth2": {
        "registration_uri": null,
        "authorize_uri": null,
        "token_uri": null
      }
    };

    try {
      var smartExtension = response.data.rest[0].security.extension.filter(function (e) {
         return (e.url === "http://fhir-registry.smarthealthit.org/StructureDefinition/oauth-uris");
      });

      smartExtension[0].extension.forEach(function(arg, index, array){
        if (arg.url === "register") {
          res.oauth2.registration_uri = arg.valueUri;
        } else if (arg.url === "authorize") {
          res.oauth2.authorize_uri = arg.valueUri;
        } else if (arg.url === "token") {
          res.oauth2.token_uri = arg.valueUri;
        }
      });
    }
    catch (err) {
      return errback && errback(err);
    }

    callback && callback(res);
  }, function() {
      errback && errback("Unable to fetch conformance statement");
  });
}


module.exports = providers
