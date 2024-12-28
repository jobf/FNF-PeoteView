package elements;

/**
	The text buffer class.
**/
@:publicFields
class Text {
	var buffer:Buffer<Sprite>;
	var text(default, set):String;

	function set_text(str:String) {
		if (str == text && _scale == scale) {
			return text;
		}

		var advanceX:Int = 0;

		trace('str ' + str);
		trace('text ' + text);

		if(text != null){
			// why is text null?
			for (i in str.length...text.length) {
				var elem = buffer.getElement(i);
				if (elem != null) {
					elem.x = elem.y = -999999999;
					buffer.updateElement(elem);
				}
			}
		}

		for (i in 0...str.length) {
			var code = str.charCodeAt(i) - 32;

			if (code > 95) {
				code = 0;
			}

			var data = parsedTextAtlasData[code];
			var padding = data.padding;

			var spr = buffer.getElement(i);

			if (spr == null) {
				spr = new Sprite();
				buffer.addElement(spr);
			}

			spr.clipX = data.position.x + padding;
			spr.clipY = data.position.y + padding;
			spr.clipWidth = spr.clipSizeX = data.sourceSize.width;
			spr.w = Math.floor(spr.clipWidth * scale);
			spr.clipHeight = spr.clipSizeY = data.sourceSize.height;
			spr.h = Math.floor(spr.clipHeight * scale);
			spr.x = x + Math.floor(data.char.offset.x * scale) + advanceX;
			spr.y = y + Math.floor(data.char.offset.y * scale);
			advanceX += Math.floor(data.char.advanceX * scale);

			if (height < spr.h) {
				height = spr.h;
			}

			if (spr != null) {
				buffer.updateElement(spr);
			}
		}

		var test = buffer.getElement(0);
		trace('text spr w ${test.w}');

		width = advanceX;
		_scale = scale;

		return text = str;
	}

	var x(default, set):Int;

	function set_x(value:Int) {
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

	var y(default, set):Int;

	function set_y(value:Int) {
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
		this.text = text;

		return scale = value;
	}

	var _scale(default, null):Float = 1.0;

	var width(default, null):Int;

	var height(default, null):Int;

	static var parsedTextAtlasData:Array<FontCharacterInfo>;

	function new(x:Int, y:Int, text:String = "Sample text") {
		var data = haxe.Json.parse(sys.io.File.getContent("assets/fonts/vcrAtlas.json"));
		parsedTextAtlasData = data.sprites;
		buffer = new Buffer<Sprite>(64, 64, false);

		this.text = text;
		this.x = x;
		this.y = y;
		
	}
}

private typedef FontCharacterInfo = {
	position:{
		x:Int,
		y:Int
	},
	sourceSize:{
		width:Int,
		height:Int
	},
	padding:Int,
	char:{
		advanceX:Int,
		offset:{x:Int, y:Int}
	}
}