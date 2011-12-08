// A simple module to replace `Backbone.sync` with *localStorage*-based
// persistence. Models are given GUIDS, and saved into a JSON object. Simple
// as that.

// Generate four random hex digits.
function S4() {
   return (((1+Math.random())*0x10000)|0).toString(16).substring(1);
};

// Generate a pseudo-GUID by concatenating random hexadecimal.
function guid() {
   return (S4()+S4()+"-"+S4()+"-"+S4()+"-"+S4()+"-"+S4()+S4()+S4());
};

// Our Store is represented by a single JS object in *localStorage*. Create it
// with a meaningful name, like the name you'd give a table.
var Store = function(name) {
  this.name = name;
};

_.extend(Store.prototype, {

  // Save the current state of the **Store** to *localStorage*.
  save: function() {
    console.log("save");
  },

  // Add a model, giving it a (hopefully)-unique GUID, if it doesn't already
  // have an id of it's own.
  create: function(model) {
    console.log("create");
  },

  // Update a model by replacing its copy in `this.data`.
  update: function(model) {
    console.log("update");
  },

  // Retrieve a model from `this.data` by id.
  find: function(model) {
    console.log("find");
  },

  // Return the array of all models currently in storage.
  findAll: function(callbacks) {
    console.log("findAll");
    SS.server[this.name].all(function(response) {
      callbacks.success(response);
    })
  },

  // Delete a model from `this.data`, returning it.
  destroy: function(model) {
    console.log("destroy");
  }

});

// Override `Backbone.sync` to use delegate to the model or collection's
// *localStorage* property, which should be an instance of `Store`.
Backbone.sync = function(method, model, options) {

  var resp;
  var store = model.remoteStorage || model.collection.remoteStorage;

  switch (method) {
    case "read":    resp = model.id ? store.find(model) : store.findAll(options); break;
    case "create":  resp = store.create(model);                            break;
    case "update":  resp = store.update(model);                            break;
    case "delete":  resp = store.destroy(model);                           break;
  }

  if (resp) {
    options.success(resp);
  } else {
    options.error("Record not found");
  }
};