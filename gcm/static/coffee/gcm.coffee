if typeof window.console == "undefined" or typeof window.console.log == "undefined"
  window.console = log: ->

window.GCM.collections = {}
window.GCM.models = {}
window.GCM.views = {}

$ ->
  
  $.fn.placeholder = ->
    jQuery.each @, ->
      ($ @).focus(->
        input = ($ @)
        if input.val() == input.attr "placeholder"
          input.val ""
          input.removeClass "placeholder"
      ).blur(->
        input = $(@)
        if input.val() == "" or input.val() == input.attr "placeholder"
          input.addClass "placeholder"
          input.val input.attr "placeholder"
      ).blur().parents("form").submit ->
        $(@).find("[placeholder]").each ->
          input = $(@)
          input.val "" if input.val() == input.attr "placeholder"
  
  ($ ".ie [placeholder]").placeholder()
  
  $.ajax
    url: 'http://api.tumblr.com/v2/blog/meistaramanudur.tumblr.com/posts/json?api_key=' + GCM.tumblr_id
    dataType: "jsonp"
    jsonp: "jsonp"
    success: (data, status) =>
      GCM.collections.tumblr = new Tumblr
      GCM.views.tumblr = new TumblrView collection: GCM.collections.tumblr
      GCM.collections.tumblr.add data.response.posts[0]
  
  $.ajax
    url: 'https://api.instagram.com/v1/tags/meistaram/media/recent?count=5&client_id=' + GCM.instagram_id
    dataType: "jsonp"
    success: (data, status) =>
      GCM.collections.instagram = new Instagram
      GCM.views.instagram = new InstagramView collection: GCM.collections.instagram
      GCM.collections.instagram.add data.data
  
  $.ajax
    url: 'http://api.twitter.com/1/users/show.json?screen_name=meistaramanudur&include_entities=true'
    dataType: "jsonp"
    success: (data, status) =>
      GCM.models.tweet = new Tweet data.status
      GCM.views.tweet = new TweetView model: GCM.models.tweet


class FriendView extends Backbone.View
  
  tagName: "li"
  className: "one-third column"
  
  initialize: (options) ->
    @model.bind "change", @render
    @render()
  
  render: =>
    tpl = _.template ($ "#tpl-friend").html()
    ($ @el).html (tpl @model.toJSON())
    return @


class Friend extends Backbone.Model

class FriendsView extends Backbone.View
  
  el: "ol.friends"
  
  initialize: (options) ->
    ($ @el).html ""
    @collection.bind "add", @add
    
  add: (model) =>
    model.view = new FriendView {model: model}
    ($ @el).append model.view.render().el
    
   
class Friends extends Backbone.Collection
  model: Friend
  
class Person extends Backbone.Model
  
class PersonView extends Backbone.View
  
  TIMEOUT_MS: 200
  MIN_LENGTH: 2
  
  el: ".person"
  
  events:
    "blur :input": "submit"
    "keydown :input": "keydown"
  
  initialize: (options) ->
    @model.bind "change", @render
    @render()
  
  flash: (message) =>
    $el = (@$ ".help_text").hide()
    $el.html message
    $el.slideDown "slow", =>
      setTimeout(1500, -> $el.fadeOut "fast")
  
  render: =>
    tpl = _.template ($ "#tpl-person").html()
    ($ @el).html (tpl @model.toJSON())
    _.each (@$ "input"), (el) =>
      name = (($ el).attr "name")
      value = @model.attributes[name]
      ($ el).val value if value
  
  blur: (e) =>
    @submit(e)
    
  submit: (e) =>
    url = (@$ "form").attr "action"
    $.post url, (@$ ":input").serialize(), (data, status) =>
      if data.errors
        @flash (_.values data.errors).join('<br>')
      else
        GCM.models.person.set data
        @flash "Vistað"
  
  keydown: (e) =>
    clearTimeout @typing
    switch e.keyCode
      when ($.ui.keyCode.ENTER or $.ui.keyCode.NUMPAD_ENTER)
        e.preventDefault()
        @submit()
    

class LoginView extends Backbone.View
  
  el: "#signup .signup"
  
  events: 
    "click a.login": "login"
    
  initialize: (options) ->
    GCM.auth.bind "awaiting", =>
      @render()
      ($ @el).show()
    GCM.auth.bind "connected", =>
      # ($ @el).hide()
    GCM.auth.bind "disallowed", =>
  
  login: (e) =>
    e.preventDefault()
    FB.login ->

GCM.connected_callback = (response) ->
  
  GCM.collections.friends = new Friends
  GCM.views.friends = new FriendsView collection: GCM.collections.friends
  GCM.collections.friends.add response.friends
  GCM.models.person = new Person response
  GCM.views.person = new PersonView model: GCM.models.person
  GCM.collections.friends.add GCM.models.person

window.fbAsyncInit = ->
  FB.Canvas.setSize()
  GCM.auth = new FacebookAuth 
    app_id: GCM.graph_id
    connected: GCM.connected_callback
    backend_url: GCM.routes.connect
  GCM.views.login = new LoginView
  return