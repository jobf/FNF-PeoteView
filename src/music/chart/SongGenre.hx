package music.chart;

/**
 * The song's genre.
 * This is an abstract over string.
 */
#if !debug
@:noDebug
#end
enum abstract SongGenre(String) from String {
	/**
	 * Classical.
	 */
	var CLASSICAL:SongGenre = "Classical";

	/**
	 * Metal genres.
	 */
	var DULL_METAL:SongGenre = "Dull Metal";
	var CLASSIC_METAL:SongGenre = "Classic Metal";
	var LIGHT_METAL:SongGenre = "Light Metal";
	var ALT_METAL:SongGenre = "Alternative Metal";
	var HEAVY_METAL:SongGenre = "Heavy Metal";

	/**
	 * Rock genres.
	 */
	var DULL_ROCK:SongGenre = "Dull Rock";
	var CLASSIC_ROCK:SongGenre = "Classic Rock";
	var LIGHT_ROCK:SongGenre = "Light Rock";
	var ALT_ROCK:SongGenre = "Alternative Rock";
	var HEAVY_ROCK:SongGenre = "Heavy Rock";

	/**
	 * Pop genres.
	 */
	var LIGHT_POP:SongGenre = "Light Pop";
	var HEAVY_POP:SongGenre = "Heavy Pop";

	/**
	 * EDM genres.
	 */
	var HOUSE:SongGenre = "House";
	var TECHNO:SongGenre = "Techno";
	var AMBIENT:SongGenre = "Ambient";
	var BREAKBEAT:SongGenre = "Breakbeat";
	var DUB:SongGenre = "Dub";
	var ACID_TECHNO:SongGenre = "Acid Techno";
	var DUBSTEP:SongGenre = "Dubstep";
	var IND_HARDCORE:SongGenre = "Industrial Hardcore EDM";
	var ACID_BREAKS:SongGenre = "Acid Breaks";
	var BRAZ_BASS:SongGenre = "Brazilian Bass";
	var TRAP:SongGenre = "EDM Trap";
	var DUTCH_HOUSE:SongGenre = "Dutch House";
	var DARK_AMBIENT:SongGenre = "Dark Ambient";

	/**
	 * Retro genres.
	 */
	var RETRO_NINTENDO:SongGenre = "Retro (Nintendo)";
	var RETRO_SEGA:SongGenre = "Retro (Sega)";
	var RETRO_OTHER:SongGenre = "Retro (Other)";

	/**
	 * Other genres.
	 */
	var BREAKCORE:SongGenre = "Breakcore";
	var SPEEDCORE:SongGenre = "Speedcore";
	var EXTRATONE:SongGenre = "Extratone";
	var HYPERTONE:SongGenre = "Hypertone";
	var SPLITTERTONE:SongGenre = "Splittertone";
}