loadApp = (app) ->
  app = _.find Apps.models, (stored_app) ->
        return stored_app.get("name") == app
 
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

window.AppRouter = Backbone.Router.extend(
  routes:
    help: "help"
    "app/:query": "loadApp"
    "app/:query/:instance": "loadAppInstance"

  loadApp: (app) ->
    loadApp(app)
  
  loadAppInstance: (app, instance) ->
    app = loadApp(app)
    instance = _.find app.instances.models, (stored_instance) ->
        return stored_instance.get("name") == instance
    
    instance.set({active: true})
    
    results_view = new InstanceResultsView(model: instance)
    results_view.render()

    report = instance.results.first()
    report.getFullReport (full_report) ->
      console.log full_report
      report_view = new ReportView(model: full_report)
      report_view.render()
    $("time.timeago").timeago();

    console.log app, instance
    
  help: (query, page) ->
)
