#!/usr/local/bin/node
// #!/usr/bin/node

var Babl = require('node-babl');
var http = require('http');
var path = require('path');
var port = process.env.PORT || 3000;

function requestListener(req, res) {
  var matches = (req.url.match(/^\/([^\/]+)(?:\/([^\/]*))?$/) || []).slice(-2);
  var owner = matches[0];
  var module = matches[1];

  if (owner) {
    Babl.module('larskluge/babl-events-trigger', {
      env: {
        EVENT: 'babl:inbox',
        USER: owner,
        MODULE: module
      }
    }).then(function() {
      res.statusCode = 204;
      res.end();
    }).catch(function() {
      res.statusCode = 500;
      res.end();
    });
  } else {
    res.statusCode = 404;
    res.end('404');
  }
}

http
  .createServer(requestListener)
  .listen(port);
