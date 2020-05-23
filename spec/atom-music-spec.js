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
});
