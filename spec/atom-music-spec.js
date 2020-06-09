const AtomMusic = require("../lib/atom-music");

describe("AtomMusic", function() {
	let workspaceElement, activationPromise;

	beforeEach(function() {
		workspaceElement = atom.views.getView(atom.workspace);
		activationPromise = atom.packages.activatePackage("atom-music");
	});

	describe("when the atom-music:toggle event is triggered", () => {
		it("hides and shows the pane", async () => {
			// Before the activation event the view is not on the DOM, and no panel
			// has been created
			expect(workspaceElement.querySelector(".atom-music")).not.toExist();

			// This is an activation event, triggering it will cause the package to be
			// activated.
			atom.commands.dispatch(workspaceElement, "atom-music:toggle");

			await activationPromise;

			expect(workspaceElement.querySelector(".atom-music")).toExist();

			const atomMusicElement = workspaceElement.querySelector(".atom-music");
			expect(atomMusicElement).toExist();

			const bottomDock = atom.workspace.getBottomDock();
			expect(bottomDock.getActivePaneItem()).toBe(AtomMusic.atomMusicView);
			expect(bottomDock.isVisible()).toBe(true);
			atom.commands.dispatch(workspaceElement, "atom-music:toggle");
			expect(bottomDock.isVisible()).toBe(false);
		});
	});

	describe("when atom-music is activated", () => {
		beforeEach(async () => {
			atom.commands.dispatch(workspaceElement, "atom-music:toggle");
			await activationPromise;
		});

		it("adds command atom-music:toggle", async () => {
			spyOn(AtomMusic.atomMusicView, "toggle");
			atom.commands.dispatch(workspaceElement, "atom-music:toggle");
			expect(AtomMusic.atomMusicView.toggle).toHaveBeenCalled();
		});

		it("adds command atom-music:play-pause", async () => {
			spyOn(AtomMusic.atomMusicView, "togglePlayback");
			atom.commands.dispatch(workspaceElement, "atom-music:play-pause");
			expect(AtomMusic.atomMusicView.togglePlayback).toHaveBeenCalled();
		});

		it("adds command atom-music:toggle-shuffle", async () => {
			spyOn(AtomMusic.atomMusicView, "toggleShuffle");
			atom.commands.dispatch(workspaceElement, "atom-music:toggle-shuffle");
			expect(AtomMusic.atomMusicView.toggleShuffle).toHaveBeenCalled();
		});

		it("adds command atom-music:search-playlist", async () => {
			spyOn(AtomMusic.atomMusicView, "searchPlayList");
			atom.commands.dispatch(workspaceElement, "atom-music:search-playlist");
			expect(AtomMusic.atomMusicView.searchPlayList).toHaveBeenCalled();
		});

		it("adds command atom-music:forward", async () => {
			spyOn(AtomMusic.atomMusicView, "forward");
			atom.commands.dispatch(workspaceElement, "atom-music:forward");
			expect(AtomMusic.atomMusicView.forward).toHaveBeenCalled();
		});

		it("adds command atom-music:rewind", async () => {
			spyOn(AtomMusic.atomMusicView, "rewind");
			atom.commands.dispatch(workspaceElement, "atom-music:rewind");
			expect(AtomMusic.atomMusicView.rewind).toHaveBeenCalled();
		});

		it("adds command atom-music:next-track", async () => {
			spyOn(AtomMusic.atomMusicView, "nextTrack");
			atom.commands.dispatch(workspaceElement, "atom-music:next-track");
			expect(AtomMusic.atomMusicView.nextTrack).toHaveBeenCalled();
		});

		it("adds command atom-music:previous-track", async () => {
			spyOn(AtomMusic.atomMusicView, "prevTrack");
			atom.commands.dispatch(workspaceElement, "atom-music:previous-track");
			expect(AtomMusic.atomMusicView.prevTrack).toHaveBeenCalled();
		});
	});
});
