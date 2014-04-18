Magic Carpet
===========
Magic Carpet takes your templates on a magical trip to your JavaScript tests.

This ensures that **if your templates change, your JavaScript tests will break too.** No more stubbed markup and clicking around in the browser to make sure your JavaScript works in "real life."

Magic Carpet can:
  * render templates and partials in the context of any of your controllers
  * set the state of any of those controllers (params, instance variables, etc)
  * set local variables for the templates
  * pretty much do whatever you want with your controller's `render` method
  * append your templates to the DOM for you
  * be synchronous or asynchronous

It also doesn't monkeypatch anything, so nothing weird will start happening during your Ruby tests or development.

## Installation
Add this line to your application's Gemfile (probably in the `test` and `development` groups):

    gem "magic_carpet"

And then:

    $ bundle

Or install it yourself like this:

    $ gem install magic_carpet

## Setup
Add this to your `routes` file:
```ruby
# config/routes.rb
mount MagicCarpet::Engine => "/magic_carpet" if defined?(MagicCarpet)
```
### Pulling in the companion JavaScript
**Magic Carpet Js Dependencies:** [jQuery](https://jquery.org/) (only for `MagicCarpet.request`; also load order doesn't matter).

Anyway, you can throw this:
```javascript
//= require magic_carpet/magic_carpet
```
wherever the Asset Pipeline will pick up on it. If you're using [jasmine-rails](https://github.com/searls/jasmine-rails), you can put it at the top of any file in `spec/javascripts/helpers`. Or you can drop the [this file](https://github.com/crismali/magic_carpet/blob/master/app/assets/javascripts/magic_carpet/magic_carpet.js) into wherever your test framework of choice will pick up on it.
### Without the companion JavaScript
Just make a `get` request to `/magic_carpet` with whatever paremeters you need to set the proper state on the controller to prepare the template.
## Usage
Just request the template you want with the specified state on the controller like so:
```javascript
MagicCarpet.request({
  controller_name: "Wishes",
  action_name: "index",
  instance_variables: {
    wishes: [
      { id: 1, model: "Wish", text: "more wishes" },
      { id: 2, model: "Wish", text: "more genies" },
      { id: 3, model: "Wish", text: "more wishes and genies" }
    ]
  },
  locals: {
    truncate_text: "true"
  }
});
```
Here we're just grabbing the `index` template from the `WishesController` and making sure that the `@wishes` is set to a collection of `Wish` objects so the template doesn't blow up when it's rendered. We're also setting a local variable called `truncate_text` to `true`. `action_name` and `template` are completely interchangeable:
```javascript
MagicCarpet.request({
  controller_name: "Wishes",
  template: "plain"
});
```
Also note that Magic Carpet never runs any controller actions or hits any of your routes. It just munges options and sets state before calling `render`.

You can also grab partials:
```javascript
MagicCarpet.request({
  controller_name: "Wishes",
  partial: "some_partial"
});
```
You can also have partial rendered with a collection and even pass it the `as` option (sometimes the as option is necessary):
```javascript
MagicCarpet.request({
  controller_name: "Wishes",
  partial: "wish",
  collection: [
    { id: 1, model: "Wish", text: "wish text" },
    { id: 2, model: "Wish", text: "boring wish text" },
    { id: 3, model: "Wish", text: "last of the boring wish text" }
  ],
  as: "wish"
});
```
Magic Carpet can also handle associations:
```javascript
MagicCarpet.request({
  controller_name: "Wishes",
  action_name: "show",
  instance_variables: {
    wish: {
      id: 1,
      model: "Wish",
      text: "more wishes",
      user: { id: 3, name: "Al" }
    }
  }
});
```
The type coercion is recursive, so feel free to nest associations and data structures as deeply as you like (although, if you need to do too much of that, your template might be a bit too complicated).

You can also set the `params`, `flash`, `session`, and `cookies` the template sees like so:
```javascript
MagicCarpet.request({
  controller_name: "Wishes",
  template: "upon_a_start",
  flash: {
    success: "Woohoo!"
  },
  cookies: {
    user_id: 5
  },
  params: {
    wish_id: 10
  },
  session: {
    token: "TOP SECRET"
  }
});
```
### Synchronous and Async
By default `MagicCarpet.request` is synchronous, but you can make it asynchronous by changing `MagicCarpet.asyc` to `true`. `MagicCarpet.asyncComplete` will be `true` when the request is finished.
### Your Template and the DOM
By default, `MagicCarpet` appends a div with an id of `magic-carpet` to the body of the page and puts the requested template in there. If you'd rather have your template put somewhere else, just change `MagicCarpet.sandbox` to the html node that you want to contain the template.
### Clean Up
You can empty the div that MagicCarpet puts templates in by calling `MagicCarpet.emptySandbox()`.
### Caching Responses
Magic Carpet will cache responses so if you request the same template the same way a bunch of times it will skip unnecessary extra calls to the server. If you want to empty the cache for whatever reason, just set `MagicCarpet.cache` to an empty object.
### All Options
Here's a list of all the options you can pass `MagicCarpet.request`:
  * `controller_name`
  * `action_name`
  * `template`
  * `partial`
  * `locals`
  * `instance_variables`
  * `collection`
  * `as`
  * `params`
  * `session`
  * `flash`
  * `cookies`
  * `layout`

## Type Coercion
### Booleans and Nil
Booleans and `nil` can be coerced by simply sending a string of their name, ie `"true"`, `"false"`, and `"nil"`.
### "Models"
Models is in quotes above because the object doesn't necessarily need to be and ActiveRecord object or ActiveModel at all. Magic Carpet grabs the specified 'model' class and passes the rest of the hash into the model class's `new` method. Like this:
```javascript
// You send an object that looks like this:
{
  model: "Wish",
  id: 4,
  text: "howdy",
  some_other_attribute: "value"
}
```
And Magic Carpet essentially does this:
```ruby
Wish.new({
  id: 4,
  text: "howdy",
  some_other_attribute: "value"
})
```
`OpenStruct` is a good candidate when you need a stubbed object.
### Numbers
If you need a number to actually _be_ a number (ie not a `String`), just tell Magic Carpet:
```javascript
// any of these
{ number: "5.5" }
{ number: 5.5 }
{
  number: 5.5,
  integer: true
}
// or these
{
  number: 5.5,
  integer: false // doesn't matter what's here, if the integer key is present, you get an integer.
}
// or these
{
  number: 5.5,
  integer: "anything"
}
```
Without the `integer` option, it will coerce the type via `to_f`, with the integer option present it will use `to_i`.
### Dates, Times, and DateTimes
`Dates`, `Times`, and `DateTimes` will all be parsed according to there respsective `parse` methods. Just use `date`, `time`, or `datetime` as a key that points to a parsable string (`MagicCarpet.request` will `toString()` whatever you give it, so raw `Date` objects or `moment` objects are fine too).

`Times` also have a `utc` option you can pass them (it doesn't matter what the key points to, its presence will trigger the behavior). It just calls `utc` on the `Time` object.
```javascript
// any of these
{ date: "Sat Apr 12 2014 20:44:24 GMT-0500 (CDT)" }
{ datetime: "Sat Apr 12 2014 20:44:24 GMT-0500 (CDT)" }
{
  time: "Sat Apr 12 2014 20:44:24 GMT-0500 (CDT)",
  utc: true
}
// or these
{ date: new Date() }
{ datetime: new Date() }
{
  time: new Date(),
  utc: false
}
// or these
{ date: moment() }
{ datetime: moment() }
{
  time: moment(),
  utc: "anything"
}
```
## Errors
MagicCarpet will throw descriptive errors in the JavaScript and in your server logs if something breaks in your template, if you've attempted to render a template that doesn't exist, you've sent an unparseable date string, or if something else goes wrong. If you read the errors it should be easy to figure out what's wrong. If it's not, create a new issue here or make a pull request.
## Contributing
1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
