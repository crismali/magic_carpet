(MagicCarpet = {
  async: false,
  asyncComplete: true,

  initialize: function() {
    this.bindAll();
    this.cacheElements();
    this.appendSandbox();
  },

  bindAll: function() {
    for(var prop in this) {
      if (typeof this[prop] === "function" && this.hasOwnProperty(prop)) {
        this.bind(this, prop);
      }
    }
  },

  bind: function(context, methodName) {
    var func = context[methodName];
    context[methodName] = function() {
      return func.apply(context, arguments);
    };
  },

  cacheElements: function() {
    this.body = document.body;
    this.sandbox = this.createSandbox();
  },

  createSandbox: function() {
    var div = document.createElement("div");
    div.setAttribute("id", "magic-carpet-sandbox");
    return div;
  },

  appendSandbox: function() {
    this.body.appendChild(this.sandbox);
  },

  emptySandbox: function() {
    this.sandbox.innerHTML = "";
  },

  request: function(data) {
    this.asyncComplete = false;
    $.ajax({
      url: "/magic_carpet",
      method: "get",
      async: this.async,
      data: data
    })
    .done(this.handleSuccess)
    .fail(this.handleFailure)
    .always(this.afterRequest);
  },

  handleSuccess: function(markup) {
    this.sandbox.innerHTML = markup;
  },

  handleFailure: function(response) {
    throw new Error(response.responseJSON.error);
  },

  afterRequest: function() {
    this.asyncComplete = true;
  }
}).initialize();
