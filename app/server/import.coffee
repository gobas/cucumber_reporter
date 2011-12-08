# Server-side Code

exports.actions =
  results: (params, cb) ->
    instance = params.instance
    app = params.app
    result = @request.post.raw
    key = "test_results:" + app + ":" + instance
    hkey = Date.now()
    
    
    R.sadd "apps", app
    R.sadd "instances:" + app, instance
    
    
    R.hset key, hkey, result, (err, response) ->
      if (err)
        cb err
      else if response == 0
        cb {error: true}
      else
        cb {success: true}
    