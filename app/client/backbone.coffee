exports.init = ->
  window.Apps = new AppList
  window.ReportView = Backbone.View.extend(
    el: $("#report")
    render: ->
      model = @model.toJSON()
      model.duration = model.duration / 1000.0
      $(@el).html ich.report_view model
  ) 

  window.InstanceResultsView = Backbone.View.extend(
    el: $("#sidebar")

    initialize: ->

    addOne: (result) ->
      view = new InstanceResultView(model: result)
      $("#sidebar .results").append view.render().el

    render_results: ->
      @model.results.each(this.addOne)

    render: ->
      model = @model.toJSON()
      model.results = @model.results.toJSON()
      model.app_name = @model.collection.parent.get("name")
      $(@el).html ich.result_view model
      @render_results()
  )


  window.InstanceResultView = Backbone.View.extend(
    tagName: "li"
    className: "result"
      
    initialize: ->
      @model.bind "change", @render, this
      @model.bind "destroy", @remove, this

    events:
        "click a": "openReport"
    
    openReport: ->
      @model.getFullReport (report) ->
        view = new ReportView(model: report)
        view.render()
  
    render: ->
      tstamp = @model.get("timestamp")
      date = new Date(parseInt(tstamp))

      $(@el).html ich.result_item_view {"timestamp": date.toUTCString()}
      return @
  )

  window.ApplicationNavigationView = new ApplicationNavigationView
  