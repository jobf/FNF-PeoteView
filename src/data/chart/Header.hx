package data.chart;

/**
	The chart header.
	This is a structure containing metadata about the chart.
**/
#if !debug
@:noDebug
#end
@:publicFields
class Header {
	/**
		The song's title.
	**/
	var title:String;

	/**
		The song's artist.
	**/
	var artist:String;

	/**
		The song's speed.
	**/
	var speed:Float;

	/**
		The song's beats per minute.
	**/
	var bpm:Float;

	/**
		The song's time signature.
	**/
	var timeSig:Array<Int>;

	/**
		The song's stage.
	**/
	var stage:String;

	/**
		The song's instrumental directory.
	**/
	var instDir:String;

	/**
		The song's voices directory array.
	**/
	var voicesDirs:Array<String>;

	/**
		The song's key count.
	**/
	var mania:Int;

	/**
		The song's difficulty level.
	**/
	var difficulty:Difficulty;

	/**
		The song's game over meta.
	**/
	var gameOver:GameOverMeta;

	/**
		Constructs a chart header from its raw.
	**/
	function new(raw:Dynamic) {
		this.title = raw.title;
		this.artist = raw.artist;
		this.speed = raw.speed;
		this.bpm = raw.bpm;
		this.timeSig = raw.timeSig;
		this.stage = raw.stage;
		this.instDir = raw.instDir;
		this.voicesDirs = raw.voicesDirs;
		this.mania = raw.mania;
		this.difficulty = raw.difficulty;
		this.gameOver = raw.gameOver;
	}

	/**
		Returns a string representation of the chart header.
	**/
	function toString() {
		return '{ title => $title, artist => $artist, speed => $speed, bpm => $bpm, timeSig => $timeSig, stage => $stage, instDir => $instDir, voicesDirs => $voicesDirs, mania => $mania, difficulty => $difficulty, gameOver => ${gameOver.toString()} }';
	}
}