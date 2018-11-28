{View, SelectListView} = require 'atom-space-pen-views'

class PlayListView extends SelectListView
  initialize: (@player, @items) ->
    super()
    @setItems @items
    @panel ?= atom.workspace.addModalPanel item: @, autoFocus: true
    @panel.show()
    @focusFilterEditor()

  destroy: ->
    @panel?.destroy()

  viewForItem: (track) ->
    "<li>#{track.name}</li>"

  confirmed: (track) ->
    @player.playTrack(track)
    @panel.destroy()

  cancelled: ->
    @panel.destroy()

  getFilterKey: ->
    "name"
module.exports = PlayListView
