package structures;

import lime.ui.KeyCode;
import lime.app.Event;

/**
	The home of the gameplay state.
**/
@:publicFields
class PlayField {
	var display(default, null):CustomDisplay;
	var view(default, null):CustomDisplay;

	function new(songName:String) {
		chart = new Chart('assets/songs/$songName');
	}

	function init(main:Main, display:CustomDisplay, view:CustomDisplay) {
		this.display = display;
		this.view = view;
		create(main, display, chart.header.mania);
	}

	var score:Int128 = 0;
	var misses:Int128 = 0;
	var combo:Int128 = 0;
	var numOfReceptors:Int;
	var numOfNotes:Int;
	var health:Float = 0.5;
	var latencyCompensation(default, set):Int;
	inline function set_latencyCompensation(value:Int) {
		hud.watermarkTxt.text = 'FV TEST BUILD' #if FV_DEBUG + ' | -/= to change time, F8 to flip bar, [/] to adjust latency by 10ms, B to toggle botplay, and M to toggle downscroll (${value}ms)' #end;
		return latencyCompensation = value;
	}

	var scrollSpeed(default, set):Float = 1.0;
	inline function set_scrollSpeed(value:Float) {
		return noteSystem.setScrollSpeed(scrollSpeed = value);
	}

	var downScroll(default, set):Bool;
	inline function set_downScroll(value:Bool) {
		downScroll = value;
		if (noteSystem != null) {
			noteSystem.resetReceptors(false);
			noteSystem.updateNotes(Tools.betterInt64FromFloat((songPosition + latencyCompensation) * 100));
		}
		if (hud != null) {
			hud.updateHealthBar();
			hud.updateHealthIcons();
			hud.updateScoreText(0.0);
		}
		return value;
	}

	var practiceMode:Bool;
	var songStarted(default, null):Bool;
	var songEnded(default, null):Bool;
	var disposed(default, null):Bool;
	var paused(default, null):Bool;
	var botplay(default, set):Bool;
	inline function set_botplay(value:Bool) {
		if (noteSystem != null) noteSystem.resetInputs();
		return botplay = value;
	}

	var field(default, null):Field;
	var inputSystem(default, null):InputSystem;
	var noteSystem(default, null):NoteSystem;
	var hud(default, null):HUD;
	var audioSystem(default, null):AudioSystem;

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

	var flipHealthBar:Bool;
	var hitbox:Float = 200;
	var ready:Bool = false;

	function setTime(value:Float, playAgain:Bool = false) {
		if (disposed || !songStarted || songEnded || paused) return;

		if (value < 0) value = 0;
		songPosition = value;
		audioSystem.setTime(songPosition);
		hud.hideRatingPopup();
		noteSystem.resetNotes();
		field.resetCharacters();
	}

	var songPosition:Float;
	var chart:Chart;

	/**
	 * Creates the playfield.
	 * @param main The entry point.
	 * @param display The ui display you want the playfield to go to.
	 * @param mania The amount of keys you want for your fnf song. (This is configured by the song's header)
	 */
	function create(main:Main, display:Display, mania:Int = 4) {
		if (mania > 16) mania = 16;

		UISprite.healthBarProperties = Tools.parseHealthBarConfig('assets/ui');
		Note.offsetAndSizeFrames = Tools.parseFrameOffsets('assets/notes');

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

		field = new Field(this);
		inputSystem = new InputSystem(mania, this);
		noteSystem = new NoteSystem(numOfReceptors, this);
		hud = new HUD(display, this, main);
		audioSystem = new AudioSystem(chart);

		numOfNotes = noteSystem.notesBuf.length - numOfReceptors;
		scrollSpeed = chart.header.speed;

		var conductor = Main.conductor;
		var timeSig = chart.header.timeSig;
		conductor.changeBpmAt(0, chart.header.bpm, timeSig[0], timeSig[1]);
		conductor.onBeat.add(beatHit);
		conductor.onMeasure.add(measureHit);

		onNoteHit.add(hitNote);
		onNoteMiss.add(missNote);
		onSustainComplete.add(completeSustain);
		onSustainRelease.add(releaseSustain);
		onStartSong.add(startSong);
		onStopSong.add(stopSong);
		onDeath.add(gameOver);

		songPosition = -conductor.crochet * 4.5;
	}

	/**
		Updates the playfield.
	**/
	function update(deltaTime:Float) {
		if (disposed || paused) return;

		if (!ready) {
			ready = true;
			return;
		}

		if (display.fov != 1) {
			display.fov -= (display.fov - 1) * (deltaTime * 0.01);
		}

		if (view.fov != 1) {
			view.fov -= (view.fov - 1) * (deltaTime * 0.01);
		}

		if (health < 0 && !disposed) {
			onDeath.dispatch(chart);
			return;
		}

		audioSystem.update(this, deltaTime);

		songPosition += latencyCompensation;

		Main.conductor.time = songPosition;

		var pos = Tools.betterInt64FromFloat(songPosition * 100);

		noteSystem.update(pos);
		hud.update(deltaTime);
		field.update(deltaTime);

		songPosition -= latencyCompensation;
	}

	/**
		Pauses the playfield.
	**/
	function pause() {
		if (disposed || paused) return;

		paused = true;
		if (!RenderingMode.enabled && songStarted) audioSystem.stop();
		noteSystem.resetReceptors();
		display.fov = 1;
		view.fov = 1;
		hud.pauseScreen.open();
	}

	/**
		Resumes the playfield.
	**/
	function resume() {
		if (disposed || !paused) return;

		paused = false;
		if (!RenderingMode.enabled && songStarted && !songEnded) audioSystem.play();
		noteSystem.resetReceptors();
		display.fov = 1;
		view.fov = 1;
		hud.pauseScreen.close();
	}

	inline function beatHit(beat:Float) {
		if (beat == 0 && !songStarted) onStartSong.dispatch(chart);
		if (beat < 0) hud.countdownDisp.countdownTick(Math.floor(4 + beat));
	}

	inline function measureHit(measure:Float) {
		if (measure >= 0 && SaveData.state.cameraZooming) {
			display.fov += 0.03;
			view.fov += 0.015;
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

		var preferences = SaveData.state;

		if (hud != null && preferences.scoreTxtBopping) {
			hud.scoreTxt.scale = 1.1;
		}

		var absTiming = Math.abs(timing);

		if (absTiming > 60) {
			if (preferences.ratingPopup) hud.respondWithRatingID(3);
			score += 50;
			return;
		}

		if (absTiming > 45) {
			if (preferences.ratingPopup) hud.respondWithRatingID(2);
			score += 100;
			return;
		}

		if (absTiming > 30) {
			if (preferences.ratingPopup) hud.respondWithRatingID(1);
			score += 200;
			return;
		}

		if (preferences.ratingPopup) hud.respondWithRatingID(0);
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

		if (RenderingMode.enabled) {
			RenderingMode.stopRender();
		}

		Sys.exit(0);
	}

	/**
		Disposes the playfield.
	**/
	function dispose() {
		ready = false;
		disposed = true;

		var conductor = Main.conductor;
		conductor.onBeat.remove(beatHit);
		conductor.onMeasure.remove(measureHit);

		onNoteHit.remove(hitNote);
		onNoteMiss.remove(missNote);
		onSustainComplete.remove(completeSustain);
		onSustainRelease.remove(releaseSustain);
		onStartSong.remove(startSong);
		onStopSong.remove(stopSong);
		onDeath.remove(gameOver);

		onStartSong = null;
		onPauseSong = null;
		onResumeSong = null;
		onStopSong = null;
		onDeath = null;
		onNoteHit = null;
		onNoteMiss = null;
		onSustainComplete = null;
		onSustainRelease = null;
		onKeyPress = null;
		onKeyRelease = null;

		inputSystem.dispose();
		noteSystem.dispose();
		hud.dispose();
		audioSystem.dispose();
		field.dispose();

		songEnded = true;
		GC.run();
	}
}