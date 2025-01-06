package data.chart;

/**
	The song's character.
	This is a structure containing info dedicated to the field character.
**/
#if !debug
@:noDebug
#end
@:publicFields
@:structInit
class Character {
	/**
		What to call the character.
	**/
	var name:String;

	/**
		What to take role of the character.
	**/
	var role:CharacterRole;

	/**
		The position x of the character.
	**/
	var x:Float;

	/**
		The position y of the character.
	**/
	var y:Float;

	/**
		The camera x of the character.
	**/
	var camX:Float;

	/**
		The camera y of the character.
	**/
	var camY:Float;

	/**
		Returns a string representation of the character.
	**/
	function toString() {
		return '{ name : $name, role : $role, x : $x, y : $y, camX : $camX, camY : $camY }';
	}
}