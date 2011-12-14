window.Scenario = Backbone.Model.extend(
  initialize: ->
    self = @
    if self.get("steps")
      self.steps = new StepList(self.get("steps"), {parent: self})
      delete self.attributes["steps"]
 
  fullJSON: ->
    json = @.toJSON()
    json["steps"] = @.steps.fullJSON()
    return json
)

window.ScenarioList = Backbone.Collection.extend(
  initialize: (models, options) ->
    self = @
    self.parent = options.parent if options.parent

  model: Scenario

  fullJSON: ->
    response = []
    @.each (model) ->
      response.push model.fullJSON()
    return response
)