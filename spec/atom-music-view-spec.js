const AtomMusicView = require("../lib/atom-music-view");

describe("AtomMusicView", () => {
	it("have an audio tag", () => {
		const view = new AtomMusicView();
		expect(view.element.querySelector("audio")).not.toBeNull();
	});
});
