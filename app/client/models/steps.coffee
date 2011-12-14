window.Step = Backbone.Model.extend(

  fullJSON: ->
    return @.toJSON()
)

window.StepList = Backbone.Collection.extend(
  initialize: (models, options) ->
    self = @
    self.parent = options.parent if options.parent

  model: Step

  fullJSON: ->
    response = []
    @.each (model) ->
      response.push model.fullJSON()
    return response
)