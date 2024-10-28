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

	// The actual input system logic, very different from other fnf engines since this is peote-view. (Pretty similar to the last FNF Zenith note system rewrite but it's better)
	// Do not touch any part of this area unless you know it's critical.
	// This is a huge ass system which took only 2 days to fully complete.

	var downScroll(default, null):Bool;

	var onNoteHit:Event<ChartNote->Void>;
	var onNoteMiss:Event<ChartNote->Void>;
	var onSustainComplete:Event<ChartNote->Void>;
	var onSustainRelease:Event<ChartNote->Void>;
	var onKeyPress:Event<KeyCode->Void>;
	var onKeyRelease:Event<KeyCode->Void>;

	// Behind the note system
	private var sustainProg(default, null):Program;
	private var sustainsBuf(default, null):Buffer<Sustain>;

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
		KeyCode.RIGHT => [3, 1],
		KeyCode.Z => [0, 2],
		KeyCode.X => [1, 2],
		KeyCode.N => [2, 2],
		KeyCode.M => [3, 2]
	];

	var strumlineMap:Array<Array<Array<Int>>> = [
		[[0, 9999], [0, 9999], [0, 9999], [0, 9999]],
		[[0, 50], [-90, 162], [90, 274], [180, 386]],
		[[0, 675], [-90, 787], [90, 899], [180, 1011]]
	];

	var strumlinePlayableMap:Array<Bool> = [
		false,
		true,
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
	private var botHitsToCheck(default, null):Array<Bool> = []; // For the receptor confirming to mock human input
	private var playerHitsToCheck(default, null):Array<Bool> = []; // For preventing a key press check from continuing if you hit a note

	private var spawnPosBottom(default, null):Int;
	private var spawnPosTop(default, null):Int;
	private var spawnDist(default, null):Int = 160000;
	private var despawnDist(default, null):Int = 30000;

	private var curTopNote(default, null):Note;
	private var curBottomNote(default, null):Note;

	var hitbox:Float = 10000 / 60;

	inline function addNote(note:Note) {
		notesBuf.addElement(note);
	}

	inline function addSustain(sustain:Sustain) {
		sustainsBuf.addElement(sustain);
	}

	inline function getNote(id:Int) {
		return notesBuf.getElement(id + numOfReceptors);
	}

	function setTime(value:Float) {
		// Setting time in the playfield's note system... It's still the second hardest thing to ever do in it.

		for (i in 0...numOfReceptors) {
			var rec = notesBuf.getElement(i);
			rec.reset();
			notesBuf.updateElement(rec);
		}

		// Clear the list of note inputs and sustain inputs. This is required!
		notesToHit.resize(0);
		sustainsToHold.resize(0);
		botHitsToCheck.resize(0);
		playerHitsToCheck.resize(0);
		notesToHit.resize(numOfReceptors);
		sustainsToHold.resize(numOfReceptors);
		botHitsToCheck.resize(numOfReceptors);
		playerHitsToCheck.resize(numOfReceptors);

		for (i in spawnPosBottom...spawnPosTop) {
			var note = getNote(i);
			note.x = 9999;

			var sustain = note.child;
			if (sustain != null) {
				sustain.c.aF = 0;
				sustain.x = 9999;
				sustain.w = sustain.length;
				sustain.held = false;
				sustainsBuf.updateElement(sustain);
			}

			note.missed = false;
			note.c.aF = 0;
			notesBuf.updateElement(note);
		}

		spawnPosTop = spawnPosBottom = 0;
	}

	function cullTop(pos:Int64) {
		curTopNote = getNote(spawnPosTop);

		while (spawnPosTop != numOfNotes && (curTopNote.data.position - pos).low < spawnDist) {
			spawnPosTop++;
			curTopNote.x = 9999;

			var sustain = curTopNote.child;

			if (sustain != null) {
				sustain.c.aF = Sustain.defaultAlpha;
				sustain.w = sustain.length;
				sustain.x = 9999;
				sustainsBuf.updateElement(sustain);
				sustain.held = false;
			}

			curTopNote.missed = false;
			curTopNote.c.aF = 1;
			notesBuf.updateElement(curTopNote);

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

			var sustain = curBottomNote.child;
			var sustainExists = sustain != null;

			if (sustainExists) {
				sustain.x = 9999;
				sustain.c.aF = Sustain.defaultAlpha;
				sustainsBuf.updateElement(sustain);
				sustain.held = false;
			}

			curBottomNote.missed = false;
			curBottomNote.c.aF = 1;
			notesBuf.updateElement(curBottomNote);

			curBottomNote = getNote(spawnPosBottom);
		}
	}

	function updateNotes(pos:Int64) {
		for (i in spawnPosBottom...spawnPosTop) {
			var note = getNote(i);

			var data = note.data;
			var index = data.index;
			var lane = data.lane;

			var fullIndex = index + (lane * strumlineMap[lane].length);

			var position = data.position;

			var rec = notesBuf.getElement(fullIndex);
			var diff = ((position.low - pos.low) * 0.01) * scrollSpeed;

			var isHit = note.c.aF == 0;

			note.x = rec.x;
			note.y = rec.y + (Math.floor(diff) * (downScroll ? -1 : 1));

			var sustain = note.child;
			var sustainExists = sustain != null;

			if (rec.playable) {
				if (!isHit) {
					var noteToHit = notesToHit[fullIndex];
					var noteToHitExists = noteToHit != null;
					var hitPos = noteToHitExists ? noteToHit.data.position : 0;
					if ((!note.missed && diff < hitbox && !noteToHitExists) ||
						(noteToHitExists && pos - hitPos > (position - hitPos) >> 1)) {
						notesToHit[fullIndex] = note;
					}

					if (diff < -hitbox && !note.missed) {
						note.c.aF = 0.5;
						note.missed = true;

						var data = note.data;
						onNoteMiss.dispatch(data);

						if (sustainExists && !sustain.held) {
							sustain.c.aF = Sustain.defaultMissAlpha;
							sustain.held = true;
							onSustainRelease.dispatch(data);
						}

						notesToHit[fullIndex] = null;
					}
				}
			} else {
				if (botHitsToCheck[fullIndex]) {
					rec.reset();
					notesBuf.updateElement(rec);
					botHitsToCheck[fullIndex] = false;
				}

				if (!isHit && diff < 0) {
					note.c.aF = 0;
					sustainsToHold[fullIndex] = sustain;

					rec.confirm();
					notesBuf.updateElement(rec);

					if (sustainExists) {
						sustain.followReceptor(rec);
						sustain.w = sustain.length - Int64.div(pos - position, 100).low;
						if (sustain.w < 0) sustain.w = 0;
					}

					onNoteHit.dispatch(note.data);
					botHitsToCheck[fullIndex] = !sustainExists;
				}
			}

			if (sustainExists) {
				sustain.speed = scrollSpeed;

				if (!isHit) {
					sustain.followNote(note);
				} else if (sustain.c.aF != 0) {
					if (sustain.w > 0) {
						sustain.followReceptor(rec);
						sustain.w = sustain.length - Int64.div(pos - position, 100).low;
						if (sustain.w < 0) sustain.w = 0;
					}

					if (pos > position + (sustain.length * 100) - 125 && !sustain.held) {
						sustain.held = true;
						if (rec.confirmed()) {
							if (rec.playable) rec.press();
							else rec.reset();
						}
						notesBuf.updateElement(rec);
						onSustainComplete.dispatch(sustain.parent.data);
					}
				}

				sustainsBuf.updateElement(sustain);
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

		if (playerHitsToCheck[index]) {
			return;
		}

		var rec = notesBuf.getElement(index);

		if (!rec.playable) {
			return;
		}

		playerHitsToCheck[index] = true;

		var noteToHit = notesToHit[index];

		if (noteToHit != null && !noteToHit.missed && noteToHit.c.aF != 0) {
			rec.confirm();

			noteToHit.c.aF = 0;
			sustainsToHold[index] = noteToHit.child;

			onNoteHit.dispatch(noteToHit.data);

			notesToHit[index] = null;
		} else rec.press();

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

		playerHitsToCheck[index] = false;

		var rec = notesBuf.getElement(index);

		if (!rec.playable) {
			return;
		}

		var sustain = sustainsToHold[index];

		if (sustain != null && (sustain.c.aF != 0 && sustain.w > 100)) {
			sustain.c.aF = Sustain.defaultMissAlpha;
			sustain.held = true;
			onSustainRelease.dispatch(sustain.parent.data);

			sustainsToHold[index] = null;
		}

		rec.reset();
		notesBuf.updateElement(rec);

		onKeyRelease.dispatch(code);
	}

	function createNoteSystem(display:Display, downScroll:Bool = false) {
		this.downScroll = downScroll;

		onNoteHit = new Event<ChartNote->Void>();
		onNoteMiss = new Event<ChartNote->Void>();
		onSustainComplete = new Event<ChartNote->Void>();
		onSustainRelease = new Event<ChartNote->Void>();
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

		sustainsBuf = new Buffer<Sustain>(8192, 8192, false);
		sustainProg = new Program(sustainsBuf);
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