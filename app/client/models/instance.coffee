window.Instance = Backbone.Model.extend(
  initialize: ->
    self = @
    if self.get("results")
      self.results = new ReportList(null, {parent: self})
      _.map self.attributes["results"], (result) ->
         return {timestamp: result}
      _.each self.attributes["results"], (tstamps) ->
        self.results.add {timestamp: tstamps}
      delete self.attributes["results"]
)

window.InstanceList = Backbone.Collection.extend(
  initialize: (models, options) ->
    @parent = options.parent if options.parent
  model: Instance
)