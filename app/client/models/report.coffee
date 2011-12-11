window.Report = Backbone.Model.extend(
  featureCount: ->
    return @.get("features").length
  scenarioCount: ->
    scenario_count = 0
    _.each @.get("features"), (feature) ->
      scenario_count = scenario_count + feature.scenarios.length
    return scenario_count

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

  getFullReport: (cb) ->
    self = @
    SS.server.report.get_result self.collection.parent.collection.parent.get("name"), self.collection.parent.get("name"), self.get('timestamp'), (result) ->
      result = JSON.parse result
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