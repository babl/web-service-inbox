#!/usr/bin/node

var Babl = require('node-babl');
var http = require('http');
var path = require('path');
var port = process.env.PORT || 3000;

function requestListener(req, res) {
  var matches = (req.url.match(/^\/([^\/]+)(?:\/([^\/]*))?$/) || []).slice(-2);
  var owner = matches[0];
  var module = matches[1];
  var body = [];

  req
    .on('data', body.push.bind(body))
    .on('end', function() {
      if (owner) {
        Babl.module('babl/trigger', {
          stdin: Buffer.concat(body),
          env: {
            EVENT: 'babl:inbox',
            USER: owner,
            MODULE: module,
            CONTENT_TYPE: req.headers['content-type'],
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
        res.end();
      }
    });
}

http
  .createServer(requestListener)
  .listen(port);
