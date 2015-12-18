{$, View} = require 'atom-space-pen-views'

module.exports =
class AtomMusicView extends View
  isPlaying: false
  playList: []
  currentTrack: null
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
            @tag 'input', style:'display: none;', type:'file', multiple:true, accept:"audio/mp3", outlet:"musicFileSelectionInput"
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

  filesBrowsed: ( e ) =>
    files = $(e.target)[0].files
    if files? and files.length > 0
      @playList = []
      for f in files
        @playList.push { name:f.name, path:f.path }

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

  hide: ->
    @panel?.hide()
