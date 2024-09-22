package music.chart;

import sys.io.File;
import sys.FileSystem;

using StringTools;

/**
	The chart.
**/
#if !debug
@:noDebug
#end
@:publicFields
class Chart {
	/**
		The chart's header.
	**/
	var header(default, null):ChartHeader;

	/**
		The chart's bytes.
	**/
	var bytes(default, null):Array<ChartNote>;

	/**
		Constructs a chart.
		@param path The path to the chart folder.
	**/
	function new(path:String) {
		if (FileSystem.exists('$path/chart.json')) {
			ChartConverter.baseGame(path);
		}

		header = ChartSystem.parseHeader('$path/header.txt');
		//bytes = ChartSystem._file_contents_chart('$path/chart.bin');
	}

	/**
		Updates the chart.
		@param time The music's time.
	**/
	function update(time:Float) {
		//Sys.println(nextNote);
	}
}