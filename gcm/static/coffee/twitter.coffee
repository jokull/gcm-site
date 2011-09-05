class window.Tweet extends Backbone.Model
  
  initialize: (options) ->
    if @has "text"
      tweet = @ify.hash (@get "text")
      tweet = @ify.at tweet
      tweet = @ify.link tweet
      @set ified: tweet
  
  ify: 
    link: (t) ->
      t.replace /(^|\s+)(https*\:\/\/\S+[^\.\s+])/g, (m, m1, link) ->
        m1 + "<a href=" + link + ">" + (if (link.length > 25) then link.substr(0, 24) + "..." else link) + "</a>"
  
    at: (t) ->
      t.replace /(^|\s+)\@([a-zA-Z0-9_]{1,15})/g, (m, m1, m2) ->
        m1 + "@<a href=\"http://twitter.com/" + m2 + "\">" + m2 + "</a>"
  
    hash: (t) ->
      t.replace /(^|\s+)\#([a-zA-Z0-9_]+)/g, (m, m1, m2) ->
        m1 + "#<a href=\"http://search.twitter.com/search?q=%23" + m2 + "\">" + m2 + "</a>"
  
  
class window.TweetView extends Backbone.View
  
  el: "#tweet"
  initialize: (options) ->
    @model.bind "change", @render
    @render()
  
  render: =>
    tpl = _.template ($ "#tpl-tweet").html()
    ($ @el).html (tpl @model.toJSON())
    return @
  
  