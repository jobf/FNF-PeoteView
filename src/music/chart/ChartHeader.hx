package music.chart;

/**
 * The chart header.
 */
#if !debug
@:noDebug
#end
typedef ChartHeader = {
	/**
	 * The song's title.
	 */
	var songTitle:String;

	/**
	 * The song's artist.
	 */
	var songArtist:String;

	/**
	 * The song's genre.
	 */
	var songGenre:SongGenre;

    /**
     * The song's beats per minute.
     */
    var songBpm:Float;

    /**
     * The song's speed.
     */
    var songSpeed:Float;

    /**
     * The song's characters.
     */
    var songCharacters:Array<SongCharacter>;
}