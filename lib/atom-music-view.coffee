{$, View} = require 'atom-space-pen-views'
playListView = require './atom-music-playlist-view'
module.exports =
class AtomMusicView extends View

  constructor: (serializedState) ->
    super()
    @isPlaying = false
    @playList = []
    @playListCopy = []
    @currentTrack = null
    @shuffle = false
    @fromWindowChange = false
    @windowId = process.pid

    if serializedState?
      @isPlaying = serializedState.isPlaying
      @playList = serializedState.playList or []
      @playListCopy = serializedState.playListCopy or []
      @currentTrack = serializedState.currentTrack
      @shuffle = serializedState.shuffle
      @updateMusicList()
      if @shuffle
        @shuffle = false # It will be switched back to true in toggleShuffle()
        @toggleShuffle()
      if @currentTrack?
        if @isPlaying
          @playTrack @currentTrack
        else
          @loadTrack @currentTrack

  getTitle: -> 'Music'

  getURI: -> 'atom://atom-music'

  getDefaultLocation: -> 'bottom'

  getAllowedLocations: -> ['bottom']

  @content: ->
    @div class:'atom-music', =>
      @div class:'audio-controls-container', outlet:'container', =>
        @div class:'btn-group btn-group-sm', =>
          @button class:'btn icon icon-jump-left', click:'prevTrack'
          @button class:'btn icon icon-playback-rewind', click:'back15'
          @button class:'btn icon playback-button icon-playback-play', click:'togglePlayback', outlet:'playbackButton'
          @button class:'btn icon icon-playback-fast-forward', click:'forward15'
          @button class:'btn icon icon-jump-right', click:'nextTrack'
        @div class:'btn-group btn-group-sm pull-right', =>
          @button 'Ordered', class:'btn shuffle-button icon icon-sync', click:'toggleShuffle', outlet:'shuffleButton'
          @button 'Search Playlist', class:'btn icon icon-list-ordered', click:'showPlayList'
          @button 'Clear Playlist', class:'btn icon icon-trashcan', click:'clearPlayList'
          @label 'Open Music Files', class:'btn icon icon-file-directory', tabIndex: 0, outlet:'openButton', =>
            @input style:'display: none;', type:'file', multiple:true, accept:'audio/*', outlet:'musicFileSelectionInput'
        @div class:'inline-block playing-now-container', =>
          @span 'Now Playing : ', class:'highlight'
          @span 'Nothing to play', class:'highlight', outlet:'nowPlayingTitle'
          @div class:'ticker', click:'changeTicker', =>
            @div outlet:'ticker'
      @div class:'atom-music-list-container', =>
        @ul class:'list-group', outlet:'musicList'
      @audio class:'audio-player', outlet:'audio_player'

  initialize: ->
    @musicFileSelectionInput.on 'change', @filesBrowsed
    @audio_player.on 'play', () =>
      @isPlaying = true
      atom.config.set 'atom-music.state.playerWindowId', @windowId
      atom.config.set "atom-music.state.playing", @isPlaying
      @playbackButton.removeClass('icon-playback-play').addClass('icon-playback-pause')
      @container.addClass('pulse')
      @startTicker()
    @audio_player.on 'pause', () =>
      @isPlaying = false
      if @fromWindowChange
        @fromWindowChange = false
      else
        atom.config.set "atom-music.state.playing", false
      @playbackButton.removeClass('icon-playback-pause').addClass('icon-playback-play')
      @container.removeClass('pulse')
      @stopTicker()
    @audio_player.on 'ended', @songEnded
    @openButton.keypress (e) =>
      if e.keyCode is 32
        e.preventDefault()
        @openButton.click()

  destroy: ->
    @playlistView?.destroy()
    @element.remove()

  toggle:->
    atom.workspace.toggle @getURI()

  changeTicker: (e) ->
    if @currentTrack?
      @ticker.width e.offsetX
      totalTime = @audio_player[0].duration
      factor = totalTime / @container.width()
      @audio_player[0].currentTime = e.offsetX * factor

  stopTicker: ->
    cancelAnimationFrame(@tickerTimeout)

  startTicker: ->
    @stopTicker()
    if @currentTrack?
      @moveTicker()

  moveTicker: ->
    if @currentTrack?
      timeSpent = @audio_player[0].currentTime
      totalTime = @audio_player[0].duration
      percentCompleted = timeSpent / totalTime
      @ticker.width percentCompleted * @container.width()
      @tickerTimeout = requestAnimationFrame => @moveTicker()

  songEnded: (e) =>
    @nextTrack()

  skip: (seconds)->
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

  getTrackIndex: (track) ->
    @playList.findIndex (t) -> track.name == t.name

  nextTrack: ->
    if @currentTrack?
      currentTrackIndex = @getTrackIndex @currentTrack
      if currentTrackIndex == -1 or currentTrackIndex == (@playList.length - 1)
        @shuffleList() if @shuffle
        currentTrackIndex = 0
      else
        currentTrackIndex += 1
      @playTrack @playList[currentTrackIndex]

  prevTrack: ->
    if @currentTrack?
      currentTrackIndex = @getTrackIndex @currentTrack
      if currentTrackIndex == -1 or currentTrackIndex == 0
        currentTrackIndex = @playList.length - 1
      else
        currentTrackIndex -= 1
      @playTrack @playList[currentTrackIndex]

  loadTrack: (track) ->
    if track?
      @currentTrack = track
      @selectCurrentTrack()
      @nowPlayingTitle.html (track.name)
      @audio_player[0].pause()
      @audio_player[0].src = track.path
      @audio_player[0].load()

  playTrack: (track) ->
    if track?
      @loadTrack(track)
      @togglePlayback()

  filesBrowsed: (e) =>
    files = e.target.files
    if files? and files.length > 0
      @playListHash = {}
      for f in @playListCopy or []
        @playListHash[f.name] = 1
      for f in files
        if !@playListHash[f.name]?
          try
            @playListCopy.unshift { name:f.name, path:f.path }
          catch e
            @playListCopy = [ name:f.name, path:f.path ]
      @playList = @playListCopy[...]

      @updateMusicList()
      @shuffleList() if @shuffle
      @playTrack @playList[@getTrackIndex name: files[0].name]

  selectCurrentTrack: ->
    @musicList.find(".selected").removeClass("selected")
    if @currentTrack?
      for li in @musicList.find("li")
        $(li).addClass("selected") if $(li).data().name is @currentTrack.name

  updateMusicList: ->
    @musicList.html ""
    for track in @playListCopy
      @musicList.append @createMusicListItem track

  createMusicListItem: (track) ->
    $ "<li tabindex='0' />"
      .data name: track.name
      .text track.name
      .toggleClass "selected", @currentTrack? and track.name is @currentTrack.name
      .click => @playTrack track
      .keypress (e) ->
        if e.keyCode is 32
          e.preventDefault()
          $(this).click()

  togglePlayback: ->
    if @currentTrack?
      if @audio_player[0].paused or @audio_player[0].currentTime == 0
        @audio_player[0].play()
      else
        @audio_player[0].pause()

  shuffleList: ->
    return unless @playList.length > 1
    for i in [@playList.length..1]
      j = Math.floor Math.random() * i
      [@playList[i - 1], @playList[j]] = [@playList[j], @playList[i - 1]]

  toggleShuffle: ->
    @shuffle = !@shuffle
    if @shuffle
      @shuffleButton.text('Shuffled')
      @shuffleList()
    else
      @shuffleButton.text('Ordered')
      @playList = @playListCopy[...]

  showPlayList: ->
    @playlistView = new playListView @, @playListCopy[...]

  clearPlayList: ->
    @audio_player[0].pause() unless @audio_player[0].paused
    @audio_player[0].src = ""
    @stopTicker()
    @ticker.width 0
    @isPlaying = false
    @currentTrack = null
    @playList = []
    @playListCopy = []
    @updateMusicList()
    @nowPlayingTitle.html ('Nothing to play')
    @playbackButton.removeClass('icon-playback-pause').addClass('icon-playback-play')
    @container.removeClass('pulse')

  serialize: ->
    isPlaying: false
    playList: @playList
    playListCopy: @playListCopy
    currentTrack: @currentTrack
    shuffle: @shuffle
