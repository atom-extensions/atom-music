const AtomMusicSearchView = require("../lib/atom-music-search-view");

describe("AtomMusicSearchView", () => {
	it("shows and hides the panel", () => {
		const searchView = new AtomMusicSearchView({}, []);
		expect(searchView.panel.isVisible()).toBe(false);
		searchView.show();
		expect(searchView.panel.isVisible()).toBe(true);
		searchView.hide();
		expect(searchView.panel.isVisible()).toBe(false);
	});

	it("shows and hides the panel", () => {
		const searchView = new AtomMusicSearchView({}, []);
		expect(searchView.panel.isVisible()).toBe(false);
		searchView.show();
		expect(searchView.panel.isVisible()).toBe(true);
		searchView.hide();
		expect(searchView.panel.isVisible()).toBe(false);
	});
});
