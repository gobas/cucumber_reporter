# Client-side Code

# Bind to socket events
SS.socket.on 'disconnect', ->  $('#message').text('SocketStream server is down :-(')
SS.socket.on 'reconnect', ->   $('#message').text('SocketStream server is up :-)')


# This method is called automatically when the websocket connection is established. Do not rename/delete
exports.init = ->
  $(document).ready ->
    
    SS.client.backbone.init()
  