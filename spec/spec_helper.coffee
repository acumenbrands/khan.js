global.jsdom = require("jsdom").jsdom
global.document = jsdom("<html><head></head><body><p>I'm the env</p></body></html>")
global.window = document.parentWindow
global.document = window.document
require '../bower_components/jquery/jquery.js'

global.jQuery = window.jQuery

global._ = require '../bower_components/lodash/dist/lodash.min.js'

require '../src/khan'

global.Khan = window.Khan

require '../src/khan/controller'
require '../src/khan/ease'
require '../src/khan/tween'
require '../src/khan/utilities'

jasmine.Matchers.prototype.toBeGreaterThanOrEqualTo = (expected) ->
  @actual >= expected

jasmine.Matchers.prototype.toBeGreaterThan = (expected) ->
  @actual > expected
