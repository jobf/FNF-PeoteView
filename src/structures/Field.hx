package structures;

/**
	The field of the gameplay state.
	This is an internal structure and should only be used inside of the playfield NOT to be touched with.
**/
@:publicFields
class Field {
	// Time for hell
	var dad:Actor;
	var bf:Actor;

	var parent:PlayField;

	static var singPoses:Array<String> = ["BF NOTE LEFT", "BF NOTE DOWN", "BF NOTE UP", "BF NOTE RIGHT"];
	static var missPoses:Array<String> = ["BF NOTE LEFT MISS", "BF NOTE DOWN MISS", "BF NOTE UP MISS", "BF NOTE RIGHT MISS"];

	function new(parent:PlayField) {
		this.parent = parent;

		Actor.init(parent);

		dad = new Actor("bf", 225, 250, 24);
		dad.playAnimation("BF idle dance");
		dad.mirror = true;
		dad.startingShakeFrame = 0;
		dad.endingShakeFrame = 1;
		dad.finishAnim = "BF idle dance";
		Actor.buffer.addElement(dad);

		bf = new Actor("bf", 625, 250, 24);
		bf.playAnimation("BF idle dance");
		bf.startingShakeFrame = 0;
		bf.endingShakeFrame = 1;
		bf.finishAnim = "BF idle dance";
		Actor.buffer.addElement(bf);

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
			if (!dad.animationRunning && canBop) dad.playAnimation("BF idle dance");
			if (!bf.animationRunning && canBop) bf.playAnimation("BF idle dance");
		});

		parent.view.scroll.y = -100;
		targetCamera.x = 0;
		targetCamera.y = 0;
	}

	var targetCamera:Point = {x: 0, y: 0};

	function update(deltaTime:Float) {
		var buf = Actor.buffer;

		var sc = parent.view.scroll;
		var ratio = deltaTime * 0.01;
		parent.view.scroll.x = sc.x + ratio * (targetCamera.x - sc.x);
		parent.view.scroll.y = sc.y + ratio * (targetCamera.y - sc.y);

		dad.update(deltaTime);
		buf.updateElement(dad);

		bf.update(deltaTime);
		buf.updateElement(bf);
	}

	function resetCharacters() {
		dad.playAnimation("BF idle dance");
		dad.shake = false;

		bf.playAnimation("BF idle dance");
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
		Actor.uninit(parent);
	}
}