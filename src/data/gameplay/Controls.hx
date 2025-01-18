package data.gameplay;

import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.app.Event;

/**
	The controls of the fnf engine.
	This allows for easy keybind managing for it.
**/
@:publicFields
class Controls {
	var keycodeToKeybind:Map<KeyCode, ControlsKeybind> = [];

	static var pressed:Controls;
	static var released:Controls;

	function new() {
		reload();
	}

    function reload() {
        keycodeToKeybind.clear();

        var controls = SaveData.state.controls;

		keycodeToKeybind[controls.ui.left] = UI_LEFT;
        keycodeToKeybind[controls.ui.down] = UI_DOWN;
        keycodeToKeybind[controls.ui.up] = UI_UP;
        keycodeToKeybind[controls.ui.right] = UI_RIGHT;
        keycodeToKeybind[controls.ui.accept[0]] = UI_ACCEPT;
        keycodeToKeybind[controls.ui.accept[1]] = UI_ACCEPT;
        keycodeToKeybind[controls.ui.back[0]] = UI_BACK;
        keycodeToKeybind[controls.ui.back[1]] = UI_BACK;
        keycodeToKeybind[controls.game.pause] = GAME_PAUSE;
        keycodeToKeybind[controls.game.reset] = GAME_RESET;
        keycodeToKeybind[controls.game.debug] = GAME_DEBUG;
    }
}

enum abstract ControlsKeybind(Int) {
	var UI_LEFT;
	var UI_DOWN;
	var UI_UP;
	var UI_RIGHT;
	var UI_ACCEPT;
	var UI_BACK;
	var GAME_ARRAY;
	var GAME_PAUSE;
	var GAME_RESET;
	var GAME_DEBUG;
}