package music.chart;

import sys.io.File;
import sys.FileSystem;
import haxe.io.Bytes;

/**
	The chart.
**/
#if !debug
@:noDebug
#end
@:publicFields
class Chart {
	/**
		The chart's header content.
	**/
	var header(default, null):Header;

	/**
		The chart data where every note is read and parsed to a playable song.
	**/
	var data(default, null):ChartData;

	/**
		Constructs a chart.
		@param path The path to the chart folder.
	**/
	function new(path:String) {
		trace('Parsing chart from folder...');

		if (FileSystem.exists('$path/chart.json')) {
			ChartConverter.baseGame(path);
		}

		header = ChartSystem.parseHeader('$path/header.txt');

		data = ChartData.fromFile('$path/chart.cbin');
	}
}