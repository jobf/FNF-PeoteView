package structures;

/**
	The field of the gameplay state.
	This is an internal structure and should only be used inside of the playfield NOT to be touched with.
**/
@:publicFields
class Field {
	var actors_sparrow:Array<Actor>;

	var dad(get, set):Actor;

	inline function get_dad() {
		return actors_sparrow[0];
	}

	inline function set_dad(actor:Actor) {
		return actors_sparrow[0] = actor;
	}

	var bf(get, set):Actor;

	inline function get_bf() {
		return actors_sparrow[1];
	}

	inline function set_bf(actor:Actor) {
		return actors_sparrow[1] = actor;
	}

	var parent:PlayField;

	static var singPoses:Array<String> = ["singLEFT", "singDOWN", "singUP", "singRIGHT"];
	static var missPoses:Array<String> = ["singLEFTmiss", "singDOWNmiss", "singUPmiss", "singRIGHTmiss"];

	function new(parent:PlayField) {
		this.parent = parent;

		actors_sparrow = [];
		actors_sparrow.resize(2);

		dad = new Actor(parent.view, "dad", 225, 250, 24);
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

		parent.onNoteHit.add(function(note, timing) {
			sing(note.index, (note.lane == 0 ? dad : bf), false, note.duration > 12 && timing < parent.hitbox * 0.5);

			targetCamera.x = note.lane == 0 ? -50 : 50; // Prototype camera logic I have for now
		});

		parent.onNoteMiss.add(function(note) {
			sing(note.index, (note.lane == 0 ? dad : bf), true, false);
		});

		parent.onSustainComplete.add(function(note) {
			sing(note.index, (note.lane == 0 ? dad : bf), false, false, true);
		});

		parent.onSustainRelease.add(function(note) {
			sing(note.index, (note.lane == 0 ? dad : bf), true, false);
		});

		Main.conductor.onBeat.add(function(beat) {
			var canBop = beat % 2 == 0;
			if (!dad.animationRunning && canBop) dad.playAnimation("idle");
			if (!bf.animationRunning && canBop) bf.playAnimation("idle");
		});

		parent.view.scroll.y = -100;
		targetCamera.x = 0;
		targetCamera.y = 0;
	}

	var targetCamera:Point = {x: 0, y: 0};

	function update(deltaTime:Float) {
		var sc = parent.view.scroll;
		var ratio = deltaTime * 0.01;
		parent.view.scroll.x = sc.x + ratio * (targetCamera.x - sc.x);
		parent.view.scroll.y = sc.y + ratio * (targetCamera.y - sc.y);

		dad.update(deltaTime);
		bf.update(deltaTime);
	}

	function resetCharacters() {
		dad.playAnimation("idle");
		dad.shake = false;

		bf.playAnimation("idle");
		bf.shake = false;
	}

	function sing(index:Int, char:Actor, miss:Bool = false, shake:Bool = false, skipAnimation:Bool = false) {
		var poses = (miss ? missPoses : singPoses);
		if (!skipAnimation) char.playAnimation(poses[index % poses.length]);
		char.shake = shake;
	}

	function dispose() {
		dad.dispose();
		bf.dispose();

		parent.view.scroll.x = parent.view.scroll.y = 0;
		parent.view.fov = 1.0;
	}
}