package structures;

import lime.ui.KeyCode;
import lime.app.Event;

/**
	The home of the gameplay state.
**/
@:publicFields
class PlayField implements State {
	var roof(default, null):CustomDisplay;
	var display(default, null):CustomDisplay;
	var view(default, null):CustomDisplay;

	function new(songName:String) {
		chart = new Chart('assets/songs/$songName');
	}

	function init(roof:CustomDisplay, display:CustomDisplay, view:CustomDisplay) {
		this.roof = roof;
		this.display = display;
		this.view = view;
		create(roof, display, chart.header.mania);
	}

	var score:Int128 = 0;
	var misses:Int128 = 0;
	var combo:Int128 = 0;
	var accuracy(default, null):Accuracy = new Accuracy();
	var numOfReceptors:Int;
	var numOfNotes:Int;
	var health:Float = 0.5;
	var latencyCompensation(default, set):Int;
	inline function set_latencyCompensation(value:Int) {
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
	var died(default, null):Bool;
	var botplay(default, set):Bool;
	inline function set_botplay(value:Bool) {
		if (noteSystem != null) noteSystem.resetInputs();
		return botplay = value;
	}

	var field(default, null):Field;
	var inputSystem(default, null):InputSystem;
	var noteSystem(default, null):NoteSystem;
	var audioSystem(default, null):AudioSystem;
	var hud(default, null):HUD;
	var countdownDisp(default, null):CountdownDisplay;
	var pauseScreen(default, null):PauseScreen;

	var onStartSong:Event<Chart->Void>;
	var onPauseSong:Event<Chart->Void>;
	var onResumeSong:Event<Chart->Void>;
	var onStopSong:Event<Chart->Void>;
	var onDeath:Event<Chart->Int->Void>;
	var onNoteHit:Event<MetaNote->Int->Void>;
	var onNoteMiss:Event<MetaNote->Void>;
	var onSustainComplete:Event<MetaNote->Void>;
	var onSustainRelease:Event<MetaNote->Void>;
	var onKeyPress:Event<KeyCode->Void>;
	var onKeyRelease:Event<KeyCode->Void>;

	var flipHealthBar:Bool;
	var hitbox:Float = 200;
	var ready:Bool = false;

	function setTime(value:Float, playAgain:Bool = false) {
		if (disposed || !songStarted || songEnded || paused || died) return;

		if (value < 0) value = 0;
		songPosition = value;
		if (audioSystem != null) audioSystem.setTime(songPosition);
		if (hud != null && SaveData.state.ratingPopup) hud.hideRatingPopup();
		if (noteSystem != null) noteSystem.resetNotes();
		if (field != null) field.resetCharacters();
	}

	var songPosition:Float;
	var chart:Chart;

	/**
	 * Creates the playfield.
	 * @param roof The top display you want the playfield's pause screen to go to.
	 * @param display The ui display you want the playfield's countdown display and hud to go to.
	 * @param mania The amount of keys you want for your fnf song. (This is configured by the song's header)
	 */
	function create(roof:CustomDisplay, display:CustomDisplay, mania:Int = 4) {
		if (mania > 16) mania = 16;

		onStartSong = new Event<Chart->Void>();
		onPauseSong = new Event<Chart->Void>();
		onResumeSong = new Event<Chart->Void>();
		onStopSong = new Event<Chart->Void>();
		onDeath = new Event<Chart->Int->Void>();

		onNoteHit = new Event<MetaNote->Int->Void>();
		onNoteMiss = new Event<MetaNote->Void>();
		onSustainComplete = new Event<MetaNote->Void>();
		onSustainRelease = new Event<MetaNote->Void>();
		onKeyPress = new Event<KeyCode->Void>();
		onKeyRelease = new Event<KeyCode->Void>();

		field = new Field(this);
		inputSystem = new InputSystem(mania, this);
		noteSystem = new NoteSystem(numOfReceptors, this);
		audioSystem = new AudioSystem(chart);
		HUD.init(display);
		if (!SaveData.state.hideHUD) hud = new HUD(display, this);
		CountdownDisplay.setupSounds();
		countdownDisp = new CountdownDisplay(HUD.uiBuf);
		PauseScreen.init(roof);
		pauseScreen = new PauseScreen(chart.header.difficulty);

		numOfNotes = NoteSystem.notesBuf.length - numOfReceptors;
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

		if (!died) {
			if (audioSystem != null) audioSystem.update(this, deltaTime);
			songPosition += latencyCompensation;
			Main.conductor.time = songPosition;

			var pos = Tools.betterInt64FromFloat(songPosition * 100);

			if (noteSystem != null) noteSystem.update(pos);
			if (hud != null) hud.update(deltaTime);
		} else {
			if (inputSystem != null) {
				inputSystem.dispose();
				inputSystem = null;
			}

			if (noteSystem != null) {
				noteSystem.dispose();
				noteSystem = null;
			}

			if (countdownDisp != null) {
				countdownDisp.dispose();
				countdownDisp = null;
			}

			if (pauseScreen != null) {
				pauseScreen.dispose();
				pauseScreen = null;
			}

			if (hud != null) {
				hud.dispose();
				hud = null;
			}
		}

		if (field != null) field.update(deltaTime);
		if (countdownDisp != null) countdownDisp.update(deltaTime);

		songPosition -= latencyCompensation;
	}

	/**
		Pauses the playfield.
	**/
	function pause() {
		if (disposed || paused || died) return;

		paused = true;
		if (!RenderingMode.enabled && songStarted && audioSystem != null) audioSystem.stop();
		if (noteSystem != null) noteSystem.resetReceptors();
		pauseScreen.open();
	}

	/**
		Resumes the playfield.
	**/
	function resume() {
		if (disposed || !paused || died) return;

		paused = false;
		if (!RenderingMode.enabled && songStarted && !songEnded && audioSystem != null) audioSystem.play();
		if (noteSystem != null) noteSystem.resetReceptors();
		pauseScreen.close();
	}

	inline function beatHit(beat:Float) {
		if (beat == 0 && !songStarted) onStartSong.dispatch(chart);
		if (beat < 0) countdownDisp.countdownTick(Math.floor(4 + beat));
	}

	inline function measureHit(measure:Float) {
		if (measure >= 0 && SaveData.state.cameraZooming) {
			display.fov += 0.03;
			view.fov += 0.015;
		}
	}

	function hitNote(note:MetaNote, timing:Int) {
		if (audioSystem != null) {
			var voicesTrack = audioSystem.voices[note.lane];
			if (voicesTrack == null) voicesTrack = audioSystem.voices[0];
			if (voicesTrack != null) {
				voicesTrack.volume = 1;
			}
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
			if (hud != null && preferences.ratingPopup) hud.respondWithRatingID(3);
			accuracy.increment(0.5);
			score += 50;
			return;
		}

		if (absTiming > 45) {
			if (hud != null && preferences.ratingPopup) hud.respondWithRatingID(2);
			accuracy.increment(0.75);
			score += 100;
			return;
		}

		if (absTiming > 30) {
			if (hud != null && preferences.ratingPopup) hud.respondWithRatingID(1);
			accuracy.increment(0.8);
			score += 200;
			return;
		}

		if (hud != null && preferences.ratingPopup) hud.respondWithRatingID(0);
		accuracy.increment();
		score += 400;
	}

	function missNote(note:MetaNote) {
		if (audioSystem != null) {
			var voicesTrack = audioSystem.voices[note.lane];
			if (voicesTrack == null) voicesTrack = audioSystem.voices[0];
			if (voicesTrack != null) {
				voicesTrack.volume = 0;
			}
		}

		health -= 0.025;

		combo = 0;
		score -= 50;
		++misses;
		accuracy.increment(1.0, true);

		if (health < 0 && !disposed) {
			onDeath.dispatch(chart, note.lane);
			return;
		}

		if (practiceMode && health < 0.05) {
			health = 0.05;
		}
	}

	function completeSustain(note:MetaNote) {
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

	inline function releaseSustain(note:MetaNote) {
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

		Main.switchState(MAIN_MENU);
	}

	function gameOver(chart:Chart, lane:Int) {
		onDeath.remove(gameOver);

		died = true;
		songEnded = true;
		songPosition = 0;

		Sys.println("Game Over");

		if (RenderingMode.enabled) {
			RenderingMode.stopRender();
		}

		onNoteHit.remove(hitNote);
		onNoteMiss.remove(missNote);
		onSustainComplete.remove(completeSustain);
		onSustainRelease.remove(releaseSustain);

		var conductor = Main.conductor;
		conductor.onBeat.remove(beatHit);
		conductor.onMeasure.remove(measureHit);

		if (audioSystem != null) audioSystem.stop();

		var char = field.actors[lane];
		if (char == null) char = field.actors[1];

		field.actorOnGameOver = char;
		field.targetCamera.x = lane == 0 ? -50 : 50; // Prototype camera logic I have for now
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

		if (field != null) {
			field.dispose();
			field = null;
		}

		if (inputSystem != null) {
			inputSystem.dispose();
			inputSystem = null;
		}

		if (noteSystem != null) {
			noteSystem.dispose();
			noteSystem = null;
		}

		if (countdownDisp != null) {
			countdownDisp.dispose();
			countdownDisp = null;
		}

		if (pauseScreen != null) {
			pauseScreen.dispose();
			pauseScreen = null;
		}

		if (hud != null) {
			hud.dispose();
			hud = null;
		}

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

		songEnded = true;
		GC.run();
	}
}