package structures;

/**
	The field of the gameplay state.
    This is an internal structure and should only be used inside of the playfield NOT to be touched with.
**/
@:publicFields
class Field {
    // Time for hell
    var bf:Actor;

    var parent:PlayField;

    function new(parent:PlayField) {
        this.parent = parent;

        Actor.init(parent);

        bf = new Actor("bf", 100, 100, 24);
        bf.playAnimation(301, 313);
        Actor.buffer.addElement(bf);
    }

    function update(deltaTime:Float) {
        var buf = Actor.buffer;

        bf.update(deltaTime);
        buf.updateElement(bf);
    }

    function dispose() {
        bf.dispose();
        Actor.uninit(parent);
    }
}