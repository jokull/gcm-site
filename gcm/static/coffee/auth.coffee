
class window.FacebookAuth extends Backbone.View
  
  constructor: (options) -> 
    @connected = options.connected
    @backend_url = options.backend_url
    FB.init 
      appId: options.app_id
      status: false
      logging: true
      cookie: false
      xfbml: true
    FB.getLoginStatus @status
  
  persist: (session) =>
    if session
      @trigger "connected"
      $.post @backend_url, session, @connected
    else
      @trigger "disallowed"
  
  status: (response) =>
    if response.status == "connected"
      @persist response.session
    else
      @trigger "awaiting"
      FB.Event.subscribe "auth.sessionChange", (response) =>
        @persist response.session
