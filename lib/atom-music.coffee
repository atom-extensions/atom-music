AtomMusicView = require './atom-music-view'
{CompositeDisposable} = require 'atom'
configSchema = require '../config.json'

module.exports = AtomMusic =
  atomMusicView: null
  modalPanel: null
  subscriptions: new CompositeDisposable
  config: configSchema

  activate: (state) ->
    @atomMusicView = new AtomMusicView(state.atomMusicViewState)
    @subscriptions.add atom.workspace.addOpener (uri) =>
      return @atomMusicView if uri == @atomMusicView.getURI()

    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-music:toggle': => @atomMusicView.toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-music:play-pause': => @atomMusicView.togglePlayback()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-music:toggle-shuffle': => @atomMusicView.toggleShuffle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-music:show-playlist': => @atomMusicView.showPlayList()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-music:forward-15s': => @atomMusicView.forward15()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-music:backward-15s': => @atomMusicView.back15()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-music:next-track': => @atomMusicView.nextTrack()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-music:previous-track': => @atomMusicView.prevTrack()

    if not atom.config.get 'atom-music.features.multiWindowSupport'
      @subscriptions.add atom.config.onDidChange 'atom-music.state.playing', (playing) =>
        mainWindowId = atom.config.get 'atom-music.state.playerWindowId'
        if atom.config.get 'atom-music.features.logging'
          console.log "Playing state changed", mainWindowId, @atomMusicView.windowId, playing.newValue, @atomMusicView.isPlaying
        if mainWindowId is @atomMusicView.windowId or mainWindowId is 0
          @atomMusicView.togglePlayback() if playing.newValue isnt @atomMusicView.isPlaying
      @subscriptions.add atom.config.onDidChange 'atom-music.state.playerWindowId', (windowId) =>
        if atom.config.get 'atom-music.features.logging'
          console.log "Window ID changed", windowId.newValue, @atomMusicView.windowId, @atomMusicView.isPlaying
        if windowId.newValue isnt @atomMusicView.windowId
          @atomMusicView.fromWindowChange = true
          @atomMusicView.togglePlayback() if @atomMusicView.isPlaying

  deactivate: ->
    windowId = atom.config.get 'atom-music.state.playerWindowId'
    if windowId is @atomMusicView.windowId
      atom.config.set 'atom-music.state.playerWindowId', 0
      atom.config.set 'atom-music.state.playing', false
    @atomMusicView?.destroy()
    @subscriptions?.dispose()

  deserializeAtomMusicView: (state) ->
    new AtomMusicView(state.atomMusicViewState)

  serialize: ->
    deserializer: 'atom-music/AtomMusicView'
    atomMusicViewState: @atomMusicView.serialize()
