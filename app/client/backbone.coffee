exports.init = ->
  window.Apps = new AppList
  window.NavigationView = new NavigationView
  window.ReportView = Backbone.View.extend(
    el: $("#report")
    render: ->
      model = @model.toJSON()
      model.duration = model.duration / 1000.0
      $(@el).html ich.report_view model
  ) 

  window.InstanceResultsView = Backbone.View.extend(
    el: $("#sidebar")
    render: ->
      model = @model.toJSON()
      model.instances = @model.results.toJSON()
      console.log model
      $(@el).html ich.result_view model
  ) 
  