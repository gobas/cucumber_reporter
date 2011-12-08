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
    return x.toUTCString()
    #return x.toUTCString()
)

window.ReportList = Backbone.Collection.extend(
  initialize: (models, options) ->
    self = @
    self.parent = options.parent if options.parent
  comparator: (report) ->
    return report.get("timestamp")
  model: Report
)