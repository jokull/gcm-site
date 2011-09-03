class window.Tweet extends Backbone.Model
  
class window.TweetView extends Backbone.View
  
  el: "#tweet"
  initialize: (options) ->
    @model.bind "change", @render
    @render()
  
  render: =>
    tpl = _.template ($ "#tpl-tweet").html()
    ($ @el).html (tpl @model.toJSON())
    return @
  
  