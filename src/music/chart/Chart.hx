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
		The chart's header content.
	**/
	var header(default, null):Header;

	/**
		The chart's actual bytes where every note is read and turned to a playable song.
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

		bytes = [];

		var rawBytes = File.getBytes('$path/chart.cbin');

		for (i in 0...rawBytes.length >> 4) {
			var note = rawBytes.getInt64(i << 4);
			bytes.push(note);
		}
	}
}