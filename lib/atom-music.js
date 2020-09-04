'use babel';

import AtomMusicView from './atom-music-view';
import { CompositeDisposable } from 'atom';
const configSchema = require("../config.json");

export default {
	atomMusicView: null,
	subscriptions: null,
	config: configSchema,

	activate(serialized) {
		this.atomMusicView = new AtomMusicView(serialized.atomMusicView);
		// Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable.
		this.subscriptions = new CompositeDisposable(
			// Registers an for the view.
			atom.workspace.addOpener(uri => {
				if (uri === this.atomMusicView.getURI()) { return this.atomMusicView; }
			}),
			// Registers all commands.
			atom.commands.add("atom-workspace", {
				"atom-music:toggle": () => this.atomMusicView.toggle(),
				"atom-music:play-pause": () => this.atomMusicView.togglePlayback(),
				"atom-music:toggle-shuffle": () => this.atomMusicView.toggleShuffle(),
				"atom-music:search-playlist": () => this.atomMusicView.searchPlayList(),
				"atom-music:forward": () => this.atomMusicView.forward(),
				"atom-music:rewind": () => this.atomMusicView.rewind(),
				"atom-music:next-track": () => this.atomMusicView.nextTrack(),
				"atom-music:previous-track": () => this.atomMusicView.prevTrack(),
			}),
			// Registers all configuration change events
			atom.config.onDidChange("atom-music.controls.skip", skipTime => {
				if (skipTime.newValue > 0) {
					this.atomMusicView.refs.rewindButton.style.display = "block";
						this.atomMusicView.refs.forwardButton.style.display = "block";
				} else {
					this.atomMusicView.refs.rewindButton.style.display = "none";
						this.atomMusicView.refs.forwardButton.style.display = "none";
				}
			}),
			atom.config.onDidChange("atom-music.state.playing", playing => {
				const mainWindowId = atom.config.get("atom-music.state.playerWindowId");
				if (atom.config.get("atom-music.features.logging")) {
					console.log("Playing state changed", mainWindowId, this.atomMusicView.windowId, playing.newValue, this.atomMusicView.isPlaying);
				}
				if (!atom.config.get("atom-music.features.multiWindowSupport") && ((mainWindowId === this.atomMusicView.windowId) || (mainWindowId === 0))) {
					if (playing.newValue !== this.atomMusicView.isPlaying) { this.atomMusicView.togglePlayback(); }
				}
			}),
			atom.config.onDidChange("atom-music.state.playerWindowId", windowId => {
				if (atom.config.get("atom-music.features.logging")) {
					console.log("Window ID changed", windowId.newValue, this.atomMusicView.windowId, this.atomMusicView.isPlaying);
				}
				if (!atom.config.get("atom-music.features.multiWindowSupport") && (windowId.newValue !== this.atomMusicView.windowId)) {
					this.atomMusicView.fromWindowChange = true;
					if (this.atomMusicView.isPlaying) { this.atomMusicView.togglePlayback(); }
				}
			})
		);
	},

	deactivate() {
		const windowId = atom.config.get("atom-music.state.playerWindowId");
		if (windowId === this.atomMusicView.windowId) {
			atom.config.set("atom-music.state.playerWindowId", 0);
			atom.config.set("atom-music.state.playing", false);
		}
		this.atomMusicView.destroy();
		this.subscriptions.dispose();
	},

	serialize() {
		return {
			atomMusicView: this.atomMusicView.serialize()
		};
	},

	deserializeAtomMusicView(serializedAtomMusicView) {
		return new AtomMusicView(serializedAtomMusicView);
	},
};
