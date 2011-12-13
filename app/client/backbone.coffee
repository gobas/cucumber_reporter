SS.events.on 'newResult', (report) ->
  app = window.Apps.find (app) ->
    app.get("name") == report.app_name
  if app
    instance = app.instances.find (instance) ->
      instance.get("name") == report.instance_name
    if instance
      report = new window.Report(report.result)
      report.addMetaData()
      instance.results.add report

exports.init = ->
  window.Apps = new AppList
  window.ReportView = Backbone.View.extend(
    el: $("#report")

    events:
      "click .feature_info .passed": "togglePassedFeatures"
      "click .feature_info .pending": "togglePendingFeatures"
      "click .feature_info .undefined": "toggleUndefinedFeatures"
      "click .feature_info .pending": "togglePendingFeatures"
      "click .feature_info .failed": "toggleFailedFeatures"
    
    togglePassedFeatures: ->
      console.log @el
      $(".Feature.passed").toggle()
      $(".feature_info .passed").toggleClass("hidden");

    togglePendingFeatures: ->
      console.log @el.target
      $(".Feature.pending").toggle()
      $(".feature_info .passed").toggleClass("hidden");

    toggleUndefinedFeatures: ->
      $(".Feature.undefined").toggle()
      $(".feature_info .undefined").toggleClass("hidden");

    togglePendingFeatures: ->
      $(".Feature.pending").toggle()
      $(".feature_info .pending").toggleClass("hidden");

    toggleFailedFeatures: ->
      $(".Feature.failed").toggle()
      $(".feature_info .failed").toggleClass("hidden");


    render: ->
      model = @model.toJSON()
      model.duration = model.duration / 1000.0
      $(@el).html ich.report_view model
      $("#report .timeago").timeago()
  ) 

  window.InstanceResultsView = Backbone.View.extend(
    el: $("#sidebar")

    initialize: ->
      @model.results.bind "add", @remoteAddOne, this
      @model.results.bind "reset", @addAll, this
      @model.results.bind "all", @render, this
      

    remoteAddOne: (result) ->
      console.log "remote add one", @
      self = @
      view = self.addOne result
      view.renderReport()

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

    events:
        "click a": "openReport"
    
    renderReport: ->
      view = new ReportView(model: @model)
      view.render()

    openReport: ->
      self = @
      if @model.get("created_at")
        self.renderReport()
      else
        @model.getFullReport (report) ->
          self.renderReport()
    
    render: ->
      tstamp = @model.get("timestamp")
      date = new Date(parseInt(tstamp))

      $(@el).html ich.result_item_view {"timestamp": date.toISOString()}
      return @
  )

  window.ApplicationNavigationView = new ApplicationNavigationView
  Apps.fetch success: ->
    window.app_router = new AppRouter
    Backbone.history.start()
