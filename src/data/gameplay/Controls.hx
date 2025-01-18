package data.gameplay;

import lime.ui.KeyCode;
import lime.ui.ScanCode;
import lime.ui.KeyModifier;
import lime.app.Event;

/**
	The controls of the fnf engine.
	This allows for easy keybind managing for it.
**/
@:publicFields
class Controls {
	var keycodeToUIKeybind:Map<KeyCode, ControlsKeybind> = [];
	var keycodeToGameplayKeybind:Map<KeyCode, ControlsKeybind> = [];

	static var pressed:Controls;
	static var released:Controls;

	function new() {
		reload();
	}

	function reload() {
		keycodeToUIKeybind.clear();
		keycodeToGameplayKeybind.clear();

		var controls = SaveData.state.controls;

		keycodeToUIKeybind[controls.ui.left] = UI_LEFT;
		keycodeToUIKeybind[controls.ui.down] = UI_DOWN;
		keycodeToUIKeybind[controls.ui.up] = UI_UP;
		keycodeToUIKeybind[controls.ui.right] = UI_RIGHT;
		keycodeToUIKeybind[controls.ui.accept[0]] = UI_ACCEPT;
		keycodeToUIKeybind[controls.ui.accept[1]] = UI_ACCEPT;
		keycodeToUIKeybind[controls.ui.back[0]] = UI_BACK;
		keycodeToUIKeybind[controls.ui.back[1]] = UI_BACK;
		keycodeToGameplayKeybind[controls.game.pause] = GAME_PAUSE;
		keycodeToGameplayKeybind[controls.game.reset] = GAME_RESET;
		keycodeToGameplayKeybind[controls.game.debug] = GAME_DEBUG;
	}
}

enum abstract ControlsKeybind(Int) {
	var NONE;
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