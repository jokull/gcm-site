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



class FriendView extends Backbone.View
  
  tagName: "li"
  
  initialize: (options) ->
    @model.bind "change", @render
  
  render: =>
    tpl = _.template ($ "#tpl-friend").html()
    ($ @el).html (tpl @model.toJSON())
    return @
  
  initialize: (options) ->
    @render()


class Friend extends Backbone.Model

class FriendsView extends Backbone.View
  
  el: "ol.friends"
  
  initialize: (options) ->
    @collection.bind "add", @add
    
  add: (model) =>
    model.view = new FriendView {model: model}
    ($ @el).append model.view.render().el
    
   
class Friends extends Backbone.Collection
  model: Friend
  
class Person extends Backbone.Model
  
class PersonView extends Backbone.View
  
  el: ".person"
  
  initialize: (options) ->
    @model.bind "change", @render
    @render()
  
  render: =>
    tpl = _.template ($ "#tpl-person").html()
    ($ @el).html (tpl @model.toJSON())

class LoginView extends Backbone.View
  
  el: ".signup"
  
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

window.fbAsyncInit = ->
  FB.Canvas.setSize()
  GCM.auth = new FacebookAuth 
    app_id: GCM.graph_id
    connected: GCM.connected_callback
    backend_url: GCM.routes.connect
  GCM.views.login = new LoginView
  return




    