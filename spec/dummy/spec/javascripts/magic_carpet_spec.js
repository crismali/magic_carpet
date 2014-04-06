describe("MagicCarpet", function() {
  var subject;

  beforeEach(function() {
    subject = MagicCarpet;
  });

  afterEach(function() {
    $("#magic-carpet").remove();
  });

  it("has its async property set to false by default", function(){
    expect(subject.async).toBeFalse();
  });

  it("has its asyncComplete property set to true by default", function(){
    expect(subject.asyncComplete).toBeTrue();
  });

  it("has an object for caching request results", function(){
    expect(subject.cache).toBeObject();
  });

  describe("initialize", function() {
    beforeEach(function() {
      spyOn(subject, "cacheElements");
      spyOn(subject, "appendSandbox");
      spyOn(subject, "bindAll");
      subject.initialize();
    });

    it("caches the necessary elements", function() {
      expect(subject.cacheElements).toHaveBeenCalled();
    });

    it("appends the sandbox", function(){
      expect(subject.appendSandbox).toHaveBeenCalled();
    });

    it("binds all of its functions", function(){
      expect(subject.bindAll).toHaveBeenCalled();
    });
  });

  describe("bindAll", function(){
    var dummyFunction;
    beforeEach(function() {
      subject.dummyOption = false;
      dummyFunction = function() { this.dummyOption = true; };
      subject.dummy = dummyFunction;
      subject.bindAll();
    });

    afterEach(function() {
      delete subject.dummy;
      delete subject.dummyOption;
    });

    it("binds all methods", function(){
      expect(subject.dummy).not.toEqual(dummyFunction);
      subject.dummy();
      expect(subject.dummyOption).toBeTrue();
    });
  });

  describe("bind", function(){
    it("binds the function to the context", function(){
      var obj = {};
      obj.func = function(arg) { this.funcArg = arg; };
      subject.bind(obj, "func");
      var func = obj.func;
      func("arg");
      expect(obj.funcArg).toEqual("arg");
    });
  });

  describe("cacheElements", function() {
    beforeEach(function() {
      spyOn(subject, "createSandbox").and.returnValue("sandbox");
      subject.cacheElements();
    });

    it("caches a sandbox", function() {
      expect(subject.sandbox).toEqual("sandbox");
    });
  });

  describe("createSandbox", function() {
    it("returns a div", function() {
      expect(subject.createSandbox().tagName).toEqual("DIV");
    });

    it("returns a div with an ID of #magic-carpet", function() {
      expect(subject.createSandbox().getAttribute("id")).toEqual("magic-carpet");
    });
  });

  describe("appendSandbox", function() {
    beforeEach(function() {
      subject.cacheElements();
      subject.appendSandbox();
    });

    it("appends the sandbox to the body", function() {
      expect(subject.sandbox).toBeDefined();
      expect(subject.sandbox).toEqual($("body #magic-carpet")[0]);
    });
  });

  describe("emptySandbox", function(){
    beforeEach(function() {
      subject.cacheElements();
      subject.sandbox.innerHTML = '<div id="dummy"></div>';
      subject.emptySandbox();
    });

    it("empties the sandbox", function(){
      expect($("#dummy")[0]).toBeUndefined();
      expect(subject.sandbox.innerHTML).toEqual("");
    });
  });

  describe("request", function(){
    var requestData;
    beforeEach(function() {
      subject.cacheElements();
      spyOn(subject, "fetch");
      requestData = { some: "template" };
    });

    it("fetches the markup if the request isn't cached", function(){
      subject.cache = {};
      subject.request(requestData);
      expect(subject.fetch).toHaveBeenCalledWith(requestData);
      expect(subject.sandbox.innerHTML).toEqual("");
    });

    it("puts the markup on the page when it's already cached", function(){
      subject.cache[$.param(requestData)] = "markup";
      subject.request(requestData);
      expect(subject.fetch).not.toHaveBeenCalled();
      expect(subject.sandbox.innerHTML).toEqual("markup");
    });
  });

  describe("fetch", function(){
    var arg;
    beforeEach(function() {
      subject.asyncComplete = true;
      subject.lastRequest = undefined;
      spyOn($, "ajax").and.returnValue(promiseStub);
      subject.async = "default async setting";
      subject.fetch("data");
      arg = $.ajax.calls.argsFor(0)[0];
    });

    it("makes a get request to /magic_carpet", function(){
      expect(arg.url).toEqual("/magic_carpet");
      expect(arg.method).toEqual("get");
    });

    it("uses the global magic carpet async setting", function(){
      expect(arg.async).toEqual("default async setting");
    });

    it("passes its argument as data", function(){
      expect(arg.data).toEqual("data");
    });

    it("sets asyncComplete to false", function(){
      expect(subject.asyncComplete).toBeFalse();
    });

    it("handles success", function(){
      expect(promiseStub.done).toHaveBeenCalledWith(subject.handleSuccess);
    });

    it("handles failure", function(){
      expect(promiseStub.fail).toHaveBeenCalledWith(subject.handleFailure);
    });

    it("cleans up after itself", function(){
      expect(promiseStub.always).toHaveBeenCalledWith(subject.afterRequest);
    });

    it("caches the request object", function(){
      expect(subject.lastRequest).toEqual("data");
    });
  });

  describe("handleSuccess", function(){
    var lastRequest;
    var markup;
    beforeEach(function() {
      subject.appendSandbox();
      lastRequest = { some: "template" };
      subject.lastRequest = lastRequest;
      subject.cache = {};
      markup = '<div id="fresh-markup"></div>';
      subject.handleSuccess(markup);
    });

    it("puts the markup in the sandbox", function(){
      expect($("#magic-carpet #fresh-markup")[0]).toBeDefined();
    });

    it("caches the markup", function(){
      expect(subject.cache[$.param(lastRequest)]).toEqual(markup);
    });
  });

  describe("handleFailure", function(){
    it("throws an error with a message", function(){
      var errorObj = { error: "There was a problem" };
      var response = { responseJSON: errorObj };
      expect(function() {
        subject.handleFailure(response);
      }).toThrow(new Error(errorObj.error));
    });
  });

  describe("afterRequest", function(){
    beforeEach(function() {
      subject.asyncComplete = false;
      subject.afterRequest();
    });

    it("sets asyncComplete to true", function(){
      expect(subject.asyncComplete).toBeTrue();
    });
  });
});
