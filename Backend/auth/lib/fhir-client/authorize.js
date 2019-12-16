var Guid = require('./guid');
var jwt = require('jsonwebtoken');

// Params: {
//   client: {
//     redirect_uri: 'foo.bar.com',
//     scope: 'openid profile',
//     launch: null,
//   }
//   server: 'fhir.server.com',
//   response_type: 'code',
//   patientId: 'abc_123'
// }

const authorize =  function(params, errback, cb) {
  if (!errback){
    errback = function(){
        console.log("Failed to discover authorization URL given", params);
    };
  }

  // prevent inheritance of tokenResponse from parent window
  // delete sessionStorage.tokenResponse;

  if (!params.client) { params = { client: params }; }
  if (!params.response_type) { params.response_type = 'code'; }

  if (!params.client.redirect_uri) { throw 'must have redirect_uri' }

  // if (!params.client.redirect_uri.match(/:\/\//)){
  //   params.client.redirect_uri = relative(params.client.redirect_uri);
  // }

  if (params.client.launch) {
    if (!params.client.scope.match(/launch/)) { params.client.scope += " launch"; }
  }

  if (!params.server) {
    console.warn(
      'No server provided. For EHR launch, the EHR should provide that as "iss" ' +
      'parameter. For standalone launch you should pass a ""server" option ' +
      'to the authorize function. Alternatively, you can also pass ' +
      '"fhirServiceUrl" parameter to your launch url.'
    );
    return errback();
  }

  if (params.patientId) {
    params.fake_token_response = params.fake_token_response || {};
    params.fake_token_response.patient = params.patientId;
  }

  // If we already have the token_uri for this provider. Do not go fetch it again
  if (params.provider.authorize_uri) {
    var state = params.client.state || Guid.newGuid();
    var client = params.client;

    var redirect_to=params.provider.authorize_uri + "?" +
      "client_id="+encodeURIComponent(client.client_id)+"&"+
      "response_type="+encodeURIComponent(params.response_type)+"&"+
      "scope="+encodeURIComponent(client.scope)+"&"+
      "redirect_uri="+encodeURIComponent(client.redirect_uri)+"&"+
      "state="+encodeURIComponent(state)+"&"+
      "aud="+encodeURIComponent(params.server);

    console.log('redirect_to, ', redirect_to)

    if (typeof client.launch !== 'undefined' && client.launch) {
      redirect_to += "&launch="+encodeURIComponent(client.launch);
    }

    cb(redirect_to);
  } else {
    this.providers(params.server, params.provider, (provider) => {
      params.provider = provider;

      var state = params.client.state || Guid.newGuid();
      var client = params.client;

      // if (params.provider.oauth2 == null) {

      //   // Adding state to tokenResponse object
      //   if (BBClient.settings.fullSessionStorageSupport) {
      //     sessionStorage[state] = JSON.stringify(params);
      //     sessionStorage.tokenResponse = JSON.stringify({state: state});
      //   } else {
      //     var combinedObject = $.extend(true, params, { 'tokenResponse' : {state: state} });
      //     sessionStorage[state] = JSON.stringify(combinedObject);
      //   }

      //   // window.location.href = client.redirect_uri + "?state="+encodeURIComponent(state);
      //   throw 'up';
      //   return;
      // }

      // sessionStorage[state] = JSON.stringify(params);

      this.config.auth_uri = params.provider.oauth2.authorize_uri;
      this.config.token_uri = params.provider.oauth2.token_uri;

      var redirect_to=params.provider.oauth2.authorize_uri + "?" +
        "client_id="+encodeURIComponent(client.client_id)+"&"+
        "response_type="+encodeURIComponent(params.response_type)+"&"+
        "scope="+encodeURIComponent(client.scope)+"&"+
        "redirect_uri="+encodeURIComponent(client.redirect_uri)+"&"+
        "state="+encodeURIComponent(state)+"&"+
        "aud="+encodeURIComponent(params.server);

      if (typeof client.launch !== 'undefined' && client.launch) {
         redirect_to += "&launch="+encodeURIComponent(client.launch);
      }

      cb(redirect_to);
    }, errback);
  }
}

module.exports = authorize;
