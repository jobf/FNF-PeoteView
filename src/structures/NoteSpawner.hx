package structures;

/**
	The note spawner.
	This is an internal structure and should only be used inside of the playfield NOT to be touched with.
	Coming soon...
**/
@:publicFields
@:access(structures.PlayField)
class NoteSpawner {
	var parent:PlayField;

	var top:Int64;
	var bottom:Int64;

	function new(parent:PlayField) {
		this.parent = parent;
	}

	function update(pos:Int64) {
		// TODO
	}

	
}