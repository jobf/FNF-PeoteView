package elements.playField;

import lime.ui.KeyCode;
import sys.io.File;

@:publicFields
class PlayField {

	/**************************************************************************************
										  CONSTRUCTOR
	**************************************************************************************/

	function new(display:Display) {
		createNoteSystem(display);
	}

	/**************************************************************************************
										  NOTE SYSTEM
	**************************************************************************************/

	// Behind the note system
	private var behindProg(default, null):Program;
	private var behindBuf(default, null):Buffer<Sustain>;

	// Above the note system
	private var frontProg(default, null):Program;
	private var frontBuf(default, null):Buffer<Note>;

	var textureMapProperties:Array<Int> = [];
	var keybindMap:Map<KeyCode, Array<Int>> = [
		KeyCode.A => [0, 1],
		KeyCode.LEFT => [0, 1],
		KeyCode.S => [1, 1],
		KeyCode.DOWN => [1, 1],
		KeyCode.W => [2, 1],
		KeyCode.UP => [2, 1],
		KeyCode.D => [3, 1],
		KeyCode.RIGHT => [3, 1]
	];

	var strumlineMap:Array<Array<Array<Int>>> = [
		[[0, 50], [-90, 162], [90, 274], [180, 386]],
		[[0, 690], [-90, 802], [90, 914], [180, 1026]]
	];

	var strumlinePlayableMap:Array<Bool> = [
		false,
		true
	];

	var numOfReceptors:Int;
	var numOfNotes:Int;

	var scrollSpeed(default, set):Float = 1.0;

	inline function set_scrollSpeed(value:Float) {
		spawnDist = Math.floor(160000 / value);
		despawnDist = Math.floor(40000 / Math.min(value, 1));
		return scrollSpeed = value;
	}

	private var notesToHit(default, null):Array<Note> = [];
	private var sustainsToHold(default, null):Array<Sustain> = [];

	private var spawnPosBottom(default, null):Int;
	private var spawnPosTop(default, null):Int;
	private var spawnDist(default, null):Int = 160000;
	private var despawnDist(default, null):Int = 30000;

	private var currentBottomNote(default, null):Note;

	inline function addNote(note:Note) {
		frontBuf.addElement(note);
	}

	inline function addSustain(sustain:Sustain) {
		behindBuf.addElement(sustain);
	}

	inline function getNote(id:Int) {
		return frontBuf.getElement(id + numOfReceptors);
	}

	function cullTop(pos:Int64) {
		// The buffers must be untouched for this to work. Lel
		while (spawnPosTop != numOfNotes && (getNote(spawnPosTop).data.position - pos).low < spawnDist) {
			spawnPosTop++;
		}
	}

	function cullBottom(pos:Int64) {
		currentBottomNote = getNote(spawnPosBottom);

		if (spawnPosBottom != numOfNotes &&
			((pos +
			(
				((currentBottomNote.data.duration << 2) + currentBottomNote.data.duration)
			)) -
			currentBottomNote.data.position).low - (despawnDist << 1) > despawnDist) {
			spawnPosBottom++;
			Sys.println(spawnPosBottom);
			currentBottomNote = getNote(spawnPosBottom);
		}
	}

	function updateNotes(pos:Int64) {
		for (i in spawnPosBottom...spawnPosTop) {
			var note = getNote(i);

			var data = note.data;
			var index = data.index;
			var lane = data.lane;

			var laneMap = strumlineMap[lane];
			var fullIndex = index + (lane * laneMap.length);

			var position = data.position;

			var rec = frontBuf.getElement(fullIndex);
			var diff = Math.floor(Int64.div(position - pos, 100).low * scrollSpeed);

			var isHit = note.c.aF == 0;

			note.x = rec.x;
			note.y = rec.y + diff;
			note.r = laneMap[index][0];

			var sustain = note.child;
			var sustainExists = sustain != null;
			var dist = despawnDist;

			// The actual input system logic + opponent note hits
			// This shit is very different from other fnf engines since this is peote-view.
			// Do not touch any part of this area unless you know it's critical.

			if (rec.playable) {
				if (!isHit) {
					var noteToHit = notesToHit[fullIndex];
					if ((diff < 160 && noteToHit == null) ||
						(noteToHit != null && position - noteToHit.data.position < 80)) {
						notesToHit[fullIndex] = note;
					}

					if (diff < -200) {
						notesToHit[fullIndex] = null;
						note.c.aF = 0;
						if (sustainExists) sustain.c.aF = 0;
						if (rec.playable) {
							Sys.println('Missed $index');
						}
					}
				}
			} else {
				if (note.c.aF != 0 && diff < 0) {
					note.c.aF = 0;
					sustainsToHold[fullIndex] = note.child;
					rec.confirm();

					if (sustainExists) {
						sustain.followReceptor(rec);
						sustain.w = Math.floor(Math.max(sustain.length - Int64.div(pos - position, 100).low, 0));
					}
				}

				if (sustainExists && sustain.w < 100) {
					rec.reset();
					frontBuf.updateElement(rec);
				}
			}

			if (sustainExists) {
				sustain.speed = scrollSpeed;

				if (!isHit) {
					sustain.followNote(note);
				} else if (sustain.c.aF != 0) {
					if (pos > position + (sustain.length * 100)) {
						rec.reset();
					}

					if (sustain.w > 0) {
						sustain.followReceptor(rec);
						sustain.w = Math.floor(Math.max(sustain.length - Int64.div(pos - position, 100).low, 0));
					}

					if (!rec.idle()) {
						rec.confirm();
						frontBuf.updateElement(rec);
					}
				}

				behindBuf.updateElement(sustain);

				@:privateAccess {
					if (sustain.despawnDist == 0) {
						sustain.despawnDist = despawnDist + (sustain.length * 100);
					}
					dist = sustain.despawnDist;
				}
			}

			frontBuf.updateElement(note);
		}
	}

	function keyPress(code:KeyCode, mod) {
		if (!keybindMap.exists(code)) {
			return;
		}

		var map = keybindMap[code];
		var lane = map[1];
		var index = map[0] + (lane * strumlineMap[lane].length);

		var rec = frontBuf.getElement(index);

		if (!rec.playable) {
			return;
		}

		var noteToHit = notesToHit[index];
		if (noteToHit != null && noteToHit.c.aF != 0) {
			rec.confirm();

			noteToHit.c.aF = 0;
			sustainsToHold[index] = noteToHit.child;

			notesToHit[index] = null;
		} else {
			rec.press();
		}

		frontBuf.updateElement(rec);
	}

	function keyRelease(code:KeyCode, mod) {
		if (!keybindMap.exists(code)) {
			return;
		}

		var map = keybindMap[code];
		var lane = map[1];
		var index = map[0] + (lane * strumlineMap[lane].length);

		var rec = frontBuf.getElement(index);

		if (!rec.playable) {
			return;
		}

		var sustain = sustainsToHold[index];

		if (sustain != null && (sustain.c.aF != 0 && sustain.w > 100)) {
			sustain.c.aF = 0;
			sustainsToHold[index] = null;
		}

		rec.reset();
		frontBuf.updateElement(rec);
	}

	function createNoteSystem(display:Display) {
		for (i in 0...strumlineMap.length) {
			numOfReceptors += strumlineMap[i].length;
		}

		notesToHit.resize(numOfReceptors);
		sustainsToHold.resize(numOfReceptors);

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
				rec.playable = strumlinePlayableMap[j];
				frontBuf.addElement(rec);
			}
		}
	}

	/**************************************************************************************
										   UI SYSTEM
	**************************************************************************************/



	/**************************************************************************************
										   UI SYSTEM
	**************************************************************************************/

	function update(songPos:Float) {
		var pos = ChartConverter.betterInt64FromFloat(songPos * 100);

		cullTop(pos);
		cullBottom(pos);
		updateNotes(pos);
	}
}