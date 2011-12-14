loadApp = (app) ->
  app = Apps.find (stored_app) ->
    return stored_app.get("name") == app
  if app.get("active") != true
    console.log "clearing sidebar"
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
  return app

loadAppInstance = (app, instance) ->

  app = loadApp(app)
  instance = app.instances.find (stored_instance) ->
    return stored_instance.get("name") == instance
  if $("#sidebar").html() == ""
    instance.set({active: true})
    instance.collection.each (model) ->
      model.set({active: false}, {silent: true})

    results_view = new InstanceResultsView(model: instance)
    results_view.render()
    window.location = "#app/" + app.get("name") + "/" + instance.get("name") + "/" + instance.results.first().get("timestamp")

    #report = instance.results.first()
    #report.getFullReport (full_report) ->
    #  console.log full_report
    #  report_view = new ReportView(model: full_report)
    #  report_view.render()
    $("time.timeago").timeago();
  return instance

window.AppRouter = Backbone.Router.extend(
  routes:
    help: "help"
    "app/:query": "loadApp"
    "app/:query/:instance": "loadAppInstance"
    "app/:query/:instance/:timestamp": "loadAppInstanceResult"

  loadApp: (app) ->
    loadApp(app)
  
  loadAppInstance: (app, instance) ->
    loadAppInstance(app, instance)
    
  loadAppInstanceResult: (app, instance, timestamp) ->
    instance = loadAppInstance(app, instance)
    result = instance.results.find (stored_result) ->
      return stored_result.get("timestamp") == timestamp
    result.set({active: true})
    result.collection.each (model) ->
      model.set({active: false}, {silent: true})

    if result.get("created_at")
      view = new ReportView(model: result)
      view.render()
    else
      result.getFullReport (report) ->
        view = new ReportView(model: result)
        view.render()


    console.log app, instance, timestamp
)
