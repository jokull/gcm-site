class window.TumblrPost extends Backbone.Model
  
class window.Tumblr extends Backbone.Collection
  model: TumblrPost
  
class window.TumblrPostView extends Backbone.View
  
  className: "tumblr-post"

  initialize: (options) ->
    @model.bind "change", @render
  
  render: =>
    tpl = _.template ($ "#tpl-tumblr-post").html()
    ($ @el).html (tpl @model.toJSON())
    return @
  
  
class window.TumblrView extends Backbone.View
  el: "#tumblr"
  
  initialize: (options) ->
    @collection.bind "add", @add
    
  add: (model) =>
    model.view = new TumblrPostView model: model
    model.view.render()
    ($ @el).append model.view.el
  