package menus;

import lime.ui.KeyCode;
import lime.app.Event;
import lime.app.Application;

@:publicFields
class PlayField {
	var disposed:Bool = true;

	/**************************************************************************************
										  CONSTRUCTOR
	**************************************************************************************/

	function new(songName:String) {
		chart = new Chart('assets/songs/$songName');
	}

	function init(display:Display, downScroll:Bool) {
		this.downScroll = downScroll;

		createNoteSystem(display);
		createHUD(display);
		finishPlayfield(display);

		disposed = false;
	}

	/**************************************************************************************
										  NOTE SYSTEM
	**************************************************************************************/

	// The actual input system logic, very different from other fnf engines since this is peote-view. (Pretty similar to the last FNF Zenith note system rewrite but it's better)
	// Do not touch any part of this area unless you know it's critical.
	// This is a huge ass system which took only 2 days to fully complete.

	var downScroll(default, null):Bool;

	var onNoteHit:Event<ChartNote->Int->Void>;
	var onNoteMiss:Event<ChartNote->Void>;
	var onSustainComplete:Event<ChartNote->Void>;
	var onSustainRelease:Event<ChartNote->Void>;
	var onKeyPress:Event<KeyCode->Void>;
	var onKeyRelease:Event<KeyCode->Void>;

	// Behind the note system
	private var sustainProg(default, null):Program;
	private var sustainBuf(default, null):Buffer<Sustain>;

	// Above the note system
	private var notesProg(default, null):Program;
	private var notesBuf(default, null):Buffer<Note>;

	var sustainDimensions:Array<Int> = [];

	// CUSTOMIZATION SECTION //

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

	var flipHealthBar:Bool;

	///////////////////////////

	var numOfReceptors:Int;
	var numOfNotes:Int;

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
		sustainBuf.addElement(sustain);
	}

	inline function getNote(id:Int) {
		return notesBuf.getElement(id + numOfReceptors);
	}

	function setTime(value:Float) {
		if (disposed) return;

		conductor.active = false;
		conductor.time = songPosition = value;
		conductor.active = true;

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
			note.x = 9999;

			var sustain = note.child;
			if (sustain != null) {
				sustain.c.aF = 0;
				sustain.x = 9999;
				sustain.w = sustain.length;
				sustain.held = false;
				sustainBuf.updateElement(sustain);
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
			curTopNote.x = 9999;

			var sustain = curTopNote.child;

			if (sustain != null) {
				sustain.c.aF = Sustain.defaultAlpha;
				sustain.w = sustain.length;
				sustain.x = 9999;
				sustainBuf.updateElement(sustain);
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

			curBottomNote.x = 9999;

			var sustain = curBottomNote.child;
			var sustainExists = sustain != null;

			if (sustainExists) {
				sustain.x = 9999;
				sustain.c.aF = Sustain.defaultAlpha;
				sustainBuf.updateElement(sustain);
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
			var note = getNote(i);

			var data = note.data;
			var index = data.index;
			var lane = data.lane;

			var fullIndex = index + (lane * strumlineMap[lane].length);

			var position = data.position;

			var rec = notesBuf.getElement(fullIndex);

			var diff = (Int64.toInt(position - pos) * 0.01) * scrollSpeed;
			var leftover = Math.floor(Int64.toInt(pos - position) * 0.01);

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

						hideRatingPopup();
					}
				}
			} else {
				if (botHitsToCheck[fullIndex]) {
					if (!rec.idle()) {
						rec.reset();
						notesBuf.updateElement(rec);
					}

					botHitsToCheck[fullIndex] = false;
				}

				if (!isHit && diff < 0) {
					note.c.aF = 0;
					sustainsToHold[fullIndex] = sustain;

					if (!rec.confirmed()) {
						rec.confirm();
						notesBuf.updateElement(rec);
					}

					if (sustainExists) {
						sustain.followReceptor(rec);
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
						sustain.followReceptor(rec);
						sustain.w = sustain.length - leftover;
						if (sustain.w < 0) sustain.w = 0;
					}

					if (pos > position + (sustain.length * 100) - 125 && !sustain.held) {
						sustain.held = true;
						if (rec.confirmed()) {
							if (rec.playable) rec.press();
							else rec.reset();
						}
						notesBuf.updateElement(rec);
						onSustainComplete.dispatch(data);
					}
				}

				sustainBuf.updateElement(sustain);
			}

			notesBuf.updateElement(note);
		}
	}

	function keyPress(code:KeyCode, mod) {
		if (disposed) return;

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
			if (!rec.confirmed()) {
				rec.confirm();
				notesBuf.updateElement(rec);
			}

			noteToHit.c.aF = 0;
			sustainsToHold[index] = noteToHit.child;

			var data = noteToHit.data;

			onNoteHit.dispatch(data, Int64.toInt(Int64.div(data.position - Tools.betterInt64FromFloat(songPosition * 100), 100)));

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
		if (disposed) return;

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

			hideRatingPopup();
		}

		if (!rec.idle()) {
			rec.reset();
			notesBuf.updateElement(rec);
		}

		onKeyRelease.dispatch(code);
	}

	function createNoteSystem(display:Display) {
		UISprite.healthBarDimensions = Tools.parseHealthBarConfig('assets/ui');
		Note.offsetAndSizeFrames = Tools.parseFrameOffsets('assets/notes');

		if (strumlineMap.length > 4) strumlineMap.resize(4);

		onNoteHit = new Event<ChartNote->Int->Void>();
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

		notesBuf = new Buffer<Note>(16384, 16384, false);
		notesProg = new Program(notesBuf);
		notesProg.blendEnabled = true;

		TextureSystem.setTexture(notesProg, "noteTex", "noteTex");

		var tex1 = TextureSystem.getTexture("noteTex");

		// SUSTAIN SETUP
		sustainBuf = new Buffer<Sustain>(16384, 16384, false);
		sustainProg = new Program(sustainBuf);
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
				var rec = new Note(0, downScroll ? display.height - 150 : 50, 0, 0);
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

	var countdownDisp:CountdownDisplay;

	private var uiBuf(default, null):Buffer<UISprite>;
	private var uiProg(default, null):Program;

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
			part.w = (healthBarBG.w >> 1) - (healthBarWS << 1);
			part.h = healthBarBG.h - (healthBarHS << 1);
			part.x = (healthBarBG.x + (part.w * i)) + healthBarWS;
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

		// HEALTH ICONS SETUP

		var x = healthBarBG.x + (healthBarBG.w >> 1);

		var oppIcon = healthIcons[0] = new UISprite();
		oppIcon.type = HEALTH_ICON;
		oppIcon.x = x - 118;
		oppIcon.changeID(healthIconIDs[0][0]);

		var plrIcon = healthIcons[1] = new UISprite();
		plrIcon.type = HEALTH_ICON;
		plrIcon.x = x - 18;
		plrIcon.changeID(healthIconIDs[1][0]);

		oppIcon.y = plrIcon.y = healthBarBG.y - 75;
		plrIcon.flip = 1;

		uiBuf.addElement(oppIcon);
		uiBuf.addElement(plrIcon);

		display.addProgram(uiProg);
	}

	/**************************************************************************************
									 THE REST OF THIS SHIT
	**************************************************************************************/

	/**
		Finalize the playfield.
	**/
	function finishPlayfield(display:Display) {
		var timeSig = chart.header.timeSig;
		conductor = new Conductor(chart.header.bpm, timeSig[0], timeSig[1]);

		scrollSpeed = chart.header.speed;

		songPosition = -conductor.crochet * 4.5;

		conductor.onBeat.add((beat:Float) -> {
			if (beat < 0) {
				countdownDisp.countdownTick(Math.floor(4 + beat));
			}
		});

		countdownDisp = new CountdownDisplay(display, uiBuf);

		var dimensions = sustainDimensions;

		var sW = dimensions[0];
		var sH = dimensions[1];

		var notes = chart.data;

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
			var noteSpr = new Note(9999, 0, 0, 0);
			noteSpr.data = note;
			noteSpr.toNote();
            noteSpr.r = strumlineMap[note.lane][note.index][0];
			addNote(noteSpr);

			if (note.duration > 5) {
				var susSpr = new Sustain(9999, 0, sW, sH);
				susSpr.length = ((note.duration << 2) + note.duration) - 25;
				susSpr.w = susSpr.length;
				susSpr.r = downScroll ? -90 : 90;
				susSpr.c.aF = Sustain.defaultAlpha;
				addSustain(susSpr);

				susSpr.parent = noteSpr;
				noteSpr.child = susSpr;
			}

			#if FV_BIG_BYTES i++; #end
		}

		numOfNotes = notesBuf.length - numOfReceptors;

		//// CALLBACK TEST ////
		onNoteHit.add((note:ChartNote, timing:Int) -> {
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
		});

		onNoteMiss.add((note:ChartNote) -> {
			//Sys.println('Miss ${note.index}, ${note.lane}');

			// Don't execute ratings if an opponent note has executed it

			if (!strumlinePlayableMap[note.lane]) {
				health -= 0.025;

				if (health < 0.05) {
					health = 0.05;
				}

				return;
			}

			// Zero the combo
			combo = 0;

			// Increment the misses
			++misses;

			// Hurt the health
			health -= 0.05;
		});

		onSustainComplete.add((note:ChartNote) -> {
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
		});

		onSustainRelease.add((note:ChartNote) -> {
			//Sys.println('Release ${note.index}, ${note.lane}');

			// Add the health

			if (!strumlinePlayableMap[note.lane]) {
				health -= 0.025;

				if (health < 0.05) {
					health = 0.05;
				}

				return;
			}

			// Zero the combo
			combo = 0;

			// Hurt the health
			health -= 0.025;
		});
		///////////////////////
	}

	var score:Int64 = 0;
	var misses:Int64 = 0;
	var combo:Int;

	var songPosition:Float;
	var conductor:Conductor;

	var chart:Chart;

	/**
		Update the playfield.
	**/
	function update(deltaTime:Float) {
		if (disposed) return;

		// Trigger a game over
		if (health < 0) {
			Sys.println("Game Over");
			dispose();
		}

		conductor.time = songPosition;

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

		if (countdownDisp == null) return;

		countdownDisp.update(deltaTime);
	}

	/**
		Dispose the playfield.
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

		notesProg.displays[0].removeProgram(notesProg);
		sustainProg.displays[0].removeProgram(sustainProg);
		uiProg.displays[0].removeProgram(uiProg);

		GC.run();
	}
}