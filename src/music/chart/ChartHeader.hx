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
		The song's genres throughout the song.
	**/
	var genres:Array<SongGenre>;

	/**
		The song's speed.
	**/
	var speed:Float;

	/**
		The song's beats per minute.
	**/
	var bpm:Float;

	/**
		The song's stage.
	**/
	var stage:String;

	/**
		The song's characters.
	**/
	var characters:Array<SongCharacter>;

	/**
		Returns a string representation of the chart header.
	**/
	function toString() {
		return '{ title => $title, artist => $artist, genres => $genres, speed => $speed, bpm => $bpm, stage => $stage, characters => ${[for (character in characters) character.toString()]} }';
	}
}