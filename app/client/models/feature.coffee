window.Feature = Backbone.Model.extend(
  initialize: ->
    self = @
    if self.get("scenarios")
      self.scenarios = new ScenarioList(self.get("scenarios"), {parent: self})
      delete self.attributes["scenarios"]

  fullJSON: ->
    json = @.toJSON()
    json["scenarios"] = @.scenarios.fullJSON()
    return json
)

window.FeatureList = Backbone.Collection.extend(
  initialize: (models, options) ->
    self = @
    self.parent = options.parent if options.parent

  model: Feature

  fullJSON: ->
    response = []
    @.each (model) ->
      response.push model.fullJSON()
    return response
)