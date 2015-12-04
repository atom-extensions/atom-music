AtomMusicView = require './atom-music-view'
{CompositeDisposable} = require 'atom'

module.exports = AtomMusic =
  atomMusicView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @atomMusicView = new AtomMusicView(state.atomMusicViewState)
    # Register command that toggles this view
    atom.commands.add 'atom-workspace', 'atom-music:toggle': => @atomMusicView.toggle()

  deactivate: ->
    @atomMusicView.destroy()

  serialize: ->
    atomMusicViewState: @atomMusicView.serialize()
