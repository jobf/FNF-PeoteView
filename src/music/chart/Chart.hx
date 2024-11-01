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

		Sys.println('Parsing chart from CBIN...');

		var chartPath = '$path/chart.cbin';
		var size = FileSystem.stat(chartPath).size;

		var stamp:Float;
		if (size < 0xFFFFF) {
			var input = File.read('$path/chart.cbin');
			var buffer = Bytes.alloc(0xA00000);

			stamp = haxe.Timer.stamp();
			while (!input.eof()) {
				var bufSize = 0xA00000;
				try {
					input.readFullBytes(buffer, 0, bufSize);
				} catch (e) {
					bufSize = size & 0x9FFFFF;
				}
	
				for (i in 0...buffer.length >> 3) {
					var note = buffer.getInt64(i << 3);
					bytes.push(note);
				}
			}
		} else {
			stamp = haxe.Timer.stamp();
			var rawBytes = File.getBytes('$path/chart.cbin');

			for (i in 0...rawBytes.length >> 3) {
				var note = rawBytes.getInt64(i << 3);
				bytes.push(note);
			}
		}

		Sys.println('Done! Took ${(haxe.Timer.stamp() - stamp) * 1000}ms');
	}
}