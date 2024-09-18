package music.chart;

import sys.io.File;

using StringTools;

/**
 * The chart.
 */
#if !debug
@:noDebug
#end
@:publicFields
class Chart {
	/**
	 * The chart's header.
	 */
	var header:ChartHeader;

	/**
	 * The chart's bytes.
	 */
	var bytes:Array<ChartNote>;

	/**
	 * Constructs a chart.
	 * @param path 
	 */
	function new(path:String) {
		header = parseHeader('$path/header.txt');
		trace(header);

		//bytes = ChartSystem._file_contents_chart('$path/chart.bin');
	}

	/**
	 * Internal function to parse the chart's header.
	 * @param path 
	 */
	private function parseHeader(path:String):ChartHeader {
		var input = File.read(path, false);

		var title = input.readLine().split(": ")[1].trim();
		var artist = input.readLine().split(": ")[1].trim();
		var genre = input.readLine().split(": ")[1].trim();
		var speed = Std.parseFloat(input.readLine().split(": ")[1].trim());
		var bpm = Std.parseFloat(input.readLine().split(": ")[1].trim());

		input.readLine();

		var characterData:Array<SongCharacter> = [];

		while (!input.eof()) {
			var name = input.readLine();
			var role:SongCharacterRole = input.readLine().replace("role ", "");

			var posSplit = input.readLine().replace("pos ", "").split(" ");
			var x = Std.parseFloat(posSplit[0]);
			var y = Std.parseFloat(posSplit[1]);
			var camSplit = input.readLine().replace("cam ", "").split(" ");
			var camX = Std.parseFloat(camSplit[0]);
			var camY = Std.parseFloat(camSplit[1]);

			var character:SongCharacter = {name: name, role: role, x: x, y: y, camX: camX, camY: camY};
			characterData.push(character);
		}

		var result:ChartHeader = {
			songTitle: title,
			songArtist: artist,
			songGenre: genre,
			songSpeed: speed,
			songBpm: bpm,
			songCharacters: characterData
		};

		return result;
	}
}