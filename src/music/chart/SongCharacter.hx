package music.chart;

/**
 * The song's genre.
 * This is an abstract over string.
 */
#if !debug
@:noDebug
#end
typedef SongCharacter = {
	/**
	 * The character's name.
	 */
	var name:String;

	/**
	 * The character's role.
	 */
	var role:SongCharacterRole;

	/**
	 * The character's position x.
	 */
	var x:Float;

	/**
	 * The character's position y.
	 */
	var y:Float;

	/**
	 * The character's camera x.
	 */
	var camX:Float;

	/**
	 * The character's camera y.
	 */
	var camY:Float;
}