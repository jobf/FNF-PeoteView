package data.gameplay;

import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.app.Event;

/**
	The controls of the fnf engine.
	This allows for easy keybind managing for your fnf engine.
**/
@:publicFields
class Controls {
	var keybindMap:Map<ControlsKeybind, Vector<Vector<KeyCode>>> = [];

	static var pressed:Controls;
	static var released:Controls;

	var action:Map<ControlsKeybind, Event<Int->Void>> = [
		UI_LEFT => new Event<Int->Void>(),
		UI_DOWN => new Event<Int->Void>(),
		UI_UP => new Event<Int->Void>(),
		UI_RIGHT => new Event<Int->Void>(),
		UI_ACCEPT => new Event<Int->Void>(),
		UI_BACK => new Event<Int->Void>(),
		GAME_ARRAY => new Event<Int->Void>(),
		GAME_PAUSE => new Event<Int->Void>(),
		GAME_RESET => new Event<Int->Void>(),
		GAME_DEBUG => new Event<Int->Void>()
	];

	function addToQueue(bind:ControlsKeybind, func:Int->Void) {
		if (func == null) {
			Sys.println('Controls system - could not add function to queue.');
			return;
		}

		action[bind].add(func);
	}

	function removeFromQueue(bind:ControlsKeybind, func:Int->Void) {
		if (func == null) {
			Sys.println('Controls system - could not add function to queue.');
			return;
		}

		action[bind].remove(func);
	}

	function new(type:ControlsKeyActionType) {
		var window = lime.app.Application.current.window;

		switch (type) {
			case PRESSED:
				window.onKeyDown.add(fire);
			case RELEASED:
				window.onKeyUp.add(fire);
		}

		var controls = SaveData.state.controls;

		keybindMap[UI_LEFT] = Vector.fromData([Vector.fromData([controls.ui.left])]);
		keybindMap[UI_DOWN] = Vector.fromData([Vector.fromData([controls.ui.down])]);
		keybindMap[UI_UP] = Vector.fromData([Vector.fromData([controls.ui.up])]);
		keybindMap[UI_RIGHT] = Vector.fromData([Vector.fromData([controls.ui.right])]);
		keybindMap[UI_ACCEPT] = Vector.fromData([Vector.fromData([controls.ui.accept])]);
		keybindMap[UI_BACK] = Vector.fromData([Vector.fromData([controls.ui.back])]);
		keybindMap[GAME_ARRAY] = controls.game.keybindArray;
		keybindMap[GAME_PAUSE] = Vector.fromData([Vector.fromData([controls.game.pause])]);
		keybindMap[GAME_RESET] = Vector.fromData([Vector.fromData([controls.game.reset])]);
		keybindMap[GAME_DEBUG] = Vector.fromData([Vector.fromData([controls.game.debug])]);
	}

	// This shit is the mess part

	function fire(code:KeyCode, keyModifier:KeyModifier) {
		var controls = SaveData.state.controls;

		var ui = controls.ui;
		var game = controls.game;

		// Fuck you haxe switch statements for not letting me do 
		if (code == keybindMap[UI_LEFT][0][0]) action[UI_LEFT].dispatch(0);
		else if (code == keybindMap[UI_DOWN][0][0]) action[UI_DOWN].dispatch(0);
		else if (code == keybindMap[UI_UP][0][0]) action[UI_UP].dispatch(0);
		else if (code == keybindMap[UI_RIGHT][0][0]) action[UI_RIGHT].dispatch(0);
		else if (code == keybindMap[UI_ACCEPT][0][0]) action[UI_ACCEPT].dispatch(0);
		else if (code == keybindMap[UI_BACK][0][0]) action[UI_BACK].dispatch(0);
		else if (code == keybindMap[GAME_PAUSE][0][0]) action[GAME_PAUSE].dispatch(0);
		else if (code == keybindMap[GAME_RESET][0][0]) action[GAME_RESET].dispatch(0);
		else if (code == keybindMap[GAME_DEBUG][0][0]) action[GAME_DEBUG].dispatch(0);
		else keybindFire(code);
	}

	function keybindFire(code:KeyCode) {
		var playField = Main.current.playField;

		if (playField == null) return;

		var event = action[GAME_ARRAY];
		var keys = playField.chart.header.mania;
		var arr = SaveData.state.controls.game.keybindArray[keys];

		for (i in 0...keys) {
			var keybind = arr[i];
			if (code == keybind) {
				event.dispatch(i);
				break;
			}
		}
	}
}

enum abstract ControlsKeyActionType(Int) {
	var PRESSED;
	var RELEASED;
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