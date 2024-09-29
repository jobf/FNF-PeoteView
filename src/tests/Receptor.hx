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

		// TOO MANY KEYBINDS! Remove the extra ones.
		// This is a design choice.
		if (keyCodes.length > 2) {
			keyCodes.resize(2);
		}

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
		Where the receptor should go.
    **/
    var cam:Camera;

	/**
		Constructs the receptor.
		@param x The sprite's x.
		@param y The sprite's y.
		@param binds The keybind list that the receptor is allowed to press.
		@param skin What the receptor should look like.
		@param z The sprite's z index.
	**/
	function new(x:Float = 0, y:Float = 0, binds:Array<KeyCode> = null, skin:String = "normal", z:Int = 0) {
		super(x, y, z);
        this.skin = skin;

		if (binds != null) {
			this.binds = binds;
		}
	}

	/**
		Internal function callback for receptor presses.
	**/
	private function _keyPress(keyCode:KeyCode, keyMod:KeyModifier) {
		if (binds.length == 0 || cam == null) {
			return;
		}

		var bindCheck = (binds.length != 1) ? (bind == keyCode || binds[1] == keyCode) : bind == keyCode;

		if (!bindCheck) {
			return;
		}

		//Sys.println('Press $keyCode');

		c = 0xFFFFFF66;
		cam.update(this);
	}

	/**
		Internal function callback for receptor releases.
	**/
	private function _keyRelease(keyCode:KeyCode, keyMod:KeyModifier) {
		if (binds.length == 0 || cam == null) {
			return;
		}

		var bindCheck = (binds.length != 1) ? (bind == keyCode || binds[1] == keyCode) : bind == keyCode;

		if (!bindCheck) {
			return;
		}

		//Sys.println('Release $keyCode');

		c = 0xFFFFFFFF;
		cam.update(this);
	}
}