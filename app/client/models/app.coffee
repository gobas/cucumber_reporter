window.App = Backbone.Model.extend(
  initialize: ->
    self = @
    if self.get("instances")
      self.instances = new InstanceList(self.get("instances"), {parent: self})
      delete self.attributes["instances"]
)

window.AppList = Backbone.Collection.extend(
  model: App,
  remoteStorage: new Store("app")
)