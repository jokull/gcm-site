class window.TumblrPost extends Backbone.Model
  
class window.Tumblr extends Backbone.Collection
  model: TumblrPost
  
class window.TumblrView extends Backbone.View
  el: "#tumblr"
  
  initialize: (options) ->
    @collection.bind "add", @add
    
  add: (model) =>
    model.view = new TumblrPostView model: model
    ($ @el).append model.view.render().el
  
class window.TumblrPostView extends Backbone.View
  
  initialize: (options) ->
    @model.bind "change", @render
    @render()
  
  render: =>
    tpl = _.template ($ "#tpl-tumblr-post").html()
    ($ @el).html (tpl @model.toJSON())
    return @
  
  