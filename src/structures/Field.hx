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

        dad = new Actor("bf", 100, 100, 24);
        dad.playAnimation("BF idle dance");
        //dad.mirror = true;
        Actor.buffer.addElement(dad);

        bf = new Actor("bf", 500, 100, 24);
        bf.playAnimation("BF idle dance");
        Actor.buffer.addElement(bf);

        parent.onNoteHit.add(function(note, timing) {
            var char = (note.lane == 0 ? dad : bf);
            char.playAnimation(singPoses[note.index % 4]);
            char.finishAnim = "BF idle dance";
        });

        parent.onNoteMiss.add(function(note) {
            var char = (note.lane == 0 ? dad : bf);
            char.playAnimation(missPoses[note.index % 4]);
            char.finishAnim = "BF idle dance";
        });

        Main.conductor.onBeat.add(function(beat) {
            var canBop = beat % 2 == 0;
            if (!dad.animationRunning && canBop) dad.playAnimation("BF idle dance");
            if (!bf.animationRunning && canBop) bf.playAnimation("BF idle dance");
        });
    }

    function update(deltaTime:Float) {
        var buf = Actor.buffer;

        dad.update(deltaTime);
        buf.updateElement(dad);

        bf.update(deltaTime);
        buf.updateElement(bf);
    }

    function dispose() {
        dad.dispose();
        bf.dispose();
        Actor.uninit(parent);
    }
}