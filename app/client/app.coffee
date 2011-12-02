# Client-side Code

# Bind to socket events
SS.socket.on 'disconnect', ->  $('#message').text('SocketStream server is down :-(')
SS.socket.on 'reconnect', ->   $('#message').text('SocketStream server is up :-)')

# This method is called automatically when the websocket connection is established. Do not rename/delete
exports.init = ->
  

  features_template = "<h1>Test Run <small>{{duration}} seconds</small></h1><div>{{#features}}{{>feature}}{{/features}}</div>";
  partials = {
    feature: "<div class='{{keyword}} row'>
                <div class='span6'>
                  <h2>{{name}} <small>{{duration}} milliseconds</small></h2>
                  {{#description}}<blockquote><p>{{{description}}}</p></blockquote>{{/description}}  
                  <h3>Tags</h3>
                  <ul>{{#tags}}{{>tag}}{{/tags}}</ul>
                </div>
                <div class='span10'> 
                  {{#scenarios}}{{>scenario}}{{/scenarios}}
                </div>  
              </div>"
    scenario: "<div class='row {{keyword}}'>
                  <div class='span8'>
                    <h4>{{name}} <small>{{duration}} milliseconds</small></h4>
                  </div>
              </div>
              <div class='well {{#result}}{{label}}{{/result}}'>{{#steps}}{{>steps}}{{/steps}}</div>",
    steps: "<div class='row'>
              <div class='span8 {{keyword}}'><strong>{{keyword}}</strong> {{name}}</div>
              <div class='span1'>{{#result}}<span class='label {{label}}'>{{status}}</span>{{/result}}</div> 
            </div>"
    tag: "<li class='tag'>{{.}}</li>"
  
  }

  SS.server.app.get_results "test1234", (features) ->
    console.log "new"
    console.log JSON.parse(features)

  SS.server.app.get_results "test1234", (features) ->
    features = JSON.parse(features)
    features.duration = features.duration / 1000
    _.each features["features"], (feature) ->
      feature.description = feature.description.replace /\n/g, '<br/>'
      if feature.result && feature.result.status == "passed"
        feature.result["label"] = "success"
      else if feature.result && feature.result.status == "undefined"
        feature.result["label"] = "warning"
      else if feature.result && feature.result.status == "pending"
        feature.result["label"] = "notice"
      else if feature.result && feature.result.status == "failed"
        feature.result["label"] = "important"
        
      _.each feature.scenarios, (scenario) ->
        #scenario.duration = scenario.duration / 1000
        if scenario.result && scenario.result.status == "passed"
          scenario.result["label"] = "success"
        else if scenario.result && scenario.result.status == "undefined"
          scenario.result["label"] = "warning"
        else if scenario.result && scenario.result.status == "pending"
          scenario.result["label"] = "notice"
        else if scenario.result && scenario.result.status == "failed"
          scenario.result["label"] = "important"
        
                
        _.each scenario.steps, (step) ->
          #if step.duration
          #  step.duration = step.duration / 1000
          if step.result && step.result.status
            if step.result.status == "passed"
              step.result["label"] = "success"
            else if step.result.status == "skipped"
              step.result["label"] = ""
            else if step.result.status == "pending"
              step.result["label"] = "notice"
            else if step.result.status == "undefined"
              step.result["label"] = "warning"
            else if step.result.status == "failed"
              step.result["label"] = "important"
    
    $(".cucumber-report").append(Mustache.to_html(features_template, features, partials))