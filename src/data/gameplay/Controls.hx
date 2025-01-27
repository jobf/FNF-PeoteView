package data.gameplay;

import lime.ui.KeyCode;
import lime.ui.ScanCode;
import lime.ui.KeyModifier;
import lime.app.Event;
import input2action.*;
import input2action.util.NestedArray;

/**
	The controls of the fnf engine.
	This allows for easy keybind managing for it.
**/
@:publicFields
class Controls {
	var handle:ControlsHandle;
	var config:ActionConfig;
	var map:ActionMap = new ActionMap();

	function setActionOnMap(action:Action, func:ActionFunction, up:Bool = true) {
		for (key => value in map) {
			if (key == action) {
				var untypedMap = untyped map;
				if (!untypedMap.exists(key)) {
					untypedMap.set(key, {action: func, up: up});
				} else {
					untypedMap.get(key).action = func;
				}
				break;
			}
		}
	}

	function new() {
		reload();
	}

	function reload() {
		var controls = SaveData.state.controls;

		config = [
			{
				action: Action.UI_LEFT,
				keyboard: NestedArray.fromNestedArrayItem(controls.ui.left),
				gamepad: NestedArray.fromNestedArrayItem(controls.ui.left)
			},
			{
				action: Action.UI_DOWN,
				keyboard: NestedArray.fromNestedArrayItem(controls.ui.down),
				gamepad: NestedArray.fromNestedArrayItem(controls.ui.up)
			},
			{
				action: Action.UI_UP,
				keyboard: NestedArray.fromNestedArrayItem(controls.ui.up),
				gamepad: NestedArray.fromNestedArrayItem(controls.ui.up)
			},
			{
				action: Action.UI_RIGHT,
				keyboard: NestedArray.fromNestedArrayItem(controls.ui.right),
				gamepad: NestedArray.fromNestedArrayItem(controls.ui.right)
			},
			{
				action: Action.UI_ACCEPT,
				keyboard: cast NestedArray.fromNestedArrayItem(controls.ui.accept),
				gamepad: cast NestedArray.fromNestedArrayItem(controls.ui.accept)
			},
			{
				action: Action.UI_BACK,
				keyboard: cast NestedArray.fromNestedArrayItem(controls.ui.back),
				gamepad: cast NestedArray.fromNestedArrayItem(controls.ui.back)
			},
			{
				action: Action.GAME_PAUSE,
				keyboard: NestedArray.fromNestedArrayItem(controls.game.pause),
				gamepad: NestedArray.fromNestedArrayItem(controls.game.pause)
			},
			{
				action: Action.GAME_RESET,
				keyboard: NestedArray.fromNestedArrayItem(controls.game.reset),
				gamepad: NestedArray.fromNestedArrayItem(controls.game.reset)
			},
			{
				action: Action.GAME_DEBUG,
				keyboard: NestedArray.fromNestedArrayItem(controls.game.debug),
				gamepad: NestedArray.fromNestedArrayItem(controls.game.debug)
			}
		];

		handle = new ControlsHandle(config, map);
	}
}

@:publicFields
class ControlsHandle {
	var i2a:Input2Action;
	var kb:KeyboardAction;
	var gp:GamepadAction;

	function new(config:ActionConfig, map:ActionMap) {
		reload(config, map);
	}

	function reload(config:ActionConfig, map:ActionMap) {
		i2a = new Input2Action();
		i2a.registerKeyboardEvents(lime.app.Application.current.window);
		kb = new KeyboardAction(config, map);
		i2a.addKeyboard(kb);
		//gp = new GamepadAction(config, map);
		//i2a.addGamepad(Main.current.gamepad, gp);
	}
}

enum abstract Action(String) to String {
	var UI_LEFT = "L";
	var UI_DOWN =  "D";
	var UI_UP = "U";
	var UI_RIGHT = "R";
	var UI_ACCEPT = "A";
	var UI_BACK = "B";
	var GAME_PAUSE = "P";
	var GAME_RESET = "X";
	var GAME_DEBUG = "C";
}