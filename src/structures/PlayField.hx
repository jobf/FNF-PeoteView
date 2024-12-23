package structures;

import lime.ui.KeyCode;
import lime.app.Event;

/**
	The UI and note system.
	This includes audio which represent the [instrumentals] and [voicesTracks].
**/
@:publicFields
class PlayField {
	var display(default, null):CustomDisplay;

	var disposed(default, null):Bool;
	var paused(default, null):Bool;
	var botplay:Bool;

	/**************************************************************************************
										  CONSTRUCTOR
	**************************************************************************************/

	function new(songName:String) {
		chart = new Chart('assets/songs/$songName');
	}

	function init(display:CustomDisplay, downScroll:Bool) {
		this.downScroll = downScroll;
		this.display = display;

		create(display, chart.header.mania);
		loadAudio();
		finishPlayfield(display);
	}

	/**************************************************************************************
										 NOTES AND HUD
	**************************************************************************************/

	// The actual input system logic, very different from other fnf engines since this is peote-view. (Pretty similar to the last FNF Zenith note system rewrite but it's better)
	// Do not touch any part of this area unless you know it's critical.
	// This is a huge ass system which took only 2 days to fully complete.

	var downScroll(default, null):Bool;
	var practiceMode:Bool;

	var onStartSong:Event<Chart->Void>;
	var onPauseSong:Event<Chart->Void>;
	var onResumeSong:Event<Chart->Void>;
	var onStopSong:Event<Chart->Void>;
	var onDeath:Event<Chart->Void>;

	var onNoteHit:Event<ChartNote->Int->Void>;
	var onNoteMiss:Event<ChartNote->Void>;
	var onSustainComplete:Event<ChartNote->Void>;
	var onSustainRelease:Event<ChartNote->Void>;
	var onKeyPress:Event<KeyCode->Void>;
	var onKeyRelease:Event<KeyCode->Void>;

	var noteSystem(default, null):NoteSystem;
	var hud(default, null):HUD;

	private var sustainDimensions:Array<Int> = [];

	// CUSTOMIZATION SECTION //

	var keybindMaps:Array<Map<KeyCode, Array<Int>>> = [
		// 1 KEY
		[KeyCode.SPACE => [0, 1]],
		// 2 KEY
		[KeyCode.A => [0, 1], KeyCode.D => [1, 1],
		KeyCode.LEFT => [0, 1], KeyCode.RIGHT => [1, 1]],
		// 3 KEY
		[KeyCode.A => [0, 1], KeyCode.SPACE => [1, 1], KeyCode.D => [2, 1],
		KeyCode.LEFT => [0, 1], KeyCode.RIGHT => [2, 1]],
		// 4 KEY
		[KeyCode.A => [0, 1], KeyCode.S => [1, 1], KeyCode.W => [2, 1], KeyCode.D => [3, 1],
		KeyCode.LEFT => [0, 1], KeyCode.DOWN => [1, 1], KeyCode.UP => [2, 1], KeyCode.RIGHT => [3, 1]],
		// 5 KEY
		[KeyCode.A => [0, 1], KeyCode.S => [1, 1], KeyCode.SPACE => [2, 1], KeyCode.W => [3, 1], KeyCode.D => [4, 1],
		KeyCode.LEFT => [0, 1], KeyCode.DOWN => [1, 1], KeyCode.UP => [3, 1], KeyCode.RIGHT => [4, 1]],
		// 6 KEY
		[KeyCode.S => [0, 1], KeyCode.D => [1, 1], KeyCode.F => [2, 1],
		KeyCode.J => [3, 1], KeyCode.K => [4, 1], KeyCode.L => [5, 1]],
		// 7 KEY
		[KeyCode.S => [0, 1], KeyCode.D => [1, 1], KeyCode.F => [2, 1], KeyCode.SPACE => [3, 1],
		KeyCode.J => [4, 1], KeyCode.K => [5, 1], KeyCode.L => [6, 1]],
		// 8 KEY
		[KeyCode.A => [0, 1], KeyCode.S => [1, 1], KeyCode.D => [2, 1], KeyCode.F => [3, 1],
		KeyCode.H => [4, 1], KeyCode.J => [5, 1], KeyCode.K => [6, 1], KeyCode.L => [7, 1]],
		// 9 KEY
		[KeyCode.A => [0, 1], KeyCode.S => [1, 1], KeyCode.D => [2, 1], KeyCode.F => [3, 1], KeyCode.SPACE => [4, 1],
		KeyCode.H => [5, 1], KeyCode.J => [6, 1], KeyCode.K => [7, 1], KeyCode.L => [8, 1]]
	];

	var keybindMap:Map<KeyCode, Array<Int>>;

	var strumlineRotationMap:Array<Int>;

	var strumlineMap:Array<Array<Array<Float>>>;

	var strumlinePlayableMap:Array<Bool>;

	var flipHealthBar:Bool;

	///////////////////////////

	var numOfReceptors:Int;
	var numOfNotes:Int;
	var precalculatedIndexThing:Array<Int> = [];

	var hitbox:Float = 200;

	var scrollSpeed(default, set):Float = 1.0;

	inline function set_scrollSpeed(value:Float) {
		return noteSystem.setScrollSpeed(scrollSpeed = value);
	}

	function setTime(value:Float, playAgain:Bool = false) {
		if (disposed || !songStarted || songEnded || paused) return;

		if (value < 0) {
			value = 0;
		}

		songPosition = value;

		for (inst in instrumentals) {
			if (playAgain) {
				inst.play();
			}
			inst.time = songPosition;
			inst.update();
		}

		for (voices in voicesTracks) {
			if (playAgain) {
				voices.play();
			}
			voices.time = songPosition;
			voices.update();
		}

		hud.hideRatingPopup();

		noteSystem.resetNotes();
	}

	function keyPress(code:KeyCode, mod) {
		if (disposed || botplay || RenderingMode.enabled || paused) return;

		if (!keybindMap.exists(code)) {
			return;
		}

		var map = keybindMap[code];
		var lane = map[1];
		var index = map[0] + precalculatedIndexThing[lane];

		if (noteSystem.playerHitsToCheck[index]) {
			return;
		}

		var rec = noteSystem.getReceptor(index);

		if (!rec.playable) {
			return;
		}

		noteSystem.playerHitsToCheck[index] = true;

		var noteToHit = noteSystem.notesToHit[index];
		noteSystem.hitDetectNote(noteToHit, rec, index);

		onKeyPress.dispatch(code);
	}

	function keyRelease(code:KeyCode, mod) {
		if (code == KeyCode.RETURN) {
			if (paused) {
				resume();
			} else {
				pause();
			}
		}

		if (disposed || botplay || RenderingMode.enabled || paused) return;

		if (!keybindMap.exists(code)) {
			return;
		}

		var map = keybindMap[code];
		var lane = map[1];
		var index = map[0] + precalculatedIndexThing[lane];

		noteSystem.playerHitsToCheck[index] = false;

		var rec = noteSystem.getReceptor(index);

		if (!rec.playable) {
			return;
		}

		var sustainToRelease = noteSystem.sustainsToHold[index];
		noteSystem.releaseDetectSustain(sustainToRelease, rec, index);

		onKeyRelease.dispatch(code);
	}

	function create(display:Display, mania:Int = 4) {
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
		onPauseSong = new Event<Chart->Void>();
		onResumeSong = new Event<Chart->Void>();
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

		noteSystem = new NoteSystem(numOfReceptors, this);
		hud = new HUD(display, this);
	}

	/**************************************************************************************
										   UI SYSTEM
	**************************************************************************************/

	var health:Float = 0.5;

	/**************************************************************************************
											 AUDIO
	**************************************************************************************/

	var instrumentals:Array<Sound> = [];
	var voicesTracks:Array<Sound> = [];

	function loadAudio() {
		var inst = new Sound();
		inst.fromFile(chart.header.instDir);

		instrumentals.push(inst);

		var voices = new Sound();
		voices.fromFile(chart.header.voicesDir);

		voicesTracks.push(voices);
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
		var conductor = Main.conductor;

		var timeSig = chart.header.timeSig;
		conductor.changeBpmAt(0, chart.header.bpm, timeSig[0], timeSig[1]);

		scrollSpeed = chart.header.speed;

		songPosition = -conductor.crochet * 4.5;

		conductor.onBeat.add(beatHit);
		conductor.onMeasure.add(measureHit);

		noteSystem.init(chart.file);

		numOfNotes = noteSystem.notesBuf.length - numOfReceptors;

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
	var combo:Int128 = 0;

	var songPosition:Float;

	var chart:Chart;

	var latencyCompensation:Int;

	/**
		Update the playfield.
	**/
	function update(deltaTime:Float) {
		if (disposed || paused) return;

		if (display.fov != 1) {
			display.fov -= (display.fov - 1) * 0.15;
		}

		// Trigger a game over
		if (health < 0 && !disposed) {
			onDeath.dispatch(chart);
			return;
		}

		var firstInst = instrumentals[0];

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
		noteSystem.update(pos);

		// UI SYSTEM
		hud.update(deltaTime);

		songPosition -= latencyCompensation;
	}

	/**
		Pauses the playfield.
	**/
	function pause() {
		if (disposed || paused) return;

		paused = true;

		if (!RenderingMode.enabled) {
			for (inst in instrumentals) {
				inst.stop();
			}

			for (voices in voicesTracks) {
				voices.stop();
			}
		}

		noteSystem.resetReceptors();
		display.fov = 1;
		hud.openPauseScreen();
	}

	/**
		Resumes the playfield.
	**/
	function resume() {
		if (disposed || !paused) return;

		paused = false;

		setTime(songPosition, true); // This will be removed soon
		display.fov = 1;
		hud.closePauseScreen();
	}

	inline function beatHit(beat:Float) {
		if (beat == 0 && !songStarted) {
			onStartSong.dispatch(chart);
		}

		if (beat < 0) {
			hud.countdownDisp.countdownTick(Math.floor(4 + beat));
		} else {
			// We just have to resync the vocals with the old method cause miniaudio sounds are almost perfectly synced with others.
			// Unpausing the game can fuck up the sync between the instrumentals and the vocals.
			// This is because they're literally streamed which can delay the playback process.
			// So, here's a bandaid fix for it.

			// Oh yeah and this also simulates gradual resync that activates if the song is more than 1 ms off
			if (songStarted && !RenderingMode.enabled) {
				for (inst in instrumentals) {
					if (inst.time - songPosition > 5) {
						inst.time = songPosition;
					}
				}

				for (vocals in voicesTracks) {
					if (vocals.time - songPosition > 5) {
						vocals.time = songPosition;
					}
				}
			}
		}
	}

	inline function measureHit(measure:Float) {
		if (measure >= 0) {
			display.fov += 0.03;
		}
	}

	function hitNote(note:ChartNote, timing:Int) {
		//Sys.println('Hit ${note.index}, ${note.lane} - Timing: $timing');

		// Turn the vocals assigned by a lane back on

		var voicesTrack = voicesTracks[note.lane];
		if (voicesTrack == null) voicesTrack = voicesTracks[0];
		if (voicesTrack != null) {
			voicesTrack.volume = 1;
		}

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
			hud.respondWithRatingID(3);
			score += 50;

			return;
		}

		if (absTiming > 45) {
			hud.respondWithRatingID(2);
			score += 100;

			return;
		}

		if (absTiming > 30) {
			hud.respondWithRatingID(1);
			score += 200;

			return;
		}

		hud.respondWithRatingID(0);
		score += 400;
	}

	inline function missNote(note:ChartNote) {
		//Sys.println('Miss ${note.index}, ${note.lane}');

		// Mute the vocals assigned by a lane

		var voicesTrack = voicesTracks[note.lane];
		if (voicesTrack == null) voicesTrack = voicesTracks[0];
		if (voicesTrack != null) {
			voicesTrack.volume = 0;
		}

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

	/**
		Disposes the playfield.
	**/
	function dispose() {
		disposed = true;

		onNoteHit = null;
		onNoteMiss = null;
		onSustainComplete = null;
		onSustainRelease = null;

		noteSystem.dispose();
		hud.dispose();

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
}