package structures;

import lime.ui.KeyCode;
import lime.app.Event;

/**
	The home of the gameplay state.
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

	function init(display:CustomDisplay) {
		this.display = display;
		create(display, chart.header.mania);
	}

	var downScroll(default, set):Bool;

	inline function set_downScroll(value:Bool) {
		downScroll = value;
		if (noteSystem != null) noteSystem.resetReceptors(false);
		return value;
	}

	var practiceMode:Bool;

	var songStarted(default, null):Bool;
	var songEnded(default, null):Bool;

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

	var inputSystem(default, null):InputSystem;
	var noteSystem(default, null):NoteSystem;
	var hud(default, null):HUD;
	var audioSystem(default, null):AudioSystem;

	var scrollSpeed(default, set):Float = 1.0;

	inline function set_scrollSpeed(value:Float) {
		return noteSystem.setScrollSpeed(scrollSpeed = value);
	}

	var flipHealthBar:Bool;

	var numOfReceptors:Int;
	var numOfNotes:Int;

	var hitbox:Float = 200;

	function setTime(value:Float, playAgain:Bool = false) {
		if (disposed || !songStarted || songEnded || paused) return;

		if (value < 0) value = 0;
		songPosition = value;
		audioSystem.setTime(songPosition);
		hud.hideRatingPopup();
		noteSystem.resetNotes();
	}

	function create(display:Display, mania:Int = 4) {
		UISprite.healthBarDimensions = Tools.parseHealthBarConfig('assets/ui');
		Note.offsetAndSizeFrames = Tools.parseFrameOffsets('assets/notes');

		if (mania > 16) mania = 16;

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

		inputSystem = new InputSystem(mania, this);
		noteSystem = new NoteSystem(numOfReceptors, this);
		hud = new HUD(display, this);
		audioSystem = new AudioSystem(chart);

		finishPlayfield(display);
	}

	/**
		Finish creating the playfield.
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
	var health:Float = 0.5;
	var latencyCompensation:Int;
	var chart:Chart;

	/**
		Update the playfield.
	**/
	function update(deltaTime:Float) {
		if (disposed || paused) return;

		if (display.fov != 1) {
			display.fov -= (display.fov - 1) * (deltaTime * 10);
		}

		if (health < 0 && !disposed) {
			onDeath.dispatch(chart);
			return;
		}

		var pos = Tools.betterInt64FromFloat(songPosition * 100);

		songPosition += latencyCompensation;

		noteSystem.update(pos);
		hud.update(deltaTime);
		audioSystem.update(this, deltaTime);

		Main.conductor.time = songPosition + latencyCompensation;

		songPosition -= latencyCompensation;
	}

	/**
		Pauses the playfield.
	**/
	function pause() {
		if (disposed || paused) return;

		paused = true;
		if (!RenderingMode.enabled) audioSystem.stop();
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
		if (!RenderingMode.enabled) audioSystem.play();
		display.fov = 1;
		hud.closePauseScreen();
	}

	inline function beatHit(beat:Float) {
		if (beat == 0 && !songStarted) onStartSong.dispatch(chart);
		if (beat < 0) hud.countdownDisp.countdownTick(Math.floor(4 + beat));
	}

	inline function measureHit(measure:Float) {
		if (measure >= 0) {
			display.fov += 0.03;
		}
	}

	function hitNote(note:ChartNote, timing:Int) {
		var voicesTrack = audioSystem.voices[note.lane];
		if (voicesTrack == null) voicesTrack = audioSystem.voices[0];
		if (voicesTrack != null) {
			voicesTrack.volume = 1;
		}

		if (!inputSystem.strumlinePlayable[note.lane]) {
			health -= 0.025;
			if (health < 0.05) {
				health = 0.05;
			}
			return;
		}

		++combo;

		health += 0.025;
		if (health > 1) {
			health = 1;
		}

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
		var voicesTrack = audioSystem.voices[note.lane];
		if (voicesTrack == null) voicesTrack = audioSystem.voices[0];
		if (voicesTrack != null) {
			voicesTrack.volume = 0;
		}

		health -= 0.025;

		if (practiceMode && health < 0.05) {
			health = 0.05;
		}

		combo = 0;
		score -= 50;
		++misses;
	}

	inline function completeSustain(note:ChartNote) {
		if (!inputSystem.strumlinePlayable[note.lane]) {
			health -= 0.025;

			if (health < 0.05) {
				health = 0.05;
			}

			return;
		}

		health += 0.025;

		if (health > 1) {
			health = 1;
		}
	}

	inline function releaseSustain(note:ChartNote) {
		combo = 0;
	}

	function startSong(chart:Chart) {
		Sys.println('Song activity is on');

		if (!RenderingMode.enabled) {
			audioSystem.play();
		}

		songStarted = true;
		songEnded = false;
	}

	function stopSong(chart:Chart) {
		Sys.println('Song activity is off');

		if (!RenderingMode.enabled) {
			audioSystem.stop();
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
		audioSystem.dispose();

		songEnded = true;
		GC.run();
	}
}