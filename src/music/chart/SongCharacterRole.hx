package music.chart;

/**
 * The song's character role.
 * This is an abstract over string.
 */
#if !debug
@:noDebug
#end
enum abstract SongCharacterRole(String) from String {
	/**
	 * The enemy role.
	 */
	var ENEMY:SongCharacterRole = "enemy";

	/**
	 * The player role.
	 */
	var PLAYER:SongCharacterRole = "player";

	/**
	 * The other role.
	 */
	var OTHER:SongCharacterRole = "other";
}