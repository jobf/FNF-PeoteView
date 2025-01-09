package data;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import sys.io.File;
import sys.FileSystem;
import sys.io.FileOutput;
import haxe.crypto.Base64;
import lime.ui.KeyCode;

/**
	The save data securer.
**/
@:publicFields
class SaveData_Securer {
	static function lock(bytes:Bytes):String {
		return Base64.encode(bytes);
	}

	static function unlock(encoded:String):Bytes {
		return Base64.decode(encoded);
	}
}

/**
	The save data structure.
**/
@:structInit
@:publicFields
class SaveData {
	static var state:SaveData = {
		controls: {
			ui: {
				left: KeyCode.LEFT,
				down: KeyCode.DOWN,
				up: KeyCode.UP,
				right: KeyCode.RIGHT,
				accept: KeyCode.RETURN,
				back: KeyCode.BACKSPACE
			},
			game: {
				left: KeyCode.LEFT,
				down: KeyCode.DOWN,
				up: KeyCode.UP,
				right: KeyCode.RIGHT,
				reset: KeyCode.R,
				pause: KeyCode.RETURN,
				debug: KeyCode.NUMBER_7
			},
			inputOffset: 0
		},
		preferences: {
			downScroll: true,
			hideHUD: false,
			smoothHealthbar: false,
			ratingPopup: true,
			scoreTxtBopping: true,
			cameraZooming: true,
			iconBopping: true
		},
		graphics: {
			frameRate: 60,
			mipMapping: false,
			antialiasing: true,
			customTitleBarColor: 0xFFAA00FF,
			customWindowOutlineColor: 0x999999FF,
			customTitleTextFont: "vcr"
		}
	};

	static function init() {
		var window = lime.app.Application.current.window;
		window.onClose.add(save);

		if (!FileSystem.exists('save.dat')) {
			save();
		}

		open();
	}

	static function open() {
		var result = SaveData_Securer.unlock(File.getContent("save.dat"));
		state = _toStruct(result);
	}

	static function save() {
		var bytes = _toBytes(state);
		var result = SaveData_Securer.lock(bytes);
		var fo:FileOutput = File.write("save.dat");
		fo.writeString(result);
		fo.close();
	}

	private static function _toBytes(s:SaveData) {
		var out = new BytesOutput();

		out.writeInt32(s.graphics.customTitleTextFont.length);
		out.writeString(s.graphics.customTitleTextFont);
		out.writeInt32(s.controls.ui.left);
		out.writeInt32(s.controls.ui.down);
		out.writeInt32(s.controls.ui.up);
		out.writeInt32(s.controls.ui.right);
		out.writeInt32(s.controls.ui.accept);
		out.writeInt32(s.controls.ui.back);
		out.writeInt32(s.controls.game.left);
		out.writeInt32(s.controls.game.down);
		out.writeInt32(s.controls.game.up);
		out.writeInt32(s.controls.game.right);
		out.writeInt32(s.controls.game.pause);
		out.writeInt32(s.controls.game.reset);
		out.writeInt32(s.controls.game.debug);
		out.writeInt32(s.controls.inputOffset);
		out.writeByte(s.preferences.downScroll ? 0 : 1);
		out.writeByte(s.preferences.hideHUD ? 0 : 1);
		out.writeByte(s.preferences.smoothHealthbar ? 0 : 1);
		out.writeByte(s.preferences.ratingPopup ? 0 : 1);
		out.writeByte(s.preferences.scoreTxtBopping ? 0 : 1);
		out.writeByte(s.preferences.cameraZooming ? 0 : 1);
		out.writeByte(s.preferences.iconBopping ? 0 : 1);
		out.writeInt32(s.graphics.frameRate);
		out.writeByte(s.graphics.mipMapping ? 0 : 1);
		out.writeByte(s.graphics.antialiasing ? 0 : 1);
		out.writeInt32(s.graphics.customTitleBarColor);
		out.writeInt32(s.graphics.customWindowOutlineColor);

		return out.getBytes();
	}

	private static function _toStruct(bytes:Bytes):SaveData {
		var b = new BytesInput(bytes);

		var len = b.readInt32();
		var fnt = b.readString(len);

		var result:SaveData = {
			controls: {
				ui: {
					left: b.readInt32(),
					down: b.readInt32(),
					up: b.readInt32(),
					right: b.readInt32(),
					accept: b.readInt32(),
					back: b.readInt32()
				},
				game: {
					left: b.readInt32(),
					down: b.readInt32(),
					up: b.readInt32(),
					right: b.readInt32(),
					reset: b.readInt32(),
					pause: b.readInt32(),
					debug: b.readInt32()
				},
				inputOffset: b.readInt32()
			},
			preferences: {
				downScroll: b.readByte() == 0,
				hideHUD: b.readByte() == 0,
				smoothHealthbar: b.readByte() == 0,
				ratingPopup: b.readByte() == 0,
				scoreTxtBopping: b.readByte() == 0,
				cameraZooming: b.readByte() == 0,
				iconBopping: b.readByte() == 0
			},
			graphics: {
				frameRate: b.readInt32(),
				mipMapping: b.readByte() == 0,
				antialiasing: b.readByte() == 0,
				customTitleBarColor: b.readInt32(),
				customWindowOutlineColor: b.readInt32(),
				customTitleTextFont: fnt
			}
		};

		return result;
	}

	var controls:SaveData_Controls;
	var preferences:SaveData_Preferences;
	var graphics:SaveData_Graphics;
}

/**
	The save data controls category.
**/
@:structInit
@:publicFields
class SaveData_Controls {
	var ui:Controls_UI;
	var game:Controls_Game;
	var inputOffset:Int;
}

/**
	The save data UI sub-category of the controls.
**/
@:structInit
@:publicFields
class Controls_UI {
	var left:Int;
	var down:Int;
	var up:Int;
	var right:Int;
	var accept:Int;
	var back:Int;
}

/**
	The save data game sub-category of the controls.
**/
@:structInit
@:publicFields
class Controls_Game {
	var left:Int;
	var down:Int;
	var up:Int;
	var right:Int;
	var pause:Int;
	var reset:Int;
	var debug:Int;
}


/**
	The save data preferences category.
**/
@:structInit
@:publicFields
class SaveData_Preferences {
	var downScroll:Bool;
	var hideHUD:Bool;
	var smoothHealthbar:Bool;
	var ratingPopup:Bool;
	var scoreTxtBopping:Bool;
	var cameraZooming:Bool;
	var iconBopping:Bool;
}

/**
	The save data graphics category.
**/
@:structInit
@:publicFields
class SaveData_Graphics {
	var frameRate:Int;
	var mipMapping:Bool;
	var antialiasing:Bool;
	var customTitleBarColor:Int;
	var customWindowOutlineColor:Int;
	var customTitleTextFont:String;
}