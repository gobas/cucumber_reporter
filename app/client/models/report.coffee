window.Report = Backbone.Model.extend(
  initialize: ->
    self = @
    console.log "initalizing report", self.attributes
    if self.get("features")
      self.instances = new FeatureList(self.get("features"), {parent: self})
      delete self.attributes["features"]

  featureCount: ->
    return @.features.length

  scenarioCount: ->
    scenario_count = 0
    _.each @.features.each (feature) ->
      scenario_count = scenario_count + feature.scenarios.length
    return scenario_count

  fullJSON: ->
    json = @.toJSON()
    json["duration"] = json["duration"] / 1000.0
    json["features"] = @.features.fullJSON()
    return json

  navJSON: ->
    json = @.toJSON()
    json["instance_name"] = @.collection.parent.get("name")
    json["app_name"] = @.collection.parent.collection.parent.get("name")
    tstamp = new Date(parseInt(json["timestamp"]))
    json["created_at"] = tstamp.toISOString()
    return json

  isUndefined: ->
    return @.get("undefined_steps_count") > 0
  isFailing: ->
    return @.get("failed_steps_count") > 0
  isPending: ->
    return @.get("pending_steps_count") > 0    
  isSuccessfull: ->
    @.get("failed_steps_count") == 0
  isComplete: ->
    if @.get("failed_steps_count") == @.get("pending_steps_count") == @.get("skipped_steps_count") == 0
      return true
    else
      return false
  getTimestamp: ->
    tstamp = parseInt(@.get("timestamp"))
    x = new Date(tstamp)
    return x.toISOString()

  addMetaData: ->
    self = @
    self.set({failing: self.isFailing(), undefined: self.isUndefined(), pending: self.isPending(), successfull: self.isSuccessfull(), complete: self.isComplete()}, {silent: true})
    self.set({feature_count: self.featureCount(), scenario_count: self.scenarioCount()}, {silent: true})
    self.set({created_at: self.getTimestamp()}, {silent: true})

  openReport: ->
    result = @
    result.collection.each (model) ->
      model.set({active: false}, {silent: true})
    result.set({active: true})

    if result.get("created_at")
      view = new ReportView(model: result)
      view.render()
    else
      result.getFullReport (report) ->
        view = new ReportView(model: result)
        view.render()

  getFullReport: (cb) ->
    self = @
    SS.server.report.get_result self.collection.parent.collection.parent.get("name"), self.collection.parent.get("name"), self.get('timestamp'), (result) ->
      result = JSON.parse result
      self.features = new FeatureList(result["features"], {parent: self})
      delete result["features"]
      self.set(result, {silent: true})
      self.addMetaData()
      cb(self)
    #return x.toUTCString()
)

window.ReportList = Backbone.Collection.extend(
  initialize: (models, options) ->
    self = @
    self.parent = options.parent if options.parent
  comparator: (report) ->
    return Date.now() - report.get("timestamp")
  model: Report
)