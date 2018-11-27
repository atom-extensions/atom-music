{View, SelectListView} = require 'atom-space-pen-views'

class PlayListView extends SelectListView
  initialize: (@player, @items) ->
    super()
    @setItems @items
    @panel ?= atom.workspace.addModalPanel item:@
    @panel.show()
    @focusFilterEditor()

  viewForItem: (track)->
    "<li>&nbsp; &nbsp; #{track.name}</li>"

  confirmed: (track)->
    @player.playTrackByItem(track)
    @parent().remove()

  cancelled: ->
    @parent().remove()

  getFilterKey: ->
    "name"
module.exports = PlayListView
