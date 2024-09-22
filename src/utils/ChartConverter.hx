package utils;

import sys.io.File;
import haxe.Json;
import haxe.Int64;

import sys.io.FileOutput;
import sys.io.FileInput;

/**
	The chart converter class.
	This is a universal chart converter that can convert multiple formats to the chart folder.
**/
#if !debug
@:noDebug
#end
@:publicFields
class ChartConverter
{
	/**
		Converts a base-game chart file to Funkin' View's chart format.
		@param path The specified path you want to convert your chart to.
	**/
	static function baseGame(path:String) {
		Sys.println("Welcome to the Funkin' View chart converter!");
		Sys.println("Converting base-game chart to Funkin' View chart... (Only notes will be converted.)");

		var header:FileOutput = File.write('$path/header.txt');
		var events:FileOutput = File.write('$path/events.txt');
		var chart:FileOutput  = File.write('$path/chart.cbin');

		Sys.println("Parsing json... (The slow part, as json is a dynamic file structure system, hence the name javascript object notation)");

		var fileContents = "";
		try {
			fileContents = File.getContent('$path/chart.json');
		} catch (e) {
			throw "There must be a chart.json.";
		}

		var json = Json.parse(fileContents);
		var song = json.song;

		var stage = song.stage;

		if (stage == null) {
			stage = "stage";
		}

		header.writeString('Title: ${song.song}\n');
		header.writeString('Arist: N/A\n');
		header.writeString('Genre: N/A\n');
		header.writeString('Speed: ${song.speed * 0.45}\n');
		header.writeString('BPM: ${song.bpm}\n');
		header.writeString('Stage: $stage\n');
		header.writeString('Characters:\n');
		header.writeString('${song.player2}\nrole enemy\npos -700 300\ncam 0 45\n');
		header.writeString('${song.gfVersion}\nrole other\npos -100 300\ncam 0 45\n');
		header.writeString('${song.player1}\nrole player\npos 200 300\ncam 0 45');
		header.close();

		Sys.println("Sorting notes...");
		Sys.println("Notes in a base game format chart can get out of order\n");

		try {
			var notes:Array<Dynamic> = song.notes;
			var sectionsParsed:Int = 0;
			for (section in notes.iterator()) {
				section.sectionNotes.sort((a, b) -> a[0] - b[0]);
				var sectionNotes:Array<Dynamic> = section.sectionNotes;
				for (note in sectionNotes.iterator()) {
					var position:Int64 = new ChartNote(
						betterInt64FromFloat(note[0] * 100000),
						Math.floor(note[2] * 0.3636363636363636),
						Math.floor(note[3]),
						0,
						Math.floor(note[1] * 0.25)
					).toNumber();
					chart.writeInt32((position.high:Int));
					chart.writeInt32((position.low:Int));
				}
			}
		} catch (e) {
			Sys.println(e);
			Sys.println("This may be an invalid base game chart format or there\'s an error in the file.");
		}


	}

	/**
		An optimized version of `haxe.Int64.fromFloat`. Only works on certain targets such as cpp, js, or eval.
	**/
	inline static function betterInt64FromFloat(value:Float):Int64 {
		var high:Int = Math.floor(value / 4294967296);
		var low:Int = Math.floor(value);
        return Int64.make(high, low);
    }
}