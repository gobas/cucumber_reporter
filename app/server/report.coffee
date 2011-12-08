# Server-side Code

exports.actions =
  get_result: (app, instance, timestamp, cb) ->
    key = "test_results:" + app + ":" + instance
    R.hget key, timestamp, (err, result) ->
      console.log result
      cb result
    
  get_results: (app, instance, cb) ->
    key = "test_results:" + app + ":" + instance
    R.hkeys key, (err, keys) ->
      cb keys
  
  get_result_sets: (app, cb) ->
    Seq()
      .seq_((next) ->
         R.smembers "instances:" + app, next
      )
      .flatten()
      .parEach_((next, instance) ->
         key = "test_results:" + app + ":" + instance
         R.hkeys key, next.into(instance)
      )
      .seq_((next) ->
        hash = []
        _.each @vars, (result_set, instance) ->
          results = []
          _.each result_set, (timestamp) ->
            results.push {timestamp: timestamp, instance: instance}
          
          hash.push {name: instance, results: results}
        
        cb hash
      )
      .catch((err) ->
        cb err
      )