/** @babel */

/** @jsx etch.dom */

const etch = require("etch");
const SelectList = require("atom-select-list");

class PlayListView {
	constructor(player, items) {
		this.player = player;
		this.items = items;
		this.filterKeyForItem = this.filterKeyForItem.bind(this);
		this.didConfirmSelection = this.didConfirmSelection.bind(this);
		this.didCancelSelection = this.didCancelSelection.bind(this);
		this.elementForItem = this.elementForItem.bind(this);
		etch.initialize(this);
		this.panel = atom.workspace.addModalPanel({item: this, autoFocus: true});
	}

	update(items) {
		if (items) {
			this.items = items;
		}
		return etch.update(this);
	}

	render() {
		return (
			<SelectList
				ref="selectList"
				items={this.items}
				filterKeyForItem={this.filterKeyForItem}
				didConfirmSelection={this.didConfirmSelection}
				didCancelSelection={this.didCancelSelection}
				elementForItem={this.elementForItem}
			/>
		);
	}

	show() {
		this.panel.show();
		this.focus();
	}

	hide() {
		this.panel.hide();
	}

	focus() {
		this.refs.selectList.focus();
	}

	filterKeyForItem(track) { return track.name; }

	didConfirmSelection(track) {
		this.player.playTrack(track);
		this.hide();
	}

	didCancelSelection() {
		this.hide();
	}

	elementForItem(track) {
		return etch.render(<li>{track.name}</li>);
	}

	destroy() {
		this.panel.destroy();
		return etch.destroy(this);
	}
}

module.exports = PlayListView;
