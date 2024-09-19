package music.chart;

/**
	The song's charater.
	This is a structure containing info of the field character.
**/
#if !debug
@:noDebug
#end
@:publicFields
@:structInit
class SongCharacter {
	/**
		The character's name.
	**/
	var name:String;

	/**
		The character's role.
	**/
	var role:SongCharacterRole;

	/**
		The character's position x.
	**/
	var x:Float;

	/**
		The character's position y.
	**/
	var y:Float;

	/**
		The character's camera x.
	**/
	var camX:Float;

	/**
		The character's camera y.
	**/
	var camY:Float;
}