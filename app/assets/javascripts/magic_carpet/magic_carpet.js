(MagicCarpet = {
  async: false,
  asyncComplete: true,
  cache: {},

  initialize: function() {
    this.bindAll();
    this.cacheElements();
    this.appendSandbox();
  },

  bindAll: function() {
    for(var prop in this) {
      if (typeof this[prop] === "function" && this.hasOwnProperty(prop))
        this.bind(this, prop);
    }
  },

  bind: function(context, methodName) {
    var func = context[methodName];
    context[methodName] = function() {
      return func.apply(context, arguments);
    };
  },

  cacheElements: function() {
    this.sandbox = this.createSandbox();
  },

  createSandbox: function() {
    var div = document.createElement("div");
    div.setAttribute("id", "magic-carpet");
    return div;
  },

  appendSandbox: function() {
    document.body.appendChild(this.sandbox);
  },

  emptySandbox: function() {
    this.sandbox.innerHTML = "";
  },

  request: function(data) {
    var cachedMarkup = this.cache[$.param(data)];
    if (cachedMarkup) {
      this.sandbox.innerHTML = cachedMarkup;
    } else {
      this.fetch(data);
    }
  },

  fetch: function(data) {
    this.lastRequest = data;
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
    var cacheKey = $.param(this.lastRequest);
    this.cache[cacheKey] = markup;
    this.request(this.lastRequest);
  },

  handleFailure: function(response) {
    throw new Error(response.responseJSON.error);
  },

  afterRequest: function() {
    this.asyncComplete = true;
  }
}).initialize();
