package music.chart;

/**
	The chart header.
	This is a structure containing metadata about the chart.
**/
#if !debug
@:noDebug
#end
@:publicFields
@:structInit
class ChartHeader {
	/**
		The song's title.
	**/
	var title:String;

	/**
		The song's artist.
	**/
	var artist:String;

	/**
		The song's genre.
	**/
	var genre:SongGenre;

	/**
		The song's beats per minute.
	**/
	var bpm:Float;

	/**
		The song's speed.
	**/
	var speed:Float;

	/**
		The song's characters.
	**/
	var characters:Array<SongCharacter>;
}