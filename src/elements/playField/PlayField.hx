package elements.playField;

import lime.ui.KeyCode;
import lime.app.Event;

@:publicFields
class PlayField {

	/**************************************************************************************
										  CONSTRUCTOR
	**************************************************************************************/

	function new(display:Display, downScroll:Bool = false) {
		createNoteSystem(display, downScroll);
	}

	/**************************************************************************************
										  NOTE SYSTEM
	**************************************************************************************/

	var downScroll(default, null):Bool;

	var onNoteHit:Event<Note->Bool->Void>;
	var onNoteMiss:Event<Note->Bool->Void>;
	var onSustainComplete:Event<Sustain->Bool->Void>;
	var onSustainRelease:Event<Sustain->Bool->Void>;
	var onKeyPress:Event<KeyCode->Void>;
	var onKeyRelease:Event<KeyCode->Void>;

	// Behind the note system
	private var sustainProg(default, null):Program;
	private var sustainBuf(default, null):Buffer<Sustain>;

	// Above the note system
	private var frontProg(default, null):Program;
	private var notesBuf(default, null):Buffer<Note>;

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
		[[0, 675], [-90, 787], [90, 899], [180, 1011]]
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
		despawnDist = Math.floor(40000 / Math.min(value, 1.0));
		return scrollSpeed = value;
	}

	private var notesToHit(default, null):Array<Note> = [];
	private var sustainsToHold(default, null):Array<Sustain> = [];

	private var spawnPosBottom(default, null):Int;
	private var spawnPosTop(default, null):Int;
	private var spawnDist(default, null):Int = 160000;
	private var despawnDist(default, null):Int = 30000;

	private var curTopNote(default, null):Note;
	private var curBottomNote(default, null):Note;

	inline function addNote(note:Note) {
		notesBuf.addElement(note);
	}

	inline function addSustain(sustain:Sustain) {
		sustainBuf.addElement(sustain);
	}

	inline function getNote(id:Int) {
		return notesBuf.getElement(id + numOfReceptors);
	}

	function cullTop(pos:Int64) {
		curTopNote = getNote(spawnPosTop);

		while (spawnPosTop != numOfNotes && (curTopNote.data.position - pos).low < spawnDist) {
			spawnPosTop++;
			curTopNote.x = 9999;
			curTopNote = getNote(spawnPosTop);
		}
	}

	function cullBottom(pos:Int64) {
		curBottomNote = getNote(spawnPosBottom);

		while (spawnPosBottom != numOfNotes /* We subtract one because we want to make sure that */ &&
			((pos -
			(
				((curBottomNote.data.duration << 2) + curBottomNote.data.duration) * 100
			)) -
			curBottomNote.data.position).low > despawnDist) {
			spawnPosBottom++;
			curBottomNote.x = 9999;
			Sys.println(spawnPosBottom);

			// Fix for the last sustain not executing the receptor's press animation if it was finished.
			if (spawnPosBottom == numOfNotes - 1) {
				var data = curBottomNote.data;
				var lane = data.lane;

				var rec = notesBuf.getElement(data.index + (strumlineMap[lane].length * lane));

				var sustain = curBottomNote.child;
				if (sustain != null && sustain.w < 100) {
					rec.reset();
					onSustainComplete.dispatch(sustain, rec.playable);
					notesBuf.updateElement(rec);
				}
			}

			curBottomNote = getNote(spawnPosBottom);
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

			var rec = notesBuf.getElement(fullIndex);
			var diff = Math.floor(Int64.div(position - pos, 100).low * scrollSpeed);

			var isHit = note.c.aF == 0;

			note.x = rec.x;
			note.y = rec.y + (diff * (downScroll ? -1 : 1));

			var sustain = note.child;
			var sustainExists = sustain != null;

			// The actual input system logic + opponent note hits
			// This shit is very different from other fnf engines since this is peote-view.
			// Do not touch any part of this area unless you know it's critical.

			if (rec.playable) {
				if (!isHit) {
					var noteToHit = notesToHit[fullIndex];
					var hitPos = noteToHit != null ? noteToHit.data.position : 0;
					if ((diff < 160 && noteToHit == null) ||
						(noteToHit != null && pos - hitPos > (position - hitPos) >> 1)) {
						notesToHit[fullIndex] = note;
					}

					if (diff < -160) {
						notesToHit[fullIndex] = null;
						note.c.aF = 0;
						if (sustainExists) sustain.c.aF = 0;
						onNoteMiss.dispatch(note, rec.playable);
					}
				}
			} else {
				if (!isHit && diff < 0) {
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
					notesBuf.updateElement(rec);
					onSustainComplete.dispatch(sustain, rec.playable);
				}
			}

			if (sustainExists) {
				sustain.speed = scrollSpeed;

				if (!isHit) {
					sustain.followNote(note);
				} else if (sustain.c.aF != 0) {
					if (pos > position + (sustain.length * 100)) {
						onSustainComplete.dispatch(sustain, rec.playable);
						rec.reset();
					}

					if (sustain.w > 0) {
						sustain.followReceptor(rec);
						sustain.w = Math.floor(Math.max(sustain.length - Int64.div(pos - position, 100).low, 0));
					}

					if (!rec.idle()) {
						rec.confirm();
						notesBuf.updateElement(rec);
					}
				}

				sustainBuf.updateElement(sustain);
			}

			notesBuf.updateElement(note);
		}
	}

	function keyPress(code:KeyCode, mod) {
		if (!keybindMap.exists(code)) {
			return;
		}

		var map = keybindMap[code];
		var lane = map[1];
		var index = map[0] + (lane * strumlineMap[lane].length);

		var rec = notesBuf.getElement(index);

		if (!rec.playable) {
			return;
		}

		var noteToHit = notesToHit[index];
		if (noteToHit != null && noteToHit.c.aF != 0) {
			rec.confirm();

			noteToHit.c.aF = 0;
			sustainsToHold[index] = noteToHit.child;

			onNoteHit.dispatch(noteToHit, rec.playable);

			notesToHit[index] = null;
		} else {
			rec.press();
		}

		notesBuf.updateElement(rec);

		onKeyPress.dispatch(code);
	}

	function keyRelease(code:KeyCode, mod) {
		if (!keybindMap.exists(code)) {
			return;
		}

		var map = keybindMap[code];
		var lane = map[1];
		var index = map[0] + (lane * strumlineMap[lane].length);

		var rec = notesBuf.getElement(index);

		if (!rec.playable) {
			return;
		}

		var sustain = sustainsToHold[index];

		if (sustain != null && (sustain.c.aF != 0 && sustain.w > 100)) {
			sustain.c.aF = 0;
			onSustainRelease.dispatch(sustain, rec.playable);

			sustainsToHold[index] = null;
		}

		rec.reset();
		notesBuf.updateElement(rec);

		onKeyRelease.dispatch(code);
	}

	function createNoteSystem(display:Display, downScroll:Bool = false) {
		this.downScroll = downScroll;

		onNoteHit = new Event<Note->Bool->Void>();
		onNoteMiss = new Event<Note->Bool->Void>();
		onSustainComplete = new Event<Sustain->Bool->Void>();
		onSustainRelease = new Event<Sustain->Bool->Void>();
		onKeyPress = new Event<KeyCode->Void>();
		onKeyRelease = new Event<KeyCode->Void>();

		for (i in 0...strumlineMap.length) {
			numOfReceptors += strumlineMap[i].length;
		}

		notesToHit.resize(numOfReceptors);
		sustainsToHold.resize(numOfReceptors);

		// Note to self: set the texture size exactly to the image's size

		// NOTE SHEET SETUP
		TextureSystem.createTiledTexture("noteTex", "assets/notes/normal/noteSheet.png", 4);

		notesBuf = new Buffer<Note>(8192, 8192, false);
		frontProg = new Program(notesBuf);
		frontProg.blendEnabled = true;
		TextureSystem.setTexture(frontProg, "noteTex", "noteTex");

		var tex1 = TextureSystem.getTexture("noteTex");
		textureMapProperties.push(tex1.width >> 2);
		textureMapProperties.push(tex1.height);

		// SUSTAIN SETUP

		TextureSystem.createTexture("sustainTex", "assets/notes/normal/sustain.png");

		sustainBuf = new Buffer<Sustain>(8192, 8192, false);
		sustainProg = new Program(sustainBuf);
		sustainProg.blendEnabled = true;

		var tex2 = TextureSystem.getTexture("sustainTex");

		Sustain.init(sustainProg, "sustainTex", tex2);
		textureMapProperties.push(tex2.width);
		textureMapProperties.push(tex2.height);

		display.addProgram(sustainProg);
		display.addProgram(frontProg);

		for (j in 0...strumlineMap.length) {
			var map = strumlineMap[j];
			for (i in 0...map.length) {
				var rec = new Note(0, downScroll ? display.height - 150 : 50, textureMapProperties[0], textureMapProperties[1]);
				rec.r = map[i][0];
				rec.x = map[i][1];
				rec.playable = strumlinePlayableMap[j];
				notesBuf.addElement(rec);
			}
		}
	}

	/**************************************************************************************
										   UI SYSTEM
	**************************************************************************************/

	// Behind the ui system
	private var healthBarBuf(default, null):Buffer<HealthBar>;
	private var healthBarProg(default, null):Program;

	function createHUD() {
		/*healthBarBuf = new Buffer<HealthBar>(1, 0, false);
		healthBarProg = new Program(healthBarBuf);*/
	}

	/**************************************************************************************
									   REST OF THIS SHIT
	**************************************************************************************/

	function update(songPos:Float) {
		var pos = ChartConverter.betterInt64FromFloat(songPos * 100);

		cullTop(pos);
		cullBottom(pos);
		updateNotes(pos);
	}
}