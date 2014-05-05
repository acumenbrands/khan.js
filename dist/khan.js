(function() {
  var Khan,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Khan = {
    Deferred: jQuery.Deferred
  };

  if (typeof module !== "undefined" && module !== null) {
    module.exports = Khan;
  }

  if (typeof window !== "undefined" && window !== null) {
    window.Khan = Khan;
  }

  Khan.Controller = (function() {
    function Controller() {
      var duration, properties, tweens;
      duration = arguments[0], tweens = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      this.duration = duration;
      properties = _.map(tweens, function(t) {
        return t.property;
      });
      this.tweens = _.object(properties, tweens);
    }

    Controller.requestAnimationFrame = window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.msRequestAnimationFrame || window.oRequestAnimationFrame || function(callback) {
      return setTimeout(callback, 10);
    };

    Controller.prototype.update = function(options) {
      var key, value, _ref, _results;
      _results = [];
      for (key in options) {
        value = options[key];
        _results.push((_ref = this.tweens[key]) != null ? _ref.end = value : void 0);
      }
      return _results;
    };

    Controller.prototype.halt = function() {
      delete this._deferred;
      return delete this._ticks;
    };

    Controller.prototype.reset = function() {
      return delete this._ticks;
    };

    Controller.prototype.stop = function() {
      return this.deferred().resolve();
    };

    Controller.prototype.promise = function() {
      return this.deferred().promise();
    };

    Controller.prototype.animate = function() {
      var results;
      results = this.tick_all();
      if (_.keys(results).length > 0) {
        this.deferred().notify(results);
        Khan.Controller.requestAnimationFrame.call(window, this.animate.bind(this));
      } else {
        results = this.tock_all();
        this.deferred().notify(results);
        this.deferred().resolve(results);
      }
      return this;
    };


    /* INTERNAL */

    Controller.prototype.deferred = function() {
      return this._deferred || (this._deferred = new Khan.Deferred());
    };

    Controller.prototype.tick_all = function() {
      return this._build(this.ticks(), function(tick) {
        return tick.tick();
      });
    };

    Controller.prototype.tock_all = function() {
      return this._build(this.ticks(), function(tick) {
        return tick.tock();
      });
    };

    Controller.prototype._build = function(obj, callback) {
      var prop, reduced, val, value;
      reduced = {};
      for (prop in obj) {
        value = obj[prop];
        val = callback(value);
        if (val !== null) {
          reduced[prop] = val;
        }
      }
      return reduced;
    };

    Controller.prototype.ticks = function() {
      var a, prop, _ref;
      if (this._ticks) {
        return this._ticks;
      }
      this._ticks = {};
      _ref = this.tweens;
      for (prop in _ref) {
        a = _ref[prop];
        this._ticks[prop] = a.tween(this.duration);
      }
      return this._ticks;
    };

    return Controller;

  })();

  Khan.Ease = (function() {
    function Ease() {}

    Ease.linear = function(t, b, c, d) {
      return (c * (t / d)) + b;
    };

    Ease.circinout = function(t, b, c, d) {
      t /= d / 2;
      if (t < 1) {
        return -c / 2 * (Math.sqrt(1 - t * t) - 1) + b;
      }
      t -= 2;
      return c / 2 * (Math.sqrt(1 - t * t) + 1) + b;
    };

    Ease.quintout = function(t, b, c, d) {
      t /= d;
      t--;
      return c * (t * t * t * t * t + 1) + b;
    };

    return Ease;

  })();

  Khan.Tween = (function() {
    function Tween(property, start, end, ease, options) {
      if (ease == null) {
        ease = 'linear';
      }
      if (options == null) {
        options = {};
      }
      this.ease = Khan.Ease[ease];
      this.properties['property'] = property;
      this.properties['start'] = start;
      this.properties['end'] = end;
      this.defineProperties(options);
    }

    Tween.prototype.properties = {};

    Tween.prototype.defineProperties = function(options) {
      var prop, value, _ref, _results;
      _ref = this.properties;
      _results = [];
      for (prop in _ref) {
        value = _ref[prop];
        options.value = value;
        _results.push(Object.defineProperty(this, prop, this.defaultValues(options)));
      }
      return _results;
    };

    Tween.prototype.defaultValues = function(options) {
      var defaults;
      if (options == null) {
        options = {};
      }
      defaults = {
        configurable: true,
        writable: true,
        enumerable: true
      };
      if (options['updatable'] === false) {
        _.extend(defaults, {
          writable: false,
          configurable: false
        });
      }
      return _.extend(defaults, options);
    };

    Tween.prototype.tween = function(duration) {
      return Khan.Utilities.tick(duration, (function(_this) {
        return function(i) {
          return _this.ease(i, _this.start, _this.end - _this.start, duration);
        };
      })(this));
    };

    return Tween;

  })();

  Khan.Frames = (function(_super) {
    __extends(Frames, _super);

    function Frames(property, start, end, ease) {
      this.property = property;
      this.start = start;
      this.end = end;
      if (ease == null) {
        ease = 'linear';
      }
      Frames.__super__.constructor.call(this, this.property, this.start, this.end, ease);
      if (this.start === this.end) {
        this.steps = 1;
      } else {
        this.steps = Math.abs(this.start - this.end);
      }
    }

    Frames.prototype.tween = function(duration) {
      return Khan.Utilities.stretch(this.steps, duration, (function(_this) {
        return function(i) {
          return Math.round(_this.ease(i, _this.start, _this.end - _this.start, _this.steps));
        };
      })(this));
    };

    return Frames;

  })(Khan.Tween);

  Khan.Range = (function(_super) {
    __extends(Range, _super);

    function Range(property, start, end, steps) {
      this.property = property;
      this.start = start;
      this.end = end;
      this.steps = steps;
      Range.__super__.constructor.call(this, this.property, this.start, this.end);
      this.diff = Math.abs(this.start - this.end) + 1;
      this.direction = 1;
      if (this.steps == null) {
        if (this.start === this.end) {
          this.steps = 1;
        } else {
          this.steps = this.diff;
        }
      }
      if (this.start > this.end) {
        this.direction = -1;
      } else if (this.start === this.end) {
        this.direction = 0;
      }
    }

    Range.prototype.tween = function() {
      return Khan.Utilities.step(this.steps, (function(_this) {
        return function(i) {
          if (_this.steps > _this.diff) {
            i = i * _this.diff / _this.steps;
          }
          if (_this.steps === 1) {
            return _this.end;
          }
          return Math.round(_this.start + i * _this.direction);
        };
      })(this));
    };

    return Range;

  })(Khan.Tween);

  Khan.Loop = (function() {
    function Loop(property, steps, bounce) {
      this.property = property;
      this.steps = steps;
      this.bounce = bounce != null ? bounce : false;
    }

    Loop.prototype.tween = function() {
      return Khan.Utilities.loop(this.steps, this.bounce, (function(_this) {
        return function(i) {
          return i;
        };
      })(this));
    };

    return Loop;

  })();

  Khan.Utilities = (function() {
    var getTime;

    function Utilities() {}

    getTime = function() {
      return new Date().getTime();
    };

    Utilities.tick = function(duration, callback) {
      return (function() {
        var start_time;
        start_time = getTime();
        return {
          tock: function() {
            return callback(duration);
          },
          tick: function() {
            var elapsed;
            elapsed = getTime() - start_time;
            if (elapsed > duration) {
              return null;
            }
            return callback(elapsed);
          }
        };
      })();
    };

    Utilities.step = function(steps, callback) {
      return (function() {
        var step;
        step = 0;
        return {
          tock: function() {
            return callback(steps);
          },
          tick: function() {
            step += 1;
            if (step > steps) {
              return null;
            }
            return callback(step);
          }
        };
      })();
    };

    Utilities.stretch = function(steps, duration, callback) {
      return (function() {
        var freq, start_time, step;
        start_time = getTime();
        freq = duration / (steps + 1);
        step = 0;
        return {
          tock: function() {
            return callback(steps, duration);
          },
          tick: function() {
            var elapsed;
            elapsed = getTime() - start_time;
            step = Math.floor(elapsed / freq);
            if (step > steps) {
              return null;
            }
            return callback(step, elapsed);
          }
        };
      })();
    };

    Utilities.loop = function(steps, bounce, callback) {
      return (function() {
        var direction, next, prev, step;
        if (typeof bounce === 'function') {
          callback = bounce;
          bounce = false;
        }
        step = 0;
        next = function(n) {
          return n += 1;
        };
        prev = function(n) {
          return n -= 1;
        };
        direction = next;
        return {
          tock: function() {
            return callback(steps);
          },
          tick: function() {
            if (direction === next && step >= steps) {
              if (bounce) {
                direction = prev;
              } else {
                step = 0;
              }
            }
            if (direction === prev && step <= 1) {
              direction = next;
            }
            step = direction(step);
            return callback(step);
          }
        };
      })();
    };

    return Utilities;

  })();

}).call(this);

//# sourceMappingURL=maps/khan.js.map
