package menus;

import lime.ui.KeyCode;
import lime.app.Event;
import lime.app.Application;

/**
	The UI and note system.
	This includes audio which present the [instrumentals] and [voicesTracks].
**/
@:publicFields
class PlayField {
	var display(default, null):Display;

	var disposed(default, null):Bool;
	var paused(default, null):Bool;
	var botplay:Bool;

	/**************************************************************************************
										  CONSTRUCTOR
	**************************************************************************************/

	function new(songName:String) {
		chart = new Chart('assets/songs/$songName');
	}

	function init(display:Display, downScroll:Bool) {
		this.downScroll = downScroll;
		this.display = display;

		createNoteSystem(display, chart.header.mania);
		createHUD(display);
		craetePauseScreen();
		loadAudio();
		finishPlayfield(display);
	}

	/**************************************************************************************
										  NOTE SYSTEM
	**************************************************************************************/

	// The actual input system logic, very different from other fnf engines since this is peote-view. (Pretty similar to the last FNF Zenith note system rewrite but it's better)
	// Do not touch any part of this area unless you know it's critical.
	// This is a huge ass system which took only 2 days to fully complete.

	var downScroll(default, null):Bool;
	var practiceMode:Bool;

	var onStartSong:Event<Chart->Void>;
	var onStopSong:Event<Chart->Void>;
	var onDeath:Event<Chart->Void>;

	var onNoteHit:Event<ChartNote->Int->Void>;
	var onNoteMiss:Event<ChartNote->Void>;
	var onSustainComplete:Event<ChartNote->Void>;
	var onSustainRelease:Event<ChartNote->Void>;
	var onKeyPress:Event<KeyCode->Void>;
	var onKeyRelease:Event<KeyCode->Void>;

	// Behind the note system
	private var sustainProg(default, null):Program;
	private var sustainsBuf(default, null):Buffer<Sustain>;

	// Above the note system
	private var notesProg(default, null):Program;
	private var notesBuf(default, null):Buffer<Note>;

	private var sustainDimensions:Array<Int> = [];

	// CUSTOMIZATION SECTION //

	var keybindMaps:Array<Map<KeyCode, Array<Int>>> = [
	[],
	[],
	[],
	[
		KeyCode.A => [0, 1],
		KeyCode.S => [1, 1],
		KeyCode.W => [2, 1],
		KeyCode.D => [3, 1],
		KeyCode.LEFT => [0, 1],
		KeyCode.DOWN => [1, 1],
		KeyCode.UP => [2, 1],
		KeyCode.RIGHT => [3, 1]
	],
	[
		KeyCode.A => [0, 1],
		KeyCode.S => [1, 1],
		KeyCode.SPACE => [2, 1],
		KeyCode.W => [3, 1],
		KeyCode.D => [4, 1],
		KeyCode.LEFT => [0, 1],
		KeyCode.DOWN => [1, 1],
		KeyCode.UP => [3, 1],
		KeyCode.RIGHT => [4, 1]
	],
	[
		KeyCode.S => [0, 1],
		KeyCode.D => [1, 1],
		KeyCode.F => [2, 1],
		KeyCode.J => [3, 1],
		KeyCode.K => [4, 1],
		KeyCode.L => [5, 1]
	],
	[
		KeyCode.S => [0, 1],
		KeyCode.D => [1, 1],
		KeyCode.F => [2, 1],
		KeyCode.SPACE => [3, 1],
		KeyCode.J => [4, 1],
		KeyCode.K => [5, 1],
		KeyCode.L => [6, 1]
	], [
		KeyCode.A => [0, 1],
		KeyCode.S => [1, 1],
		KeyCode.D => [2, 1],
		KeyCode.F => [3, 1],
		KeyCode.H => [4, 1],
		KeyCode.J => [5, 1],
		KeyCode.K => [6, 1],
		KeyCode.L => [7, 1]
	], [
		KeyCode.A => [0, 1],
		KeyCode.S => [1, 1],
		KeyCode.D => [2, 1],
		KeyCode.F => [3, 1],
		KeyCode.SPACE => [4, 1],
		KeyCode.H => [5, 1],
		KeyCode.J => [6, 1],
		KeyCode.K => [7, 1],
		KeyCode.L => [8, 1]
	]];

	var keybindMap:Map<KeyCode, Array<Int>>;

	var strumlineRotationMap:Array<Int>;

	var strumlineMap:Array<Array<Array<Float>>>;

	var strumlinePlayableMap:Array<Bool>;

	var flipHealthBar:Bool;

	///////////////////////////

	var numOfReceptors:Int;
	var numOfNotes:Int;
	var precalculatedIndexThing:Array<Int> = [];

	var scrollSpeed(default, set):Float = 1.0;

	inline function set_scrollSpeed(value:Float) {
		spawnDist = Math.floor(160000 / value);
		despawnDist = Math.floor(40000 / Math.min(value, 1.0));
		hitbox = 200 * scrollSpeed;
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

	var hitbox:Float = 200;

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
		if (disposed || !songStarted || songEnded) return;

		if (value < 0) {
			value = 0;
		}

		songPosition = value;

		for (inst in instrumentals) {
			inst.time = songPosition;
			inst.update();
		}

		for (voices in voicesTracks) {
			voices.time = songPosition;
			voices.update();
		}

		hideRatingPopup();

		for (i in 0...numOfReceptors) {
			var rec = notesBuf.getElement(i);
			rec.reset();
			notesBuf.updateElement(rec);
		}

		// Clear the list of note inputs and sustain inputs. This is required!
		notesToHit.resize(0);
		sustainsToHold.resize(0);
		playerHitsToCheck.resize(0);
		notesToHit.resize(numOfReceptors);
		sustainsToHold.resize(numOfReceptors);
		playerHitsToCheck.resize(numOfReceptors);

		for (i in spawnPosBottom...spawnPosTop) {
			var note = getNote(i);
			note.x = 999999999;

			var sustain = note.child;
			if (sustain != null) {
				sustain.c.aF = 0;
				sustain.x = 999999999;
				sustain.w = sustain.length;
				sustain.held = false;
				sustainsBuf.updateElement(sustain);
			}

			note.missed = false;
			note.c.aF = 0;
			notesBuf.updateElement(note);
		}

		// TODO: Make it so that you don't have to go through every single note before you reach the specific position.

		spawnPosTop = spawnPosBottom = 0;
	}

	function cullTop(pos:Int64) {
		if (disposed) return;

		curTopNote = getNote(spawnPosTop);

		while (spawnPosTop != numOfNotes && (curTopNote.data.position - pos).low < spawnDist) {
			spawnPosTop++;
			curTopNote.x = 999999999;

			var sustain = curTopNote.child;

			if (sustain != null) {
				sustain.c.aF = Sustain.defaultAlpha;
				sustain.w = sustain.length;
				sustain.x = 999999999;
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
		if (disposed) return;

		curBottomNote = getNote(spawnPosBottom);

		while (spawnPosBottom != numOfNotes /* We subtract one because we want to make sure that */ &&
			((pos -
			(
				((curBottomNote.data.duration << 2) + curBottomNote.data.duration) * 100
			)) -
			curBottomNote.data.position).low > despawnDist) {
			spawnPosBottom++;

			curBottomNote.x = 999999999;

			var sustain = curBottomNote.child;
			var sustainExists = sustain != null;

			if (sustainExists) {
				sustain.x = 999999999;
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
		if (disposed) return;

		for (i in spawnPosBottom...spawnPosTop) {
			updateNote(pos, getNote(i));
		}
	}

	// Do not fuck with this EVER
	private function updateNote(pos:Int64, note:Note) {
		var data = note.data;
		var index = data.index;
		var lane = data.lane;

		var fullIndex = index + precalculatedIndexThing[lane];

		var position = data.position;

		var rec = notesBuf.getElement(fullIndex);

		var diff = (Int64.toInt(position - pos) * 0.01) * scrollSpeed;
		var leftover = Math.floor(Int64.toInt(pos - position) * 0.01);

		var isHit = note.c.aF == 0;

		note.x = rec.x;
		note.y = rec.y + (Math.floor(diff) * (downScroll ? -1 : 1));

		var sustain = note.child;
		var sustainExists = sustain != null;

		var playable = rec.playable && !botplay;

		if (playable) {
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

					onNoteMiss.dispatch(data);

					if (sustainExists && !sustain.held) {
						sustain.c.aF = Sustain.defaultMissAlpha;
						sustain.held = true;
						onSustainRelease.dispatch(data);
					}

					notesToHit[fullIndex] = null;

					hideRatingPopup();
				}
			}
		} else {
			if (botHitsToCheck[fullIndex]) {
				if (!rec.idle()) {
					rec.reset();
					notesBuf.updateElement(rec);
					botHitsToCheck[fullIndex] = false;
				}
			}

			if (!isHit && diff < 0) {
				note.c.aF = 0;
				sustainsToHold[fullIndex] = sustain;

				if (!rec.confirmed()) {
					rec.confirm();
					notesBuf.updateElement(rec);
				}

				if (sustainExists) {
					sustain.followNote(rec);
					sustain.w = sustain.length - leftover;
					if (sustain.w < 0) sustain.w = 0;
				}

				onNoteHit.dispatch(data, 0);
				botHitsToCheck[fullIndex] = !sustainExists;
			}
		}

		if (sustainExists) {
			sustain.speed = scrollSpeed;

			if (!isHit) {
				sustain.followNote(note);
			} else if (sustain.c.aF != 0) {
				if (sustain.w > 0) {
					sustain.followNote(rec);
					sustain.w = sustain.length - leftover;
					if (sustain.w < 0) sustain.w = 0;
				}

				if (pos > position + (sustain.length * 100) - 75 && !sustain.held && !note.missed) {
					sustain.held = true;
					if (rec.confirmed()) {
						if (playable) rec.press();
						else rec.reset();
					}
					notesBuf.updateElement(rec);
					onSustainComplete.dispatch(data);
				}
			}

			sustainsBuf.updateElement(sustain);
		}

		notesBuf.updateElement(note);
	}

	function keyPress(code:KeyCode, mod) {
		if (disposed || botplay) return;

		if (!keybindMap.exists(code)) {
			return;
		}

		var map = keybindMap[code];
		var lane = map[1];
		var index = map[0] + precalculatedIndexThing[lane];

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
			if (!rec.confirmed()) {
				rec.confirm();
				notesBuf.updateElement(rec);
			}

			noteToHit.c.aF = 0;
			sustainsToHold[index] = noteToHit.child;

			var data = noteToHit.data;

			onNoteHit.dispatch(data, Int64.toInt(Int64.div(data.position - Tools.betterInt64FromFloat((songPosition + latencyCompensation) * 100), 100)));

			notesToHit[index] = null;
		} else {
			if (!rec.pressed()) {
				rec.press();
				notesBuf.updateElement(rec);
			}
		}

		onKeyPress.dispatch(code);
	}

	function keyRelease(code:KeyCode, mod) {
		if (disposed || botplay) return;

		if (!keybindMap.exists(code)) {
			return;
		}

		var map = keybindMap[code];
		var lane = map[1];
		var index = map[0] + precalculatedIndexThing[lane];

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

			hideRatingPopup();
		}

		if (!rec.idle()) {
			rec.reset();
			notesBuf.updateElement(rec);
		}

		onKeyRelease.dispatch(code);
	}

	function createNoteSystem(display:Display, mania:Int = 4) {
		UISprite.healthBarDimensions = Tools.parseHealthBarConfig('assets/ui');
		Note.offsetAndSizeFrames = Tools.parseFrameOffsets('assets/notes');

		if (mania > 16) mania = 16;

		keybindMap = keybindMaps[mania > 9 ? 8 : mania < 4 ? 3 : mania - 1];

		// This shit is fucking unbearable as FUCK
		// But it's fine for now since it supports a max of 16 keys
		switch (mania) {
			case 5:
				strumlineRotationMap = [0, -90, 90, 90, 180];

				strumlineMap = [
					[for (i in 0...5) [strumlineRotationMap[i], 50 + (97 * i), 0.9]],
					[for (i in 0...5) [strumlineRotationMap[i], 678 + (97 * i), 0.9]]
				];

			case 6:
				strumlineRotationMap = [0, -90, 180, 0, 90, 180];

				strumlineMap = [
					[for (i in 0...6) [strumlineRotationMap[i], 50 + (83 * i), 0.83]],
					[for (i in 0...6) [strumlineRotationMap[i], 676 + (83 * i), 0.83]]
				];

			case 7:
				strumlineRotationMap = [0, -90, 180, 90, 0, 90, 180];

				strumlineMap = [
					[for (i in 0...7) [strumlineRotationMap[i], 50 + (75 * i), 0.77]],
					[for (i in 0...7) [strumlineRotationMap[i], 668 + (75 * i), 0.77]]
				];

			case 8:
				strumlineRotationMap = [0, -90, 90, 180, 0, -90, 90, 180];

				strumlineMap = [
					[for (i in 0...8) [strumlineRotationMap[i], 50 + (70 * i), 0.68]],
					[for (i in 0...8) [strumlineRotationMap[i], 663 + (70 * i), 0.68]]
				];

			case 9:
				strumlineRotationMap = [0, -90, 90, 180, 90, 0, -90, 90, 180];

				strumlineMap = [
					[for (i in 0...9) [strumlineRotationMap[i], 50 + (56 * i), 0.64]],
					[for (i in 0...9) [strumlineRotationMap[i], 655 + (56 * i), 0.64]]
				];

			case 10:
				strumlineRotationMap = [0, -90, 90, 180, -90, 90, 0, -90, 90, 180];

				strumlineMap = [
					[for (i in 0...10) [strumlineRotationMap[i], 47 + (53 * i), 0.59]],
					[for (i in 0...10) [strumlineRotationMap[i], 645 + (53 * i), 0.59]]
				];

			case 11:
				strumlineRotationMap = [0, -90, 90, 180, 0, 90, 180, 0, -90, 90, 180];

				strumlineMap = [
					[for (i in 0...11) [strumlineRotationMap[i], 44 + (50 * i), 0.57]],
					[for (i in 0...11) [strumlineRotationMap[i], 639 + (50 * i), 0.57]]
				];

			case 12:
				strumlineRotationMap = [0, -90, 90, 180, 0, -90, 90, 180, 0, -90, 90, 180];

				strumlineMap = [
					[for (i in 0...12) [strumlineRotationMap[i], 40 + (47 * i), 0.4777]],
					[for (i in 0...12) [strumlineRotationMap[i], 631 + (47 * i), 0.4777]]
				];

			case 13:
				strumlineRotationMap = [0, -90, 90, 180, 0, -90, 90, 90, 180, 0, -90, 90, 180];

				strumlineMap = [
					[for (i in 0...13) [strumlineRotationMap[i], 38 + (42 * i), 0.432]],
					[for (i in 0...13) [strumlineRotationMap[i], 628 + (42 * i), 0.432]]
				];

			case 14:
				strumlineRotationMap = [0, -90, 90, 180, 0, -90, 180, 0, 90, 180, 0, -90, 90, 180];

				strumlineMap = [
					[for (i in 0...14) [strumlineRotationMap[i], 36 + (41 * i), 0.42]],
					[for (i in 0...14) [strumlineRotationMap[i], 627 + (41 * i), 0.42]]
				];

			case 15:
				strumlineRotationMap = [0, -90, 90, 180, 0, -90, 180, 90, 0, 90, 180, 0, -90, 90, 180];

				strumlineMap = [
					[for (i in 0...15) [strumlineRotationMap[i], 34 + (39 * i), 0.405]],
					[for (i in 0...15) [strumlineRotationMap[i], 626 + (39 * i), 0.405]]
				];

			case 16:
				strumlineRotationMap = [0, -90, 90, 180, 0, -90, 180, -90, 90, 0, 90, 180, 0, -90, 90, 180];

				strumlineMap = [
					[for (i in 0...16) [strumlineRotationMap[i], 30 + (37 * i), 0.375]],
					[for (i in 0...16) [strumlineRotationMap[i], 626 + (37 * i), 0.375]]
				];

			default:
				strumlineRotationMap = [0, -90, 90, 180];

				strumlineMap = [
					[for (i in 0...4) [strumlineRotationMap[i], 50 + (112 * i), 1]],
					[for (i in 0...4) [strumlineRotationMap[i], 680 + (112 * i), 1]]
				];

		}

		if (strumlineMap.length > 4) strumlineMap.resize(4);

		strumlinePlayableMap = [false, true];

		onStartSong = new Event<Chart->Void>();
		onStopSong = new Event<Chart->Void>();
		onDeath = new Event<Chart->Void>();

		onNoteHit = new Event<ChartNote->Int->Void>();
		onNoteMiss = new Event<ChartNote->Void>();
		onSustainComplete = new Event<ChartNote->Void>();
		onSustainRelease = new Event<ChartNote->Void>();
		onKeyPress = new Event<KeyCode->Void>();
		onKeyRelease = new Event<KeyCode->Void>();

		for (i in 0...strumlineMap.length) {
			numOfReceptors += strumlineMap[i].length;
			if (i != 0) precalculatedIndexThing.push(strumlineMap[i-1].length);
			else precalculatedIndexThing.push(0);
		}

		notesToHit.resize(numOfReceptors);
		sustainsToHold.resize(numOfReceptors);

		// Note to self: set the texture size exactly to the image's size

		// NOTE SHEET SETUP

		notesBuf = new Buffer<Note>(16384, 16384, false);
		notesProg = new Program(notesBuf);
		notesProg.blendEnabled = true;

		TextureSystem.setTexture(notesProg, "noteTex", "noteTex");

		var tex1 = TextureSystem.getTexture("noteTex");

		// SUSTAIN SETUP
		sustainsBuf = new Buffer<Sustain>(16384, 16384, false);
		sustainProg = new Program(sustainsBuf);
		sustainProg.blendEnabled = true;

		var tex2 = TextureSystem.getTexture("sustainTex");

		Sustain.init(sustainProg, "sustainTex", tex2);
		sustainDimensions.push(tex2.width);
		sustainDimensions.push(tex2.height);

		display.addProgram(sustainProg);
		display.addProgram(notesProg);

		for (j in 0...strumlineMap.length) {
			var map = strumlineMap[j];
			for (i in 0...map.length) {
				var strum = map[i];
				var rec = new Note(0, downScroll ? display.height - 150 : 50, 0, 0);
				rec.r = strum[0];
				rec.x = Math.floor(strum[1]);
				rec.scale = strum[2];
				rec.playable = strumlinePlayableMap[j];
				notesBuf.addElement(rec);
			}
		}
	}

	/**************************************************************************************
										   UI SYSTEM
	**************************************************************************************/

	var countdownDisp:CountdownDisplay;

	private var uiBuf(default, null):Buffer<UISprite>;
	private var uiProg(default, null):Program;
	private var scoreTxtProg(default, null):Program;
	private var watermarkTxtProg(default, null):Program;

	var scoreTxt:Text;
	var watermarkTxt:Text;

	var ratingPopup:UISprite;
	var comboNumbers:Array<UISprite> = [];

	var healthBarParts:Array<UISprite> = [];
	var healthBarBG:UISprite;

	var healthIcons:Array<UISprite> = [];
	var healthIconIDs:Array<Array<Int>> = [[0, 1], [2, 3]];
	var healthIconColors:Array<Array<Color>> = [
		[Color.RED1, Color.RED1, Color.RED1, Color.RED1, Color.RED1, Color.RED1],
		[Color.LIME, Color.LIME, Color.LIME, Color.LIME, Color.LIME, Color.LIME]
	];

	var healthBarWS:Int;
	var healthBarHS:Int;

	var health:Float = 0.5;

	/**
		Updates the rating popup.
	**/
	function updateRatingPopup(deltaTime:Float) {
		if (disposed) return;

		if (ratingPopup == null) return;

		if (ratingPopup.a != 0) {
			ratingPopup.a -= ratingPopup.c.aF * (deltaTime * 0.005);
		}

		if (ratingPopup.y != 320) {
			ratingPopup.y -= (ratingPopup.y - 320) * (deltaTime * 0.0125);
			uiBuf.updateElement(ratingPopup);
		}
	}

	/**
		Updates the combo numbers.
	**/
	function updateComboNumbers() {
		if (disposed) return;

		var num:Float = combo;

		for (i in 0...10) {
			var comboNumber = comboNumbers[i];

			if (comboNumber == null) continue;

			var digit = Math.floor(num) % 10;

			comboNumber.y = ratingPopup.y + (ratingPopup.h + 5);
			comboNumber.a = (Math.floor(num) != 0) ? ratingPopup.a : 0.0;

			if (comboNumber.curID != digit) {
				comboNumber.changeID(digit);
			}

			uiBuf.updateElement(comboNumber);

			num *= 0.1;
		}
	}

	/**
		Updates the health bar.
	**/
	function updateHealthBar() {
		if (disposed) return;

		var part1 = healthBarParts[0];

		if (part1 == null) return;

		var healthIconColor = healthIconColors[flipHealthBar ? 1 : 0];

		part1.c1 = healthIconColor[0];
		part1.c2 = healthIconColor[1];
		part1.c3 = healthIconColor[2];
		part1.c4 = healthIconColor[3];
		part1.c5 = healthIconColor[4];
		part1.c6 = healthIconColor[5];

		part1.w = (healthBarBG.w - Math.floor(healthBarBG.w * (flipHealthBar ? 1 - health : health))) - (healthBarWS << 1);
		part1.x = healthBarBG.x + healthBarWS;

		if (part1.w < 0) part1.w = 0;

		uiBuf.updateElement(part1);

		var part2 = healthBarParts[1];

		if (part2 == null) return;

		var healthIconColor = healthIconColors[flipHealthBar ? 0 : 1];

		part2.c1 = healthIconColor[0];
		part2.c2 = healthIconColor[1];
		part2.c3 = healthIconColor[2];
		part2.c4 = healthIconColor[3];
		part2.c5 = healthIconColor[4];
		part2.c6 = healthIconColor[5];

		part2.w = (healthBarBG.w - part1.w) - (healthBarWS << 1);
		part2.x = (healthBarBG.x + part1.w) + healthBarWS;

		if (part2.w < 0) part2.w = 0;

		uiBuf.updateElement(part2);
	}

	/**
		Updates the health icons.
	**/
	function updateHealthIcons() {
		if (disposed) return;

		var part1 = healthBarParts[1];

		if (part1 == null) return;

		var health = health;
		var icons = healthIcons;
		var ids = healthIconIDs;

		var oppIcon = icons[0];
		var plrIcon = icons[1];

		var oppIcon = healthIcons[0];
		oppIcon.x = part1.x - 118;

		var plrIcon = healthIcons[1];
		plrIcon.x = part1.x - 18;

		var oppIco = flipHealthBar ? plrIcon : oppIcon;
		var plrIco = flipHealthBar ? oppIcon : plrIcon;

		if (health > 0.75) {
			oppIco.changeID(ids[0][1]);
		} else {
			oppIco.changeID(ids[0][0]);
		}

		if (health < 0.25) {
			plrIco.changeID(ids[1][1]);
		} else {
			plrIco.changeID(ids[1][0]);
		}

		uiBuf.updateElement(oppIcon);
		uiBuf.updateElement(plrIcon);
	}

	/**
		Hides the rating popup.
	**/
	inline function hideRatingPopup() {
		if (disposed) return;

		ratingPopup.a = 0.0;
		uiBuf.updateElement(ratingPopup);
	}

	/**
		Wakes up the rating popup.
	**/
	inline function respondWithRatingID(id:Int) {
		if (disposed) return;

		ratingPopup.a = 1.0;
		ratingPopup.y = 300;
		ratingPopup.changeID(id);
		uiBuf.updateElement(ratingPopup);
	}

	/**
		Create the playfield UI.
	**/
	function createHUD(display:Display) {
		healthBarWS = UISprite.healthBarDimensions[2];
		healthBarHS = UISprite.healthBarDimensions[3];

		uiBuf = new Buffer<UISprite>(2048, 2048, false);
		uiProg = new Program(uiBuf);
		uiProg.blendEnabled = true;

		UISprite.init(uiProg, "uiTex", TextureSystem.getTexture("uiTex"));

		display.addProgram(uiProg);

		// RATING POPUP SETUP
		ratingPopup = new UISprite();
		ratingPopup.type = RATING_POPUP;
		ratingPopup.changeID(0);
		ratingPopup.x = 500;
		ratingPopup.y = 360;
		ratingPopup.a = 0.0;
		uiBuf.addElement(ratingPopup);

		comboNumbers.resize(10);

		// COMBO NUMBERS SETUP
		for (i in 0...10) {
			var comboNumber = comboNumbers[i] = new UISprite();
			comboNumber.type = COMBO_NUMBER;
			comboNumber.changeID(0);
			comboNumber.x = ratingPopup.x + 208 - ((comboNumber.w + 2) * i);
			comboNumber.y = ratingPopup.y + (ratingPopup.h + 5);
			comboNumber.a = 0.0;
			uiBuf.addElement(comboNumber);
		}

		// HEALTH BAR SETUP
		healthBarBG = new UISprite();
		healthBarBG.type = HEALTH_BAR;
		healthBarBG.changeID(0);
		healthBarBG.x = 275;
		healthBarBG.y = downScroll ? 90 : 630;

		// HEALTH BAR PART SETUP
		for (i in 0...2) {
			var part = healthBarParts[i] = new UISprite();
			part.gradientMode = 1;
			part.clipWidth = part.clipHeight = part.clipSizeX = part.clipSizeY = 0;
			part.h = healthBarBG.h - (healthBarHS << 1);
			part.y = healthBarBG.y + healthBarHS;

			var healthIconColor = healthIconColors[i];

			part.c1 = healthIconColor[0];
			part.c2 = healthIconColor[1];
			part.c3 = healthIconColor[2];
			part.c4 = healthIconColor[3];
			part.c5 = healthIconColor[4];
			part.c6 = healthIconColor[5];

			// GRADIENT TEST
			/*part.c2 = Color.YELLOW;
			part.c3 = Color.BLUE;
			part.c4 = Color.MAGENTA;
			part.c5 = Color.BLACK;
			part.c6 = Color.CYAN;*/

			uiBuf.addElement(part);
		}

		uiBuf.addElement(healthBarBG);

		updateHealthBar();

		// HEALTH ICONS SETUP

		var x = healthBarBG.x + (healthBarBG.w >> 1);

		var oppIcon = healthIcons[0] = new UISprite();
		oppIcon.type = HEALTH_ICON;
		oppIcon.changeID(healthIconIDs[0][0]);

		var plrIcon = healthIcons[1] = new UISprite();
		plrIcon.type = HEALTH_ICON;
		plrIcon.changeID(healthIconIDs[1][0]);

		oppIcon.y = plrIcon.y = healthBarBG.y - 75;
		plrIcon.flip = 1;

		uiBuf.addElement(oppIcon);
		uiBuf.addElement(plrIcon);

		updateHealthIcons();

		// TEXT SETUP

		scoreTxt = new Text(0, 0);

		watermarkTxt = new Text(0, 0, "FV TEST BUILD - Keybinds: -/= to change time, F8 to flip bar, and [/] to adjust latency by 10ms");
		watermarkTxt.x = 2;

		scoreTxtProg = new Program(scoreTxt.buffer);
		scoreTxtProg.blendEnabled = true;

		watermarkTxtProg = new Program(watermarkTxt.buffer);
		watermarkTxtProg.blendEnabled = true;

		TextureSystem.setTexture(scoreTxtProg, 'vcrTex', 'vcrTex');

		display.addProgram(scoreTxtProg);

		TextureSystem.setTexture(watermarkTxtProg, 'vcrTex', 'vcrTex');

		display.addProgram(watermarkTxtProg);
		watermarkTxt.y = watermarkTxtProg.displays[0].height - (watermarkTxt.height + 2);
	}

	/**************************************************************************************
									  PAUSE SCREEN SYSTEM                                  
	**************************************************************************************/

	var pauseBG(default, null):UISprite;
	var pauseOptions(default, null):Array<UISprite>;

	function craetePauseScreen() {
		var pauseBG = new UISprite();
		pauseBG.clipWidth = pauseBG.clipHeight = pauseBG.clipSizeX = pauseBG.clipSizeY = 0;

		uiBuf.addElement(pauseBG);

		for (i in 0...3) {
			var option = new UISprite();
			option.type = PAUSE_OPTION;
			option.changeID(i);
			option.y = 160 + (160 * i);
			uiBuf.addElement(option);
		}
	}

	/**************************************************************************************
											 AUDIO
	**************************************************************************************/

	var instrumentals:Map<String, Sound> = [];
	var voicesTracks:Map<String, Sound> = [];

	function loadAudio() {
		var inst = new Sound();
		inst.fromFile(chart.header.instDir);

		instrumentals.set("base", inst);

		var voices = new Sound();
		voices.fromFile(chart.header.voicesDir);

		voicesTracks.set("base", voices);
	}

	/**************************************************************************************
									 THE REST OF THIS SHIT
	**************************************************************************************/

	var songStarted(default, null):Bool;
	var songEnded(default, null):Bool;

	/**
		Finalize the playfield.
	**/
	function finishPlayfield(display:Display) {
		var timeSig = chart.header.timeSig;
		Main.conductor.changeBpmAt(0, chart.header.bpm, timeSig[0], timeSig[1]);

		scrollSpeed = chart.header.speed;

		songPosition = -Main.conductor.crochet * 4.5;

		Main.conductor.onBeat.add(beatHit);
		Main.conductor.onMeasure.add(measureHit);

		countdownDisp = new CountdownDisplay(display, uiBuf);

		var dimensions = sustainDimensions;

		var sW = dimensions[0];
		var sH = dimensions[1];

		var notes = chart.file;

		// Create a while loop instead that accepts Int64's cause haxe's for loop syntax sugar doesn't have it
		#if FV_BIG_BYTES
		var i:Int64 = 0;
		var len:Int64 = notes.length;
		while (i < len)
		#else
		for (i in 0...notes.length)
		#end
		{
			var note = notes.getNote(i);

			var strum = strumlineMap[note.lane][note.index];

			var noteSpr = new Note(999999999, 0, 0, 0);
			noteSpr.data = note;
			noteSpr.toNote();
			noteSpr.r = strum[0];
			noteSpr.scale = strum[2];
			addNote(noteSpr);

			if (note.duration > 5) {
				var susSpr = new Sustain(999999999, 0, sW, sH);
				susSpr.length = ((note.duration << 2) + note.duration) - 25;
				susSpr.w = susSpr.length;
				susSpr.r = downScroll ? -90 : 90;
				susSpr.scale = noteSpr.scale;
				susSpr.c.aF = Sustain.defaultAlpha;
				addSustain(susSpr);

				susSpr.parent = noteSpr;
				noteSpr.child = susSpr;
			}

			#if FV_BIG_BYTES i++; #end
		}

		numOfNotes = notesBuf.length - numOfReceptors;

		onNoteHit.add(hitNote);
		onNoteMiss.add(missNote);
		onSustainComplete.add(completeSustain);
		onSustainRelease.add(releaseSustain);
		onStartSong.add(startSong);
		onStopSong.add(stopSong);
		onDeath.add(gameOver);
	}

	var score:Int128 = 0;
	var misses:Int128 = 0;
	var combo:Int;

	var songPosition:Float;

	var chart:Chart;

	var latencyCompensation:Int;

	/**
		Update the playfield.
	**/
	function update(deltaTime:Float) {
		if (disposed || paused) return;

		if (display.zoom != 1) {
			display.zoom -= (display.zoom - 1) * 0.15;
		}

		// Trigger a game over
		if (health < 0 && !disposed) {
			onDeath.dispatch(chart);
			return;
		}

		var firstInst = instrumentals["base"];

		// We just have to resync the vocals with the old method cause miniaudio sounds are almost perfectly synced with others.
		if (songStarted && !RenderingMode.enabled) {
			for (vocals in voicesTracks) {
				if (vocals.time - firstInst.time > 10) {
					vocals.time = firstInst.time;
				}
			}
		}

		scoreTxt.text = 'Score: $score, Misses: $misses';
		scoreTxt.x = Math.floor(healthBarBG.x) + ((healthBarBG.w - scoreTxt.width) >> 1);
		scoreTxt.y = Math.floor(healthBarBG.y) + (healthBarBG.h + 2);

		watermarkTxt.text = 'FV TEST BUILD | - and = to change time | F8 to flip bar | [ and ] to adjust latency (${latencyCompensation}ms)';

		if (songPosition > firstInst.length && !songEnded) {
			onStopSong.dispatch(chart);
		}

		if (!songStarted || songEnded || RenderingMode.enabled) {
			songPosition += deltaTime;
		} else {
			firstInst.update();
			songPosition = firstInst.time;
		}

		Main.conductor.time = songPosition + latencyCompensation;

		songPosition += latencyCompensation;

		var pos = Tools.betterInt64FromFloat(songPosition * 100);

		// NOTE SYSTEM
		cullTop(pos);
		cullBottom(pos);
		updateNotes(pos);

		// UI SYSTEM
		updateRatingPopup(deltaTime);
		updateComboNumbers();
		updateHealthBar();
		updateHealthIcons();

		countdownDisp.update(deltaTime);

		songPosition -= latencyCompensation;
	}

	/**
		Disposes the playfield.
	**/
	function dispose() {
		disposed = true;

		onNoteHit = null;
		onNoteMiss = null;
		onSustainComplete = null;
		onSustainRelease = null;

		countdownDisp.dispose();
		countdownDisp = null;

		uiBuf.removeElement(ratingPopup);
		ratingPopup = null;

		for (i in 0...comboNumbers.length) {
			uiBuf.removeElement(comboNumbers[i]);
			comboNumbers[i] = null;
		}
		comboNumbers = null;

		uiBuf.removeElement(healthBarBG);
		healthBarBG = null;

		for (i in 0...healthIcons.length) {
			uiBuf.removeElement(healthIcons[i]);
			healthIcons[i] = null;
		}
		healthIcons = null;

		display.removeProgram(notesProg);
		display.removeProgram(sustainProg);
		display.removeProgram(uiProg);
		display.removeProgram(scoreTxtProg);
		display.removeProgram(watermarkTxtProg);

		notesProg = null;
		sustainProg = null;
		uiProg = null;
		scoreTxtProg = null;
		watermarkTxtProg = null;

		for (inst in instrumentals) {
			inst.dispose();
			inst = null;
		}
		instrumentals = null;

		for (voices in voicesTracks) {
			voices.dispose();
			voices = null;
		}
		voicesTracks = null;

		songEnded = true;

		GC.run();
	}

	/**
		Pauses the playfield.
	**/
	function pause() {
		if (disposed || paused) return;

		paused = true;

		for (inst in instrumentals) {
			inst.stop();
		}

		for (voices in voicesTracks) {
			voices.stop();
		}
	}

	/**
		Resumes the playfield.
	**/
	function resume() {
		if (disposed || !paused || RenderingMode.enabled) return;

		paused = false;

		if (songStarted) {
			for (inst in instrumentals) {
				inst.play();
			}

			for (voices in voicesTracks) {
				voices.play();
			}
		}
	}

	// Callback stuff

	inline function beatHit(beat:Float) {
		if (beat < 0) {
			countdownDisp.countdownTick(Math.floor(4 + beat));
		}

		if (beat == 0 && !songStarted) {
			onStartSong.dispatch(chart);
		}
	}

	inline function measureHit(measure:Float) {
		if (measure >= 0) {
			display.zoom += 0.015;
		}
	}

	function hitNote(note:ChartNote, timing:Int) {
		//Sys.println('Hit ${note.index}, ${note.lane} - Timing: $timing');

		// Don't execute ratings if an opponent note has executed it

		if (!strumlinePlayableMap[note.lane]) {
			health -= 0.025;

			if (health < 0.05) {
				health = 0.05;
			}

			return;
		}

		// Add the health

		health += 0.025;

		if (health > 1) {
			health = 1;
		}

		// Accumulate the combo and start determining the rating judgement

		++combo;

		// This shows you how ratings work

		var absTiming = Math.abs(timing);

		if (absTiming > 60) {
			respondWithRatingID(3);
			score += 50;

			return;
		}

		if (absTiming > 45) {
			respondWithRatingID(2);
			score += 100;

			return;
		}

		if (absTiming > 30) {
			respondWithRatingID(1);
			score += 200;

			return;
		}

		respondWithRatingID(0);
		score += 400;
	}

	inline function missNote(note:ChartNote) {
		//Sys.println('Miss ${note.index}, ${note.lane}');

		// Hurt the health

		health -= 0.025;

		if (practiceMode && health < 0.05) {
			health = 0.05;
		}

		// Zero the combo
		combo = 0;

		// Hurt the score
		score -= 50;

		// Increment the misses
		++misses;
	}

	inline function completeSustain(note:ChartNote) {
		//Sys.println('Complete ${note.index}, ${note.lane}');

		if (!strumlinePlayableMap[note.lane]) {
			health -= 0.025;

			if (health < 0.05) {
				health = 0.05;
			}

			return;
		}

		// Add the health

		health += 0.025;

		if (health > 1) {
			health = 1;
		}
	}

	inline function releaseSustain(note:ChartNote) {
		//Sys.println('Release ${note.index}, ${note.lane}');

		// Zero the combo
		combo = 0;
	}

	function startSong(chart:Chart) {
		Sys.println('Song activity is on');

		if (!RenderingMode.enabled) {
			for (inst in instrumentals) {
				inst.time = 0;
				inst.play();
			}

			for (voices in voicesTracks) {
				voices.time = 0;
				voices.play();
			}
		}

		songStarted = true;
		songEnded = false;
	}

	function stopSong(chart:Chart) {
		Sys.println('Song activity is off');

		if (!RenderingMode.enabled) {
			for (inst in instrumentals) {
				inst.stop();
			}

			for (voices in voicesTracks) {
				voices.stop();
			}
		} else {
			RenderingMode.stopRender();
		}

		songEnded = true;
		songStarted = false;
	}

	function gameOver(chart:Chart) {
		Sys.println("Game Over");
		dispose();

		if (RenderingMode.enabled) {
			RenderingMode.stopRender();
		}
	}
}