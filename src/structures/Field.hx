package structures;

import lime.ui.KeyCode;
import lime.ui.KeyModifier;

/**
	The field of the gameplay state.
	This is an internal structure and should only be used inside of the playfield NOT to be touched with.
**/
@:publicFields
class Field {
	var actors:Array<Actor>;

	var dad(get, set):Actor;

	inline function get_dad() {
		return actors[0];
	}

	inline function set_dad(actor:Actor) {
		return actors[0] = actor;
	}

	var bf(get, set):Actor;

	inline function get_bf() {
		return actors[1];
	}

	inline function set_bf(actor:Actor) {
		return actors[1] = actor;
	}

	var parent:PlayField;

	static var singPoses:Array<String> = ["singLEFT", "singDOWN", "singUP", "singRIGHT"];
	static var missPoses:Array<String> = ["singLEFTmiss", "singDOWNmiss", "singUPmiss", "singRIGHTmiss"];

	function new(parent:PlayField) {
		this.parent = parent;

		actors = [];
		actors.resize(2);

		dad = new Actor(parent.view, "dad", 250, -100, 24);
		dad.mirror = !dad.mirror;
		dad.playAnimation("idle");
		dad.startingShakeFrame = 0;
		dad.endingShakeFrame = 1;
		dad.finishAnim = "idle";
		dad.addToBuffer();

		bf = new Actor(parent.view, "bf", 625, 250, 24);
		bf.playAnimation("idle");
		bf.startingShakeFrame = 0;
		bf.endingShakeFrame = 1;
		bf.finishAnim = "idle";
		bf.addToBuffer();

		addCallbacks();

		Main.conductor.onBeat.add(beatHit);

		parent.view.scroll.y = -100;
		targetCamera.x = 0;
		targetCamera.y = 0;
	}

	function beatHit(beat:Float) {
		if (isInGameOver) {
			if (beat > 0) {
				actorOnGameOver.playAnimation("deathLoop");
			}
			return;
		}

		var canBop = beat % 2 == 0;
		if (!dad.animationRunning && canBop) dad.playAnimation("idle");
		if (!bf.animationRunning && canBop) bf.playAnimation("idle");
	}

	var targetCamera:Point = {x: 0, y: 0};

	function update(deltaTime:Float) {
		var sc = parent.view.scroll;
		var ratio = deltaTime * 0.01;
		parent.view.scroll.x = sc.x + ratio * (targetCamera.x - sc.x);
		parent.view.scroll.y = sc.y + ratio * (targetCamera.y - sc.y);

		dad.update(deltaTime);
		bf.update(deltaTime);

		if (!isInGameOver && parent.died) {
			gameOver();
		}

		if (gameOverMusic != null) {
			if (gameOverMusic.playing) {
				gameOverMusic.update();
				Main.conductor.time = gameOverMusic.time;
			}
			if (gameOverMusic.finished) {
				handleGameOver(KeyCode.RETURN, -1);
			}
		}

		if (gameOverConfirm != null) {
			if (gameOverConfirm.finished) {
				gameOverConfirm = null;
				isInGameOver = false;
				Main.switchState(GAMEPLAY);
				parent.display.show();
			}
		}
	}

	function resetCharacters() {
		dad.shake = false;
		dad.playAnimation("idle");

		bf.shake = false;
		bf.playAnimation("idle");
	}

	function sing(index:Int, char:Actor, miss:Bool = false, shake:Bool = false, skipAnimation:Bool = false) {
		var poses = (miss ? missPoses : singPoses);
		if (!skipAnimation) char.playAnimation(poses[index % poses.length]);
		char.shake = shake;
	}

	inline function hitNote(note:MetaNote, timing:Int) {
		sing(note.index, (note.lane == 0 ? dad : bf), false, note.duration > 12 && timing < parent.hitbox * 0.5);

		targetCamera.x = note.lane == 0 ? -50 : 50; // Prototype camera logic I have for now
	}

	inline function missNote(note:MetaNote) {
		sing(note.index, (note.lane == 0 ? dad : bf), true, false);
	}

	inline function completeSustain(note:MetaNote) {
		sing(note.index, (note.lane == 0 ? dad : bf), false, false, true);
	}

	inline function releaseSustain(note:MetaNote) {
		sing(note.index, (note.lane == 0 ? dad : bf), true, false);
	}

	function addCallbacks() {
		parent.onNoteHit.add(hitNote);
		parent.onNoteMiss.add(missNote);
		parent.onSustainComplete.add(completeSustain);
		parent.onSustainRelease.add(releaseSustain);
	}

	function removeCallbacks() {
		parent.onNoteHit.remove(hitNote);
		parent.onNoteMiss.remove(missNote);
		parent.onSustainComplete.remove(completeSustain);
		parent.onSustainRelease.remove(releaseSustain);
	}

	function dispose() {
		removeCallbacks();

		dad.dispose();
		bf.dispose();

		parent.view.scroll.x = parent.view.scroll.y = 0;
		parent.view.fov = 1.0;

		Main.conductor.onBeat.remove(beatHit);
	}

	// GAME OVER IMPL

	var isInGameOver:Bool;
	static var gameOverSounds:Map<String, Map<String, Sound>> = [];
	var gameOverSound:Sound;
	var gameOverMusic:Sound;
	var gameOverConfirm:Sound;
	var actorOnGameOver:Actor;

	function gameOver() {
		removeCallbacks();

		for (actor in actors) {
			if (actor == actorOnGameOver) continue;
			actor.c.aF = 0.0;
			actor.update(0.0);
		}

		var gameOverMeta = parent.chart.header.gameOver;
		var theme = gameOverMeta.theme;
		var bpm = gameOverMeta.bpm;

		if (!gameOverSounds.exists(theme)) {
			gameOverSounds[theme] = new Map<String, Sound>();
		}

		if (!gameOverSounds[theme].exists("firstDeath")) {
			gameOverSound = gameOverSounds[theme]["firstDeath"] = new Sound();
			gameOverSound.fromFile('assets/death/fnf_loss_sfx-${theme}.flac');
		}
		gameOverSound.play();

		if (!gameOverSounds[theme].exists("deathMusic")) {
			gameOverMusic = gameOverSounds[theme]["deathMusic"] = new Sound();
			gameOverMusic.fromFile('assets/death/fnf_loss_music-${theme}.flac');
		}

		Main.conductor.reset();
		Main.conductor.changeBpmAt(0, bpm);

		actorOnGameOver.finishAnim = "deathLoop";
		actorOnGameOver.shake = false;
		actorOnGameOver.playAnimation("firstDeath");
		actorOnGameOver.finishCallback = gameOverMusic.play;

		var window = lime.app.Application.current.window;
		window.onKeyDown.add(handleGameOver);

		isInGameOver = true;
	}

	function handleGameOver(code:KeyCode, mod:KeyModifier) {
		switch (code) {
			case KeyCode.RETURN:
				if (gameOverMusic != null) {
					gameOverMusic.stop();
					gameOverMusic = null;
				}

				var gameOverMeta = parent.chart.header.gameOver;
				var theme = gameOverMeta.theme;

				if (!gameOverSounds[theme].exists("confirm")) {
					gameOverConfirm = gameOverSounds[theme]["confirm"] = new Sound();
					gameOverConfirm.fromFile('assets/death/fnf_loss_end-${theme}.flac');
				}
				gameOverConfirm.play();

				actorOnGameOver.finishAnim = "";
				actorOnGameOver.playAnimation("deathConfirm");
			default:
				return;
		}

		var window = lime.app.Application.current.window;
		window.onKeyDown.remove(handleGameOver);
	}
}