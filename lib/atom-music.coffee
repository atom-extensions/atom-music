AtomMusicView = require './atom-music-view'
{CompositeDisposable} = require 'atom'

module.exports = AtomMusic =
  atomMusicView: null
  modalPanel: null
  subscriptions: new CompositeDisposable

  activate: (state) ->
    @atomMusicView = new AtomMusicView(state.atomMusicViewState)

    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-music:toggle': => @atomMusicView.toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-music:play-pause': => @atomMusicView.togglePlayback()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-music:toggle-shuffle': => @atomMusicView.toggleShuffle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-music:show-playlist': => @atomMusicView.showPlayList()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-music:forward-15s': => @atomMusicView.forward15()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-music:backward-15s': => @atomMusicView.back15()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-music:next-track': => @atomMusicView.nextTrack()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-music:previous-track': => @atomMusicView.prevTrack()

  deactivate: ->
    @atomMusicView?.destroy()
    @subscriptions?.dispose()

  serialize: ->
    atomMusicViewState: @atomMusicView.serialize()
