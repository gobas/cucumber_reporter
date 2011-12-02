# Server-side Code

exports.actions =
  
  init: (cb) ->
    cb "SocketStream version #{SS.version} is up and running. This message was sent over Socket.IO so everything is working OK."

  import_results: (cb) ->
    result = JSON.parse @request.post.raw
    console.log result
    cb result
    
  get_test_envs: (cb) ->
    cb #return diffent test envs  
    
  get_result: (result_id, cb) ->
    R.get "test123", (err, result) ->
      cb result  
    
  get_results: (string, cb) ->
    R.get string, (err, result) ->
      cb result