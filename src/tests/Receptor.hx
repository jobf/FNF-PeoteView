package tests;

import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.app.Application;

/**
	The receptor sprite.
	Inside of it is notes and sustains that are layered onto the receptor.
**/
#if !debug
@:noDebug
#end
@:publicFields
class Receptor extends Sprite {
	/**
		What the receptor's keybinds should allow.
    **/
    var binds(default, set):Array<KeyCode>;

	/**
		Change the receptor's keybinds.
    **/
	function set_binds(keyCodes:Array<KeyCode>):Array<KeyCode> {
		var window = Application.current.window;

		if (keyCodes.length != 0) {
			if (!window.onKeyDown.has(_keyPress)) {
				window.onKeyDown.add(_keyPress);
			}

			if (!window.onKeyUp.has(_keyRelease)) {
				window.onKeyUp.add(_keyRelease);
			}
		} else {
			if (window.onKeyDown.has(_keyPress)) {
				window.onKeyDown.remove(_keyPress);
			}

			if (window.onKeyUp.has(_keyRelease)) {
				window.onKeyUp.remove(_keyRelease);
			}
		}

		return binds = keyCodes;
	}

	/**
		What the receptor's keybind should allow.
    **/
    var bind(get, set):KeyCode;

	/**
		Get the receptor's keybind.
    **/
	inline function get_bind():KeyCode {
		return binds[0];
	}

	/**
		Change the receptor's keybind.
    **/
	inline function set_bind(value:KeyCode):KeyCode {
		return binds[0] = value;
	}

	/**
		What the receptor should display as.
    **/
    var skin:String;

	/**
		Constructs an alphabet text sprite.
		@param text The alphabet's text.
		@param x The sprite's x.
		@param y The sprite's y.
		@param z The sprite's z index.
	**/
	function new(playable:Bool = false, x:Float = 0, y:Float = 0, skin:String = "normal", z:Int = 0) {
		super(x, y, z);
        this.skin = skin;

		if (playable) {
			binds = [UNKNOWN];
		}
	}

	/**
		Internal function callback for receptor presses.
	**/
	private function _keyPress(keyCode:KeyCode, keyMod:KeyModifier) {
		if (binds.length == 0) {
			return;
		}

		// This makes it so that inputs can be a tiny bit more responsive when using only a single keybind
		var bindCheck = (binds.length != 1) ? binds.contains(keyCode) : bind != keyCode;

		if (!bindCheck) {
			return;
		}

		//Sys.println('Press $keyCode');

		c = 0xFFFFFF66;
	}

	/**
		Internal function callback for receptor releases.
	**/
	private function _keyRelease(keyCode:KeyCode, keyMod:KeyModifier) {
		if (binds.length == 0) {
			return;
		}

		// This makes it so that inputs can be a tiny bit more responsive when using only a single keybind
		var bindCheck = (binds.length != 1) ? binds.contains(keyCode) : bind != keyCode;

		if (!bindCheck) {
			return;
		}

		//Sys.println('Release $keyCode');

		c = 0xFFFFFFFF;
	}
}