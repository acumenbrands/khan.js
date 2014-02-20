Khan.Effects =
  FadeIn:
    class FadeIn extends Khan.Controller
      constructor: ->
        super(800, @opacity)

      opacity: new Khan.Tween 'opacity', 0, 1

  FadeOut:
    class FadeOut extends Khan.Controller
      constructor: ->
        super(800, @opacity)

      opacity: new Khan.Tween 'opacity', 1, 0

  Pan:
    class Pan extends Khan.Controller
      constructor: (event, @dimensions, @model) ->
        @dim = new ImageControl.Views.Dimensions(event, @dimensions)
        super(100, @topOffset(), @leftOffset())

      leftOffset: -> new Khan.Tween 'leftOffset', @model.leftOffset,  @dim.offsetLeft()
      topOffset:  -> new Khan.Tween 'topOffset',  @model.topOffset,   @dim.offsetTop()

  ZoomIn:
    class ZoomIn extends Khan.Controller
      constructor: (@dimensions, @model) ->
        super(500, @height(), @width(), @topOffset(), @leftOffset())

      height:     ->  new Khan.Tween 'height',     @dimensions.height,  @dimensions.zoomHeight, 'quintout'
      width:      ->  new Khan.Tween 'width',      @dimensions.width,   @dimensions.zoomWidth,  'quintout'
      leftOffset: ->  new Khan.Tween 'leftOffset', @model.leftOffset,   @dimensions.centerX
      topOffset:  ->  new Khan.Tween 'topOffset',  @model.topOffset,    @dimensions.centerY

  ZoomOut:
    class ZoomOut extends Khan.Controller
      constructor: (@dimensions, @model) ->
        super(250, @height(), @width(), @topOffset(), @leftOffset())

      height:     ->  new Khan.Tween 'height',     @model.height,      @dimensions.height,  'quintout', updatable: false
      width:      ->  new Khan.Tween 'width',      @model.width,       @dimensions.width,   'quintout', updatable: false
      leftOffset: ->  new Khan.Tween 'leftOffset', @model.leftOffset,  0, 'linear', updatable: false
      topOffset:  ->  new Khan.Tween 'topOffset',  @model.topOffset,   0, 'linear', updatable: false

  SpinTo:
    class SpinTo extends Khan.Controller
      constructor: (@model, @frame) ->
        super(500, @row(), @column())

      row:    ->  new Khan.Frames 'row',     @model.row,     @frame.row
      column: ->  new Khan.Frames 'column',  @model.column,  @frame.column

  View360:
    class View360 extends Khan.Controller
      constructor: ->
        super(10000, @column())

      column:    ->  new Khan.Frames 'column', 1, ImageControl.Settings.spinner.columns

  Rotation:
    class Rotation extends Khan.Controller
      constructor: ->
        super(-1, @rotation())

      rotation: -> new Khan.Loop 'rotation', 360
