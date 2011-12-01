# Client-side Code

# Bind to socket events
SS.socket.on 'disconnect', ->  $('#message').text('SocketStream server is down :-(')
SS.socket.on 'reconnect', ->   $('#message').text('SocketStream server is up :-)')

# This method is called automatically when the websocket connection is established. Do not rename/delete
exports.init = ->
  

  feature_template = "<div class='{{keyword}} row'><div class='span6'><h2>{{name}} {{#result}}<span class='label {{label}}'>{{status}}</span>{{/result}}</h2>{{#description}}<blockquote><p>{{{description}}}</p></blockquote>{{/description}}  <h3>Tags</h3><ul>{{#tags}}{{>tag}}{{/tags}}</ul></div><div class='span10'> {{#scenarios}}{{>scenario}}{{/scenarios}}</div></div>";
  partials = {
    scenario: "<div class='{{keyword}}'><h3>{{name}} <small>{{#tags}}{{.}}{{/tags}}</small> {{#result}}<span class='label {{label}}'>{{status}}</span>{{/result}}</h3>  <div class='well'>{{#steps}}{{>steps}}{{/steps}}</div></div>",
    steps: "<div class='row'><div class='span8 {{keyword}}'><strong>{{keyword}}</strong> {{name}}</div> <div class='span1'>{{#result}}<span class='label {{label}}'>{{status}}</span>{{/result}}</div> </div>"
    tag: "<li class='tag'>{{.}}</li>"
  
  }

  SS.server.app.get_results (features) ->
    features = JSON.parse(features)
    _.each features, (feature) ->
      feature.description = feature.description.replace /\n/g, '<br/>'
      if feature.passed == true
        feature.result = {status: "passed", label: "success"}
      if feature.undefined == true
        feature.result = {status: "undefined", label: "warning"}
      if feature.pending == true
        feature.result = {status: "pending", label: "notice"}
    
      _.each feature.scenarios, (scenario) ->
        if scenario.passed == true
          scenario.result = {status: "passed", label: "success"}
        if scenario.undefined == true
          scenario.result = {status: "undefined", label: "warning"}
        if scenario.pending == true
          scenario.result = {status: "pending", label: "notice"}
                
        _.each scenario.steps, (step) ->
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
    
    _.each features, (feature) ->
      console.log feature
      $(".cucumber-report").append(Mustache.to_html(feature_template, feature, partials))

  # Make a call to the server to retrieve a message
  SS.server.app.get_results (features) ->
    if false
      features = JSON.parse(features);
      formatter = new CucumberHTML.DOMFormatter($('.cucumber-report'));
      formatter.uri('report.feature');
      i = 0;
      for feature in features
        console.log feature
        console.log Mustache.to_html(feature_template, feature, partials)
        i++;
        formatter.uri('report.feature' + i);
        formatter.feature feature
        if feature.background
          background_step_lines = []
          formatter.background feature.background
        
          for scenario in feature.scenarios 
            for step in scenario.steps
              if step.line < scenario.line && step.line > feature.background.line
                render = true
                for line in background_step_lines
                  if line == step.line
                    render = false
                if render
                  background_step_lines.push step.line
                  formatter.step step
                  if step.result != undefined
                    formatter.match {uri: 'report.feature' + i}
                    formatter.result(step.result);
                  
        for scenario in feature.scenarios
          formatter.scenario scenario
          for step in scenario.steps
            if step.line > scenario.line
              formatter.step step
              if step.result
                formatter.match {uri: 'report.feature' + i}
                formatter.result(step.result);