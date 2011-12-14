SS.events.on 'newResult', (report) ->
  console.log "newREsult"
  console.log report
  app = window.Apps.find (app) ->
    app.get("name") == report.app_name
  if app
    instance = app.instances.find (instance) ->
      instance.get("name") == report.instance_name
  if instance
    result = report["result"]
    report = new Report(result)
    #report.addMetaData()
    instance.results.add report

exports.init = ->
  window.ReportView = Backbone.View.extend(
    el: $("#report")

    events:
      "click .feature_info .feature.passed": "togglePassedFeatures"
      "click .feature_info .feature.pending": "togglePendingFeatures"
      "click .feature_info .feature.undefined": "toggleUndefinedFeatures"
      "click .feature_info .feature.pending": "togglePendingFeatures"
      "click .feature_info .feature.failed": "toggleFailedFeatures"
      "click .feature_info .scenario.passed": "togglePassedScenarios"
    
    togglePassedFeatures: ->
      console.log @el
      $(".Feature.passed").toggle()
      $(".feature_info .passed").toggleClass("hidden");

    togglePassedScenarios: ->
      console.log @el
      $(".Scenario.passed").toggle()
      $(".feature_info .scenario.passed").toggleClass("hidden");

    togglePendingFeatures: ->
      console.log @el.target
      $(".Feature.pending").toggle()
      $(".feature_info .feature.passed").toggleClass("hidden");

    toggleUndefinedFeatures: ->
      $(".Feature.undefined").toggle()
      $(".feature_info .feature.undefined").toggleClass("hidden");

    togglePendingFeatures: ->
      $(".Feature.pending").toggle()
      $(".feature_info .feature.pending").toggleClass("hidden");

    toggleFailedFeatures: ->
      $(".Feature.failed").toggle()
      $(".feature_info .feature.failed").toggleClass("hidden");

    render: ->
      $(@el).html ich.report_view @model.fullJSON()
      $("#report .timeago").timeago()
  ) 

  window.InstanceResultsView = Backbone.View.extend(
    el: $("#sidebar")

    initialize: ->
      @model.results.bind "add", @remoteAddOne, this
      @model.results.bind "reset", @addAll, this
      @model.results.bind "all", @render, this

    remoteAddOne: (result) ->
      view = new InstanceResultView(model: result)
      $("#sidebar .results").prepend view.render().el
      $("time.timeago").timeago()
      return view

    addOne: (result) ->
      view = new InstanceResultView(model: result)
      $("#sidebar .results").append view.render().el
      $("time.timeago").timeago()
      return view

    addAll: ->
      @model.results.each(this.addOne)

    render: ->
      model = @model.toJSON()
      model.results = @model.results.toJSON()
      model.app_name = @model.collection.parent.get("name")
      $(@el).html ich.result_view model
      @addAll()
  )


  window.InstanceResultView = Backbone.View.extend(
    tagName: "li"
    className: "result"
      
    initialize: ->
      @model.bind "change", @render, this
      @model.bind "destroy", @remove, this
    
    render: ->
      $(@el).html ich.result_item_view @model.navJSON()
      return @
  )

  $(document).ready ->
    window.Apps = new AppList
    window.ApplicationNavigationView = new ApplicationNavigationView
    Apps.fetch success: ->
      window.app_router = new AppRouter
      Backbone.history.start()
