window.ApplicationNavigationView = Backbone.View.extend(
    el: $("#app_list")
    
    initialize: ->
      Apps.bind "add", @addOne, this
      Apps.bind "reset", @addAll, this
      Apps.bind "all", @addAll, this
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

  initialize: ->
    @model.bind "change", @render, this
    @model.bind "destroy", @remove, this
    #@render_instances()
  
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
      app = @model.toJSON()
      $(@el).html ich.instances_view app
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
    
  markActive: ->
    $(@el).parent().parent().addClass("active")
    
  initialize: ->
    @model.bind "change", @render, this
    @model.bind "destroy", @remove, this

  render: ->
    instance = @model.toJSON()
    console.log @model.collection.parent.get("name"), "instance navigation"
    instance["app_name"] = @model.collection.parent.get("name")
    $(@el).html ich.instance_view instance
    return @
)

