class window.InstagramPost extends Backbone.Model
  
class window.Instagram extends Backbone.Collection
  model: InstagramPost
  
class window.InstagramView extends Backbone.View
  el: "#instagram"
  
  initialize: (options) ->
    @collection.bind "add", @add
    
  add: (model) =>
    model.view = new InstagramPostView model: model
    ($ @el).append model.view.render().el
  
class window.InstagramPostView extends Backbone.View
  
  className: "post"
  initialize: (options) ->
    @model.bind "change", @render
    @render()
  
  render: =>
    tpl = _.template ($ "#tpl-instagram-post").html()
    ($ @el).html (tpl @model.toJSON())
    return @
  
  