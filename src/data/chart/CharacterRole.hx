package data.chart;

/**
	The song's character role.
	This is an abstract over string.
**/
#if !debug
@:noDebug
#end
enum abstract CharacterRole(String) from String
{
	/**
		The enemy role.
	**/
	var ENEMY = "enemy";

	/**
		The player role.
	**/
	var PLAYER = "player";

	/**
		The other role.
	**/
	var OTHER = "other";
}