exports.init = ->
  window.App = Backbone.Model.extend(
    initialize: ->
      self = @
      if self.get("instances")
        self.instances = new InstanceList(self.get("instances"), {parent: self})
        delete self.attributes["instances"]
  )
  
  window.AppList = Backbone.Collection.extend(
    model: App,
    remoteStorage: new Store("app")
  )
  
  window.Apps = new AppList
  
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
  
  window.ReportView = Backbone.View.extend(
    el: $("#report")
    render: ->
      model = @model.toJSON()
      model.duration = model.duration / 1000.0
      $(@el).html ich.report_view model
  )
   
  window.InstanceNavigationView = Backbone.View.extend(
    tagName: "li"
    className: "report"
      
    events:
      "click a": "openReport"
      
    openReport: ->
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
  
  window.SidebarView = Backbone.View.extend(
    el: $("#sidebar")
    #className: "nav"
    
    events:
      "click .instances a": "openReport"

    openReport: ->
      #view = new ReportView(model: @model)
      #$("#cucumber-report").html view.render().el

    initialize: ->
      console.log "initalizing app view", @model
      @model.bind "change", @render, this
      @model.bind "destroy", @remove, this
      @model.instances.bind "add", @addOne, this
      @model.instances.bind "reset", @addAll, this
      @model.instances.bind "all", @render, this
      
    addOne: (instance) ->
      view = new InstanceNavigationView(model: instance)
      $("#sidebar ul").append(view.render().el)
      #$(".instances").append view.render().el

    render_instances: ->
      @model.instances.each(this.addOne)
      return @

    render: ->
      $(@el).html ich.sidebar_view @model.toJSON()
      @render_instances()
      #return @
  )

  window.NavigationItemView = Backbone.View.extend(
    tagName: "li"
    className: "nav"
    
    events:
      "click .app": "openApp"

    openApp: ->
      sidebar = new SidebarView(model: @model)
      sidebar.render()
      #$("#sidebar").html sidebar.render().el
      
    initialize: ->
      @model.bind "change", @render, this
      @model.bind "destroy", @remove, this

    render: ->
      $(@el).html ich.nav_view @model.toJSON()
      return @
  )
  
  window.NavigationView = Backbone.View.extend(
    el: $("body")
    
    initialize: ->
      Apps.bind "add", @addOne, this
      Apps.bind "reset", @addAll, this
      Apps.bind "all", @render, this
      Apps.fetch()

    render: ->
      $(".topbar .container-fluid").append ich.navigation {}

    addAll: ->
      Apps.each(this.addOne);
        
    addOne: (app) ->
      view = new NavigationItemView(model: app)
      @$(".topbar ul.nav").append view.render().el

  )
  window.NavigationView = new NavigationView