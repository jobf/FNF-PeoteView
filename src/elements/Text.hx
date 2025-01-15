package elements;

import elements.text.*;

/**
	The text buffer class.
**/
@:publicFields
class Text {
	static var buffers:Map<String, Buffer<TextCharSprite>> = [];
	static var programs:Map<String, Program> = [];

	var buffer(get, never):Buffer<TextCharSprite>;

	inline function get_buffer() {
		return buffers[_key];
	}

	var program(get, never):Program;

	inline function get_program() {
		return programs[_key];
	}

	var _key:String;

	var display:Display;

	var text(default, set):String;

	function set_text(str:String) {
		if (str == text) {
			return text;
		}

		var advanceX:Float = 0;

		if (text != null) {
			for (i in str.length...text.length) {
				var elem = buffer.getElement(i);
				if (elem != null) {
					elem.x = elem.y = -999999999;
					buffer.updateElement(elem);
				}
			}
		}

		text = str;

		for (i in 0...str.length) {
			var code = str.charCodeAt(i) - 32;

			if (code > 95) {
				code = 0;
			}

			var data = parsedTextAtlasData[code];
			var padding = data.padding;

			var canUseFromBuffer = i < buffer.length;

			var spr:TextCharSprite = canUseFromBuffer 
				? buffer.getElement(i) 
				: buffer.addElement(new TextCharSprite());

			spr.clipX = data.position.x + padding;
			spr.clipY = data.position.y + padding;
			spr.clipWidth = spr.clipSizeX = data.sourceSize.width;
			spr.w = (spr.clipWidth * scale);
			spr.clipHeight = spr.clipSizeY = data.sourceSize.height;
			spr.h = (spr.clipHeight * scale);
			spr.x = x + (data.char.offset.x * scale) + advanceX;
			spr.y = y + (data.char.offset.y * scale);
			spr.c = color;
			advanceX += (data.char.advanceX * scale);

			if (height < spr.h) {
				height = spr.h;
			}

			buffer.updateElement(spr);
		}

		width = advanceX;

		return str;
	}

	var x(default, set):Float;

	function set_x(value:Float) {
		if (value == x) {
			return x;
		}

		for (i in 0...text.length) {
			var elem = buffer.getElement(i);
			elem.x += value - x;
			buffer.updateElement(elem);
		}

		return x = value;
	}

	var y(default, set):Float;

	function set_y(value:Float) {
		if (value == y) {
			return y;
		}

		for (i in 0...text.length) {
			var elem = buffer.getElement(i);
			elem.y += value - y;
			buffer.updateElement(elem);
		}

		return y = value;
	}

	var scale(default, set):Float = 1.0;

	function set_scale(value:Float) {
		if (value == scale) {
			return scale;
		}

		scale = value;

		var advanceX:Float = 0;

		for (i in 0...text.length) {
			var code = text.charCodeAt(i) - 32;

			if (code > 95) {
				code = 0;
			}

			var data = parsedTextAtlasData[code];
			var padding = data.padding;

			var spr = buffer.getElement(i);

			spr.clipX = data.position.x + padding;
			spr.clipY = data.position.y + padding;
			spr.clipWidth = spr.clipSizeX = data.sourceSize.width;
			spr.w = (spr.clipWidth * scale);
			spr.clipHeight = spr.clipSizeY = data.sourceSize.height;
			spr.h = (spr.clipHeight * scale);
			spr.x = x + (data.char.offset.x * scale) + advanceX;
			spr.y = y + (data.char.offset.y * scale);
			advanceX += (data.char.advanceX * scale);

			if (height < spr.h) {
				height = spr.h;
			}

			if (spr != null) {
				buffer.updateElement(spr);
			}
		}

		width = advanceX;
		_scale = scale;

		return value;
	}

	var _scale(default, null):Float = 1.0;

	var width(default, null):Float;

	var height(default, null):Float;

	var alpha(default, set):Float = 1.0;

	function set_alpha(value:Float):Float {
		for (i in 0...text.length) {
			var spr = buffer.getElement(i);
			if (spr != null) {
				spr.alpha = value;
				buffer.updateElement(spr);
			}
		}
		return alpha = value;
	}

	var color(default, set):Color = 0xFFFFFFFF;

	function set_color(value:Color):Color {
		for (i in 0...text.length) {
			var spr = buffer.getElement(i);
			if (spr != null) {
				spr.c = value;
				buffer.updateElement(spr);
			}
		}
		return color = value;
	}

	var outlineColor(default, set):Color = 0x000000FF;

	function set_outlineColor(value:Color):Color {
		for (i in 0...text.length) {
			var spr = buffer.getElement(i);
			if (spr != null) {
				spr.oc = value;
				buffer.updateElement(spr);
			}
		}
		return outlineColor = value;
	}

	function setMarkerPair(part:String, color:Color, outlineColor:Color = 0x000000FF, outlineSize:Float = 0) {
		var index = text.indexOf(part);

		for (i in index...index + part.length) {
			var spr = buffer.getElement(i);
			if (spr != null) {
				spr.c = color;
				spr.oc = outlineColor;
				spr.os = outlineSize;
				buffer.updateElement(spr);
			}
		}
	}

	var parsedTextAtlasData:Array<TextCharData>;

	function new(key:String, x:Float, y:Float, display:Display, text:String = "Sample text", font:String = "vcr") {
		if (text.length == 0) text = "Sample text";
		_key = key;

		parsedTextAtlasData = Tools.parseFont(font);

		if (buffers[key] == null) {
			buffers[key] = new Buffer<TextCharSprite>(8, 8, false);
		}

		if (programs[key] == null) {
			var program = new Program(buffer);
			program.blendEnabled = true;
			program.setFragmentFloatPrecision('medium', true);

			var displayTextureID = font + "Font";
			TextureSystem.setTexture(program, displayTextureID, "font");
			program.setColorFormula('getTextureColor(font_ID, vTexCoord) * (c * alphaColor)');
			programs[key] = program;
		}

		this.display = display;

		if (!program.isIn(display)) {
			display.addProgram(program);
		}

		this.text = text;
		this.x = x;
		this.y = y;
	}

	function dispose() {
		if (program.isIn(display)) {
			display.removeProgram(program);
		}
		buffer.clear();
		display = null;
	}
}