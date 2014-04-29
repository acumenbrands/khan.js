global.jsdom = require("jsdom").jsdom
global.document = jsdom("<html><head></head><body><p>I'm the env</p></body></html>")
global.window = document.parentWindow
global.document = window.document
require '../bower_components/jquery/jquery.js'

global.jQuery = window.jQuery

global._ = require '../bower_components/lodash/dist/lodash.min.js'

global?.expect = require('chai').expect

global?.sinon = require('sinon')

require '../src/khan'

global.Khan = window.Khan

require '../src/khan/controller'
require '../src/khan/ease'
require '../src/khan/tween'
require '../src/khan/utilities'

global.wait = (time, done, callback)->
  wait = {}

  wait.timeout = setTimeout ->
    throw new Error('Timeout Error')
  , time

  wait.interval = setInterval ->
    if callback()
      wait.cancel_interval()
      done()
  , 1

  wait.cancel_interval = ->
    clearTimeout(wait.timeout)
    clearTimeout(wait.interval)
