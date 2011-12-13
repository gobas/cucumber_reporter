# Server-side Code

exports.actions =
  results: (params, cb) ->
    instance = params.instance
    app = params.app
    result_raw = @request.post.raw
    result = JSON.parse result_raw
    key = "test_results:" + app + ":" + instance
    hkey = Date.now()
    result["timestamp"] = hkey
    
    SS.publish.broadcast "newResult", {app_name: app, instance_name: instance, result: result}


    R.sadd "apps", app
    R.sadd "instances:" + app, instance
    
    console.log JSON.parse result_raw
    
    R.hset key, hkey, result_raw, (err, response) ->
      if (err)
        cb err
      else if response == 0
        cb {error: true}
      else
        cb {success: true}
    