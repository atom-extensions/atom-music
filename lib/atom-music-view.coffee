{$, View} = require 'atom-space-pen-views'
playListView = require './atom-music-playlist-view'
module.exports =
class AtomMusicView extends View
  constructor: (serializedState) ->
    super()
    if serializedState?
      @isPlaying = serializedState.isPlaying
      @playList = serializedState.playList
      @playListCopy = serializedState.playListCopy
      @currentTrack = serializedState.currentTrack
      @shuffle = serializedState.shuffle
      @playTrackByItem @currentTrack
    else
      @isPlaying = false
      @playList = []
      @playListCopy = []
      @currentTrack = null
      @shuffle = false

  @content: ->
    @div class:'atom-music', =>
      @div class:'audio-controls-container', outlet:'container', =>
        @div class:'btn-group btn-group-sm', =>
          @button class:'btn icon icon-jump-left', click:'back15'
          @button class:'btn icon icon-playback-rewind', click:'prevTrack'
          @button class:'btn icon playback-button icon-playback-play', click:'togglePlayback'
          @button class:'btn icon icon-playback-fast-forward', click:'nextTrack'
          @button class:'btn icon icon-jump-right', click:'forward15'
        @div class:'btn-group btn-group-sm pull-right', =>
          @tag 'label', =>
            @tag 'input', style:'display: none;', type:'button', click:'toggleShuffle'
            @span 'Order', class:'btn shuffle-button icon icon-sync'
          @tag 'label', =>
            @tag 'input', style:'display: none;', type:'button', click:'showPlayList'
            @span 'Show Playlist', class:'btn icon icon-list-ordered',
          @tag 'label', =>
            @tag 'input', style:'display: none;', type:'button', click:'clearPlayList'
            @span 'Clear Playlist', class:'btn icon icon-trashcan',
          @tag 'label', =>
            @tag 'input', style:'display: none;', type:'file', multiple:true, accept:"audio/*", outlet:"musicFileSelectionInput"
            @span 'Open Music Files', class:'btn icon icon-file-directory',
        @div class:'inline-block playing-now-container', =>
          @span 'Now Playing : ', class:'highlight'
          @span 'Nothing to play', class:'highlight', outlet:'nowPlayingTitle'
          @div id:'ticker',outlet:'ticker'
      @div class:'atom-music-list-container'
      @tag 'audio', class:'audio-player', outlet:'audio_player', =>

  initialize: ->
    self = @
    @musicFileSelectionInput.on 'change', @filesBrowsed
    @audio_player.on 'play', ( ) =>
      $('.playback-button').removeClass('icon-playback-play').addClass('icon-playback-pause')
    @audio_player.on 'pause', ( ) =>
      $('.playback-button').removeClass('icon-playback-pause').addClass('icon-playback-play')
    @audio_player.on 'ended', @songEnded
    @container.on 'click', ( evt ) =>
      if 35 <= evt.offsetY <= 40 and @currentTrack?
        @ticker.context.style.width = evt.offsetX+"px"
        totalTime = @audio_player[0].duration
        factor = totalTime / @container.width()
        @audio_player[0].currentTime = evt.offsetX * factor

  show: ->
    @panel ?= atom.workspace.addBottomPanel(item:this)
    @panel.show()

  toggle:->
    if @panel?.isVisible()
      @hide()
    else
      @show()
      @pulsing()

  moveTicker: ->
    if @currentTrack?
      timeSpent = @audio_player[0].currentTime
      totalTime = @audio_player[0].duration
      percentCompleted = timeSpent / totalTime
      @ticker.context.style.width = percentCompleted * @container.width() + 'px'

  pulsing: ->
    setInterval ( ) =>
      $(@).addClass('pulse')
      @moveTicker()
      setTimeout ( ) =>
        $(@).removeClass('pulse')
      , 2000
    , 4000

  songEnded: ( e ) =>
    console.log "Changing track"
    @nextTrack()

  skip: ( seconds )->
    delta = @audio_player[0].currentTime + seconds
    if (delta < 0)
      @audio_player[0].currentTime = 0
    else if (delta > @audio_player[0].duration)
      @nextTrack()
    else
      @audio_player[0].currentTime += seconds

  forward15: ->
    @skip(15)

  back15: ->
    @skip(-15)

  nextTrack: ->
    player = @audio_player[0]
    if @currentTrack?
      currentTrackIndex = @playList.indexOf @currentTrack
      if currentTrackIndex == (@playList.length - 1)
        @shuffleList() if @shuffle
        currentTrackIndex = 0
      else
        currentTrackIndex += 1
      @playTrack currentTrackIndex
    # player.pause()

  prevTrack: ->
    player = @audio_player[0]
    if @currentTrack?
      currentTrackIndex = @playList.indexOf @currentTrack
      if currentTrackIndex == 0
        currentTrackIndex = 0
      else
        currentTrackIndex -= 1
      @playTrack currentTrackIndex

  playTrackByItem: (item) ->
    @shuffleList() if @shuffle
    @playTrack @playList.indexOf(item)

  playTrack: ( trackNum ) ->
    track = @playList[trackNum]
    player = @audio_player[0]
    if track?
      @currentTrack = track
      @nowPlayingTitle.html (track.name)
      player.pause()
      player.src = track.path
      player.load()
      player.play()

  stopTrack: ( trackNum ) ->
    track = @playList[trackNum]
    player = @audio_player[0]
    if track?
      @togglePlayback() if not player.paused
      @currentTrack = null
      @nowPlayingTitle.html ('Nothing to play')
      player.src = null

  filesBrowsed: ( e ) =>
    files = $(e.target)[0].files
    if files? and files.length > 0
      @playListHash = {}
      for f in @playList
        @playListHash[f.name] = 1
      for f in files
        if !@playListHash[f.name]?
          @playList.unshift { name:f.name, path:f.path }
      @playListCopy = @playList[...]

      @playTrack 0

  togglePlayback: ->
    player = @audio_player[0]
    if @currentTrack?
      if player.paused or player.currentTime == 0
        player.play()
        $('.playback-button').removeClass('icon-playback-play').addClass('icon-playback-pause')
      else
        player.pause()
        $('.playback-button').removeClass('icon-playback-pause').addClass('icon-playback-play')

  shuffleList: ->
    for i in [@playList.length..1]
      j = Math.floor Math.random() * i
      [@playList[i - 1], @playList[j]] = [@playList[j], @playList[i - 1]]

  toggleShuffle: ->
    @shuffle = !@shuffle
    if @shuffle
      $('.shuffle-button').text('Shuffle')
      @shuffleList()
    else
      $('.shuffle-button').text('Order')
      @playList = @playListCopy[...]

  showPlayList: ->
    new playListView @, @playListCopy

  clearPlayList: ->
    @stopTrack 0
    @playList = []
    @playListCopy = []

  hide: ->
    @panel?.hide()

  serialize: ->
    isPlaying: @isPlaying
    playList: @playList
    playListCopy: @playListCopy
    currentTrack: @currentTrack
    shuffle: @shuffle
