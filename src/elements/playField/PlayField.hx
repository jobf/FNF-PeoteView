package elements.playField;

import lime.ui.KeyCode;
import sys.io.File;

@:publicFields
class PlayField {
	// Behind the receptor system
	var behindBuf:Buffer<Sustain>;
	var frontBuf:Buffer<Note>;

	// Above the receptor system
	var behindProg:Program;
	var frontProg:Program;

	var textureMapProperties:Array<Int> = [];
	var keybindMap:Map<KeyCode, Array<Int>> = [
		KeyCode.A => [0, 1],
		KeyCode.S => [1, 1],
		KeyCode.UP => [2, 1],
		KeyCode.RIGHT => [3, 1]
	];

	var strumlineMap:Array<Array<Array<Int>>> = [
		[[0, 50], [-90, 162], [90, 274], [180, 386]],
		[[0, 690], [-90, 802], [90, 914], [180, 1026]]
	];

	var numOfReceptors:Int;
	var numOfNotes:Int;

	var scrollSpeed(default, set):Float = 1.0;

	inline function set_scrollSpeed(value:Float) {
		spawnDist = ChartConverter.betterInt64FromFloat(160000 / value);
		despawnDist = ChartConverter.betterInt64FromFloat(50000 / value);
		return scrollSpeed = value;
	}

	function new(display:Display) {
		for (i in 0...strumlineMap.length) {
			numOfReceptors += strumlineMap[i].length;
		}

		// Note to self: set the texture size exactly to the image's size

		// NOTE SHEET SETUP
		TextureSystem.createTiledTexture("noteTex", "assets/notes/normal/noteSheet.png", 4);

		frontBuf = new Buffer<Note>(8192, 8192, false);
		frontProg = new Program(frontBuf);
		frontProg.blendEnabled = true;
		TextureSystem.setTexture(frontProg, "noteTex", "noteTex");

		var tex1 = TextureSystem.getTexture("noteTex");
		textureMapProperties.push(tex1.width >> 2);
		textureMapProperties.push(tex1.height);

		// SUSTAIN SETUP

		TextureSystem.createTexture("sustainTex", "assets/notes/normal/sustain.png");

		behindBuf = new Buffer<Sustain>(8192, 8192, false);
		behindProg = new Program(behindBuf);
		behindProg.blendEnabled = true;

		var tex2 = TextureSystem.getTexture("sustainTex");

		Sustain.init(behindProg, "sustainTex", tex2);
		textureMapProperties.push(tex2.width);
		textureMapProperties.push(tex2.height);

		display.addProgram(behindProg);
		display.addProgram(frontProg);

		for (j in 0...strumlineMap.length) {
			var map = strumlineMap[j];
			for (i in 0...map.length) {
				var rec = new Note(0, 50, textureMapProperties[0], textureMapProperties[1]);
				rec.r = map[i][0];
				rec.x = map[i][1];
				frontBuf.addElement(rec);
			}
		}
	}

	private var spawnPosBottom(default, null):Int;
	private var spawnPosTop(default, null):Int;
	private var spawnDist(default, null):Int64 = ChartConverter.betterInt64FromFloat(160000);
	private var despawnDist(default, null):Int64 = ChartConverter.betterInt64FromFloat(50000);

	function update(songPos:Float) {
		var pos = ChartConverter.betterInt64FromFloat(songPos * 100);

		while (spawnPosTop != numOfNotes && frontBuf.getElement(spawnPosTop + numOfReceptors).data.position < pos + spawnDist) {
			spawnPosTop++;
			Sys.println('Top: $spawnPosTop');
		}

		for (i in spawnPosBottom...spawnPosTop) {
			var note = frontBuf.getElement(i + numOfReceptors);

			var data = note.data;
			var index = note.data.index;
			var lane = note.data.lane;

			var laneMap = strumlineMap[lane];

			var position = note.data.position;

			var rec = frontBuf.getElement(index + (lane * laneMap.length));

			note.x = rec.x;
			note.y = rec.y + Math.floor(Int64.div(position - pos, 222).low * scrollSpeed);
			note.r = laneMap[index][0];
			frontBuf.updateElement(note);

			var sustain = note.child;

			var dist = despawnDist;

			if (sustain != null) {
				sustain.speed = scrollSpeed * 0.45;
				sustain.followNote(note);
				behindBuf.updateElement(sustain);
				dist += sustain.length * 100;
			}

			while (spawnPosBottom != numOfNotes && pos - frontBuf.getElement(spawnPosBottom + numOfReceptors).data.position > dist) {
				spawnPosBottom++;
				Sys.println('Bottom: $spawnPosBottom');
			}
		}
	}

	function keyPress(code:KeyCode, mod) {
		if (!keybindMap.exists(code)) {
			return;
		}

		var map = keybindMap[code];

		var rec = frontBuf.getElement(map[0] + (strumlineMap[1].length * map[1]));

		rec.confirm();
		frontBuf.updateElement(rec);
	}

	function keyRelease(code:KeyCode, mod) {
		if (!keybindMap.exists(code)) {
			return;
		}

		var map = keybindMap[code];

		var rec = frontBuf.getElement(map[0] + (strumlineMap[1].length * map[1]));

		rec.reset();
		frontBuf.updateElement(rec);
	}
}