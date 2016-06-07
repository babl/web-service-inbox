#!/usr/bin/node

var Babl = require('node-babl');
var http = require('http');
var path = require('path');
var url = require('url');
var port = process.env.PORT || 3000;
var triggerRgx = /^\/([^\/]+)(?:\/([^\/]*))?$/;

function respond(statusCode, res, body) {
  res.statusCode = statusCode;
  res.end(body || null);
}

function isGet(req) {
  return /^get$/ig.test(req.method);
}

function isPost(req) {
  return /^(post|put|patch)$/ig.test(req.method);
}

function isRootPath(pathname) {
  return pathname === '/';
}

function isTriggerPath(pathname) {
  return triggerRgx.test(pathname);
}

function trigger(pathname, req, res) {
  var matches = (req.url.match(triggerRgx) || []).slice(-2);
  var owner = matches[0];
  var label = matches[1];
  var body = [];

  req
    .on('data', body.push.bind(body))
    .on('end', function() {
      Babl.module('babl/trigger', {
        stdin: Buffer.concat(body),
        env: {
          EVENT: 'babl:inbox',
          USER: owner,
          LABEL: label,
          CONTENT_TYPE: req.headers['content-type'],
        }
      }).then(function() {
        respond(204, res);
      }).catch(function() {
        respond(500, res);
      });
    });
}

function requestListener(req, res) {
  var pathname = url.parse(req.url).pathname;

  if (isGet(req) && isRootPath(pathname)) {
    return respond(200, res, 'Index');
  }

  if (isPost(req) && isTriggerPath(pathname)) {
    return trigger(pathname, req, res);
  }

  respond(404, res);
}

http
  .createServer(requestListener)
  .listen(port);
