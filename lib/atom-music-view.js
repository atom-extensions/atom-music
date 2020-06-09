/** @babel */

/** @jsx etch.dom */

const etch = require("etch");
const AtomMusicSearchView = require("./atom-music-search-view");

class AtomMusicView {
	constructor(serializedState) {
		this.isPlaying = false;
		this.playList = [];
		this.playListCopy = [];
		this.currentTrack = null;
		this.shuffle = false;
		this.fromWindowChange = false;
		this.windowId = process.pid;

		if (serializedState) {
			this.isPlaying = serializedState.isPlaying;
			this.playList = serializedState.playList || [];
			this.playListCopy = serializedState.playListCopy || [];
			this.currentTrack = serializedState.currentTrack;
			this.shuffle = serializedState.shuffle;
		}

		etch.initialize(this);

		if (this.shuffle) {
			this.shuffle = false; // It will be switched back to true in toggleShuffle()
			this.toggleShuffle();
		}

		if (this.currentTrack) {
			if (this.isPlaying) {
				this.playTrack(this.currentTrack);
			} else {
				this.loadTrack(this.currentTrack);
			}
		}
	}

	onAudioPlay() {
		this.isPlaying = true;
		atom.config.set("atom-music.state.playerWindowId", this.windowId);
		atom.config.set("atom-music.state.playing", this.isPlaying);
		this.refs.playbackButton.classList.remove("icon-playback-play");
		this.refs.playbackButton.classList.add("icon-playback-pause");
		this.refs.container.classList.add("pulse");
		this.startTicker();
	}

	onAudioPause() {
		this.isPlaying = false;
		if (this.fromWindowChange) {
			this.fromWindowChange = false;
		} else {
			atom.config.set("atom-music.state.playing", false);
		}
		this.refs.playbackButton.classList.remove("icon-playback-pause");
		this.refs.playbackButton.classList.add("icon-playback-play");
		this.refs.container.classList.remove("pulse");
		this.stopTicker();
	}

	getTitle() { return "Music"; }

	getURI() { return "atom://atom-music"; }

	getDefaultLocation() { return "bottom"; }

	getAllowedLocations() { return ["bottom"]; }

	render() {
		return (
			<div className="atom-music">
				<div className="audio-controls-container" ref="container">
					<div className="btn-group btn-group-sm">
						<button className="btn icon icon-jump-left" on={{click: this.prevTrack}}></button>
						{(atom.config.get("atom-music.controls.skip") > 0) ? <button className="btn icon icon-playback-rewind" on={{click: this.rewind}}></button> : ""}
						<button className="btn icon playback-button icon-playback-play" on={{click: this.togglePlayback}} ref="playbackButton"></button>
						{(atom.config.get("atom-music.controls.skip") > 0) ? <button className="btn icon icon-playback-fast-forward" on={{click: this.forward}}></button> : ""}
						<button className="btn icon icon-jump-right" on={{click: this.nextTrack}}></button>
					</div>
					<div className="btn-group btn-group-sm pull-right">
						<button className="btn shuffle-button icon icon-sync" on={{click: this.toggleShuffle}} ref="shuffleButton">Ordered</button>
						<button className="btn icon icon-list-ordered" on={{click: this.searchPlayList}}>Search Playlist</button>
						<button className="btn icon icon-trashcan" on={{click: this.clearPlayList}}>Clear Playlist</button>
						<label className="btn icon icon-file-directory" tabIndex="0" on={{keypress: this.clickOnSpaceBar}}>
							<input attributes={{style:"display: none;", type:"file", multiple:true, accept:"audio/*"}} on={{change: this.onFilesAdded}} />
							Open Music Files
						</label>
					</div>
					<div className="inline-block playing-now-container">
						<span className="highlight">Now Playing : </span>
						<span className="highlight" ref="nowPlayingTitle">Nothing to play</span>
						<div className="ticker" on={{click: this.onTickerClicked}}>
							<div ref="ticker"></div>
						</div>
					</div>
				</div>
				<div className="atom-music-list-container">
					<ul className="list-group" ref="musicList">
						{
							this.playListCopy.map(track => (
								<li
									className={(this.currentTrack && track.name === this.currentTrack.name) ? "selected" : ""}
									attributes={{tabindex: 0, "data-name": track.name}}
									on={{click: () => {this.playTrack(track);}, keypress: this.clickOnSpaceBar}}>{track.name}</li>
							))
						}
					</ul>
				</div>
				<audio className="audio-player" on={{play: this.onAudioPlay, pause: this.onAudioPause, ended: this.onAudioEnded}} ref="audio_player"></audio>
			</div>
		);
	}

	clickOnSpaceBar(e) {
		if (e.keyCode === 32) {
			e.preventDefault();
			e.target.click();
		}
	}

	update() {
		return etch.update(this);
	}

	destroy() {
		if (this.searchView) {
			this.searchView.destroy();
		}
		this.element.remove();
		return etch.destroy(this);
	}

	toggle() {
		atom.workspace.toggle(this.getURI());
	}

	onTickerClicked(e) {
		if (this.currentTrack) {
			this.refs.ticker.style.width = e.offsetX + "px";
			const totalTime = this.refs.audio_player.duration;
			const factor = totalTime / this.refs.container.offsetWidth;
			this.refs.audio_player.currentTime = e.offsetX * factor;
		}
	}

	stopTicker() {
		cancelAnimationFrame(this.refs.tickerTimeout);
	}

	startTicker() {
		this.stopTicker();
		if (this.currentTrack) {
			this.moveTicker();
		}
	}

	moveTicker() {
		if (this.currentTrack) {
			const timeSpent = this.refs.audio_player.currentTime;
			const totalTime = this.refs.audio_player.duration;
			const percentCompleted = timeSpent / totalTime;
			this.refs.ticker.style.width = (percentCompleted * this.refs.container.offsetWidth) + "px";
			this.refs.tickerTimeout = requestAnimationFrame(() => this.moveTicker());
		}
	}

	onAudioEnded() {
		this.nextTrack();
	}

	skip(seconds){
		const delta = this.refs.audio_player.currentTime + seconds;
		if (delta < 0) {
			this.refs.audio_player.currentTime = 0;
		} else if (delta > this.refs.audio_player.duration) {
			this.nextTrack();
		} else {
			this.refs.audio_player.currentTime += seconds;
		}
	}

	forward() {
		this.skip(
			atom.config.get("atom-music.controls.skip")
		);
	}

	rewind() {
		this.skip(
			-atom.config.get("atom-music.controls.skip")
		);
	}

	getTrackIndex(track) {
		return this.playList.findIndex(t => track.name === t.name);
	}

	nextTrack() {
		if (this.currentTrack) {
			let currentTrackIndex = this.getTrackIndex(this.currentTrack);
			if ((currentTrackIndex === -1) || (currentTrackIndex === (this.playList.length - 1))) {
				if (this.shuffle) { this.shuffleList(); }
				currentTrackIndex = 0;
			} else {
				currentTrackIndex += 1;
			}
			this.playTrack(this.playList[currentTrackIndex]);
		}
	}

	prevTrack() {
		if (this.currentTrack) {
			let currentTrackIndex = this.getTrackIndex(this.currentTrack);
			if ((currentTrackIndex === -1) || (currentTrackIndex === 0)) {
				currentTrackIndex = this.playList.length - 1;
			} else {
				currentTrackIndex -= 1;
			}
			this.playTrack(this.playList[currentTrackIndex]);
		}
	}

	loadTrack(track) {
		if (track) {
			this.currentTrack = track;
			this.selectCurrentTrack();
			this.refs.nowPlayingTitle.textContent = track.name;
			this.refs.audio_player.pause();
			this.refs.audio_player.src = track.path;
			this.refs.audio_player.load();
		}
	}

	playTrack(track) {
		if (track) {
			this.loadTrack(track);
			this.togglePlayback();
		}
	}

	onFilesAdded(e) {
		const { files } = e.target;
		if (files && files.length > 0) {
			this.playListHash = {};
			for (const t of this.playListCopy) {
				this.playListHash[t.name] = true;
			}
			for (const f of files) {
				if (!this.playListHash[f.name]) {
					try {
						this.playListCopy.unshift({ name:f.name, path:f.path });
					} catch (error) {
						this.playListCopy = [ {name:f.name, path:f.path} ];
					}
				}
			}
			this.playList = this.playListCopy.slice();

			this.update();
			if (this.shuffle) { this.shuffleList(); }
			this.playTrack(this.playList[this.getTrackIndex({name: files[0].name})]);
		}
	}

	selectCurrentTrack() {
		for (const selected of this.refs.musicList.querySelectorAll(".selected")) {
			selected.classList.remove("selected");
		}
		if (this.currentTrack) {
			for (const li of this.refs.musicList.querySelectorAll("li")) {
				if (li.dataset.name === this.currentTrack.name) {
					li.classList.add("selected");
				}
			}
		}
	}

	togglePlayback() {
		if (this.currentTrack) {
			if (this.refs.audio_player.paused || (this.refs.audio_player.currentTime === 0)) {
				this.refs.audio_player.play();
			} else {
				this.refs.audio_player.pause();
			}
		}
	}

	shuffleList() {
		if (this.playList.length <= 1) { return; }

		for (let i = this.playList.length - 1; i > 0; i--) {
			const j = Math.floor(Math.random() * (i + 1));
			[this.playList[i], this.playList[j]] = [this.playList[j], this.playList[i]];
		}
	}

	toggleShuffle() {
		this.shuffle = !this.shuffle;
		if (this.shuffle) {
			this.refs.shuffleButton.textContent = "Shuffled";
			this.shuffleList();
		} else {
			this.refs.shuffleButton.textContent = "Ordered";
			this.playList = this.playListCopy.slice();
		}
	}

	searchPlayList() {
		const items = this.playListCopy.slice();
		if (this.searchView) {
			this.searchView.update(items);
		} else {
			this.searchView = new AtomMusicSearchView(this, items);
		}
		this.searchView.show();
	}

	clearPlayList() {
		if (!this.refs.audio_player.paused) { this.refs.audio_player.pause(); }
		this.refs.audio_player.src = "";
		this.stopTicker();
		this.refs.ticker.style.width = "0px";
		this.isPlaying = false;
		this.currentTrack = null;
		this.playList = [];
		this.playListCopy = [];
		this.update();
		this.refs.nowPlayingTitle.textContent = "Nothing to play";
		this.refs.playbackButton.classList.remove("icon-playback-pause");
		this.refs.playbackButton.classList.add("icon-playback-play");
		this.refs.container.classList.remove("pulse");
	}

	serialize() {
		return {
			isPlaying: false,
			playList: this.playList,
			playListCopy: this.playListCopy,
			currentTrack: this.currentTrack,
			shuffle: this.shuffle
		};
	}
}
module.exports = AtomMusicView;
