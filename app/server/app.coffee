# Server-side Code

exports.actions =
  all: (cb) ->
    Seq()
      .seq_((next) ->
         R.smembers "apps", next
      )
      .flatten()
      .parEach_((next, app) ->
         R.smembers "instances:" + app, next.into(app)
      )
      .seq_((next) ->
        apps = []
        _.each @vars, (instances, app) ->
          _.each instances, (instance) ->
            apps.push {name: app, instance: instance}
        next null, apps
      )
      .flatten()
      .parEach_((next, app) ->
        key = "test_results:" + app.name + ":" + app.instance
        R.hkeys key, next.into(key)
      )
      .seq_((next)->
        apps = {}
        _.each @vars, (timestamps, key) ->
          console.log timestamps, key
          key = key.match(/test_results:([^:]*):([^:]*)/)
          if key
            app = key[1]
            instance = key[2]
            if apps[app]
              apps[app].instances.push {name: instance, results: timestamps}
            else
              apps[app] = {name: app, instances: [{name: instance, results: timestamps}]}
        apps_array = []
        _.each apps, (app) ->
          apps_array.push(app)
        cb apps_array
      )
      .catch((err) ->
        cb err
      )
    
  instances: (app, cb) ->
    R.smembers "instances:" + app, (err, response) ->
      cb response