const AtomMusicView = require("./atom-music-view");
const {CompositeDisposable} = require("atom");
const configSchema = require("../config.json");

const AtomMusic = {
	atomMusicView: null,
	modalPanel: null,
	subscriptions: new CompositeDisposable,
	config: configSchema,

	activate(state) {
		if (!this.atomMusicView) {
			this.atomMusicView = new AtomMusicView(state.atomMusicViewState);
		}
		this.subscriptions.add(atom.workspace.addOpener(uri => {
			if (uri === this.atomMusicView.getURI()) { return this.atomMusicView; }
		}));

		// Register commands
		this.subscriptions.add(atom.commands.add("atom-workspace", {
			"atom-music:toggle": () => this.atomMusicView.toggle(),
			"atom-music:play-pause": () => this.atomMusicView.togglePlayback(),
			"atom-music:toggle-shuffle": () => this.atomMusicView.toggleShuffle(),
			"atom-music:search-playlist": () => this.atomMusicView.searchPlayList(),
			"atom-music:forward": () => this.atomMusicView.forward(),
			"atom-music:rewind": () => this.atomMusicView.rewind(),
			"atom-music:next-track": () => this.atomMusicView.nextTrack(),
			"atom-music:previous-track": () => this.atomMusicView.prevTrack(),
		}));

		// Register configuration change events
		if (!atom.config.get("atom-music.features.multiWindowSupport")) {
			this.subscriptions.add(atom.config.onDidChange("atom-music.state.playing", playing => {
				const mainWindowId = atom.config.get("atom-music.state.playerWindowId");
				if (atom.config.get("atom-music.features.logging")) {
					console.log("Playing state changed", mainWindowId, this.atomMusicView.windowId, playing.newValue, this.atomMusicView.isPlaying);
				}
				if ((mainWindowId === this.atomMusicView.windowId) || (mainWindowId === 0)) {
					if (playing.newValue !== this.atomMusicView.isPlaying) { this.atomMusicView.togglePlayback(); }
				}
			})
			);
			this.subscriptions.add(atom.config.onDidChange("atom-music.state.playerWindowId", windowId => {
				if (atom.config.get("atom-music.features.logging")) {
					console.log("Window ID changed", windowId.newValue, this.atomMusicView.windowId, this.atomMusicView.isPlaying);
				}
				if (windowId.newValue !== this.atomMusicView.windowId) {
					this.atomMusicView.fromWindowChange = true;
					if (this.atomMusicView.isPlaying) { this.atomMusicView.togglePlayback(); }
				}
			})
			);
		}
		this.subscriptions.add(atom.config.onDidChange("atom-music.controls.skip", skipTime => {
			if (skipTime.newValue > 0) {
				this.atomMusicView.refs.rewindButton.style.display = "block";
					this.atomMusicView.refs.forwardButton.style.display = "block";
			} else {
				this.atomMusicView.refs.rewindButton.style.display = "none";
					this.atomMusicView.refs.forwardButton.style.display = "none";
			}
		}));
	},

	deactivate() {
		const windowId = atom.config.get("atom-music.state.playerWindowId");
		if (windowId === this.atomMusicView.windowId) {
			atom.config.set("atom-music.state.playerWindowId", 0);
			atom.config.set("atom-music.state.playing", false);
		}
		if (this.atomMusicView) {
			this.atomMusicView.destroy();
			this.atomMusicView = null;
		}
		if (this.subscriptions) {
			this.subscriptions.dispose();
		}
	},

	deserializeAtomMusicView(state) {
		if (this.atomMusicView) {
			this.atomMusicView.destroy();
		}
		this.atomMusicView = new AtomMusicView(state.atomMusicViewState);
		return this.atomMusicView;
	},
};
module.exports = AtomMusic;
