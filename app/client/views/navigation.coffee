window.NavigationView = Backbone.View.extend(
    el: $("body")
    
    initialize: ->
      Apps.bind "add", @addOne, this
      Apps.bind "reset", @addAll, this
      Apps.bind "all", @render, this
      Apps.fetch()
      $(".topbar").dropdown()

    render: ->
      $(".topbar .container-fluid").append ich.navigation {}

    addAll: ->
      Apps.each(this.addOne);
        
    addOne: (app) ->
      view = new NavigationItemView(model: app)
      @$(".topbar ul.nav").append view.render().el
  )

window.NavigationItemView = Backbone.View.extend(
  tagName: "li"
  className: "dropdown"

  initialize: ->
    @model.bind "change", @render, this
    @model.bind "destroy", @remove, this
    #@render_instances()

  render_instances: (list) ->
    model = @model
    _.each model.instances.models, (instance) ->
      console.log list
      view = new InstanceNavigationView(model: instance)
      list.append view.render().el

  render: ->
    $(@el).html ich.nav_view @model.toJSON()
    @render_instances $(@el).children('ul')
    return @
)

window.InstanceNavigationView = Backbone.View.extend(
  tagName: "li"
  className: "report"
    
  events:
    "click a": "openReport"
    
  openReport: ->
    results_view = new InstanceResultsView(model: @model)
    results_view.render()

    report = @model.results.last()
    
    SS.server.report.get_result @model.collection.parent.get("name"), @model.get("name"), report.get('timestamp'), (result) ->
      result = JSON.parse result
      report.set(result, {silent: true})
      report.set({failing: report.isFailing(), undefined: report.isUndefined(), pending: report.isPending(), successfull: report.isSuccessfull(), complete: report.isComplete()}, {silent: true})
      report.set({feature_count: report.featureCount(), scenario_count: report.scenarioCount()}, {silent: true})
      report.set({created_at: report.getTimestamp()}, {silent: true})
      console.log report
      report_view = new ReportView(model: report)
      report_view.render()
    
  initialize: ->
    @model.bind "change", @render, this
    @model.bind "destroy", @remove, this

  render: ->
    $(@el).html ich.instance_view @model.toJSON()
    return @
)

