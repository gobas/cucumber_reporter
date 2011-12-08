window.ApplicationNavigationView = Backbone.View.extend(
    el: $("#app_list")
    
    initialize: ->
      Apps.bind "add", @addOne, this
      Apps.bind "reset", @addAll, this
      Apps.bind "all", @addAll, this
      Apps.fetch()
      $(".topbar").dropdown()

    addAll: ->
      $("#app_list").html("")
      Apps.each(this.addOne);
        
    addOne: (app) ->
      if app.get("active") == true
        $(".nav > .apps").addClass("active")
        $(".nav > .apps .dropdown-toggle").text(app.get("name"))
          
      view = new ApplicationNavigationItemView(model: app)
      @$("#app_list").append view.render().el
  )

window.ApplicationNavigationItemView = Backbone.View.extend(
  tagName: "li"
  className: "app"

  events:
    "click a": "openApp"

  initialize: ->
    @model.bind "change", @render, this
    @model.bind "destroy", @remove, this
    #@render_instances()

  openApp: ->
    $("#sidebar").html("")
    $("#report").html("")
    @model.collection.each (model) ->
      model.set({active: false}, {silent: true})
    @model.set({active: true})
    view = new InstanceNavigationView(model: @model)
    if $("ul.nav .instances").length > 0
      $("ul.nav .instances").replaceWith view.render().el
    else
      $("ul.nav .apps").after view.render().el
    view.addAll()
  
  render: ->
    $(@el).html ich.nav_view @model.toJSON()
    return @
)


window.InstanceNavigationView = Backbone.View.extend(
    tagName: "li"
    className: "dropdown"
      
    initialize: ->
      @model.instances.bind "add", @addOne, this
      @model.instances.bind "reset", @addAll, this
      @model.instances.bind "all", @render, this
      $(@el).addClass("instances")
      @model.instances.each (instance) ->
        instance.set({active: false}, {silent: true})
      

    render: ->
      $(@el).html ich.instances_view @model.toJSON()
      @addAll()
      return @

    addAll: ->
      console.log "add all"
      @model.instances.each(this.addOne)
      
    addOne: (instance) ->
      
      console.log $("#instance_list")
      if instance.get("active") == true
        $(".nav > .instances").addClass("active")
        $(".nav > .instances .dropdown-toggle").text(instance.get("name"))
          
      view = new InstanceNavigationItemView(model: instance)
      @$("#instance_list").append view.render().el
  )

window.InstanceNavigationItemView = Backbone.View.extend(
  tagName: "li"
  className: "instance"
    
  events:
    "click a": "openInstance"
  
  markActive: ->
    $(@el).parent().parent().addClass("active")
    
  openInstance: ->
    @model.set({active: true})
    @markActive()
    
    results_view = new InstanceResultsView(model: @model)
    results_view.render()

    report = @model.results.first()
    report.getFullReport (full_report) ->
      console.log full_report
      report_view = new ReportView(model: full_report)
      report_view.render()
    $("time.timeago").timeago();

  initialize: ->
    @model.bind "change", @render, this
    @model.bind "destroy", @remove, this

  render: ->
    $(@el).html ich.instance_view @model.toJSON()
    return @
)

