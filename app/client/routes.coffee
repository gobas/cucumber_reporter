window.AppRouter = Backbone.Router.extend(
  routes:
    help: "help"
    "app/:query": "loadApp"
    "app/:query/:instance": "loadAppInstance"

  loadApp: (app) ->
    app = _.find Apps.models, (app) ->
      return app.get("name") == app
   
    $("#sidebar").html("")
    $("#report").html("")
    app.collection.each (model) ->
      model.set({active: false}, {silent: true})
    app.set({active: true})
    view = new InstanceNavigationView(model: app)
    if $("ul.nav .instances").length > 0
      $("ul.nav .instances").replaceWith view.render().el
    else
      $("ul.nav .apps").after view.render().el
    view.addAll()
    console.log "yeah"
    console.log app
  
  loadAppInstance: (app, instance) ->

    
  help: (query, page) ->
)
