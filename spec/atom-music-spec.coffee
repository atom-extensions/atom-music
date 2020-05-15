AtomMusic = require '../lib/atom-music'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "AtomMusic", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('atom-music')
    return

  describe "when the atom-music:toggle event is triggered", ->
    it "hides and shows the pane", ->
      # Before the activation event the view is not on the DOM, and no panel
      # has been created
      expect(workspaceElement.querySelector('.atom-music')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'atom-music:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(workspaceElement.querySelector('.atom-music')).toExist()

        atomMusicElement = workspaceElement.querySelector('.atom-music')
        expect(atomMusicElement).toExist()

        bottomDock = atom.workspace.getBottomDock()
        expect(bottomDock.getActivePaneItem()).toBe AtomMusic.atomMusicView
        expect(bottomDock.isVisible()).toBe true
        atom.commands.dispatch workspaceElement, 'atom-music:toggle'
        expect(bottomDock.isVisible()).toBe false
