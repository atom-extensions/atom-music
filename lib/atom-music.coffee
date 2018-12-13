AtomMusicView = require './atom-music-view'
{CompositeDisposable} = require 'atom'

module.exports = AtomMusic =
  atomMusicView: null
  modalPanel: null
  subscriptions: new CompositeDisposable

  config:
    state:
      title: 'Multi-Window State'
      type: 'object'
      collapsed: true
      order: -1
      description: 'Changing these values manually may prevent atom-music from working properly.'
      properties:
        playing:
          title: 'Playing'
          type: 'boolean'
          order: 1
          default: false
        playerWindowId:
          title: 'Window ID'
          type: 'integer'
          order: 2
          default: 0

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

    @subscriptions.add atom.config.onDidChange 'atom-music.state.playing', (playing) =>
      windowId = atom.config.get 'atom-music.state.playerWindowId'
      console.log "p", windowId, @atomMusicView.windowId, playing.newValue, @atomMusicView.isPlaying
      if windowId is @atomMusicView.windowId
        @atomMusicView.togglePlayback() if playing.newValue isnt @atomMusicView.isPlaying
    @subscriptions.add atom.config.onDidChange 'atom-music.state.playerWindowId', (windowId) =>
      console.log "w", windowId.newValue, @atomMusicView.windowId, @atomMusicView.isPlaying
      if windowId.newValue isnt @atomMusicView.windowId
        @atomMusicView.fromWindowChange = true
        @atomMusicView.togglePlayback() if @atomMusicView.isPlaying

  deactivate: ->
    @atomMusicView?.destroy()
    @subscriptions?.dispose()

  deserializeAtomMusicView: (state) ->
    new AtomMusicView(state.atomMusicViewState)

  serialize: ->
    deserializer: 'atom-music/AtomMusicView'
    atomMusicViewState: @atomMusicView.serialize()
