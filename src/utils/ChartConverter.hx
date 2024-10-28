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
		Sys.println("Converting base-game chart to Funkin' View chart...");
		Sys.println("1. Won't work for extra key charts with. 2. Only notes will be converted.)");

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

		var gfVersion = song.gfVersion;

		if (gfVersion == null) {
			gfVersion = "gf";
		}

		header.writeString('Title: ${song.song}
Arist: N/A
Genre: N/A
Speed: ${song.speed * 0.45}
BPM: ${song.bpm}
Stage: $stage
Instrumental: $path/Inst.ogg
Voices: $path/Voices.ogg
Characters:
${song.player2}, enemy
pos -700 300
cam 0 45
$gfVersion, other
pos -100 300
cam 0 45
${song.player1}, player
pos 200 300
cam 0 45');

		header.close();

		Sys.println("Sorting notes...");
		Sys.println("Notes in a base game format chart can get out of order\n");

		try {
			var notes:Array<Dynamic> = song.notes;
			var sectionsParsed:Int = 0;
			for (section in notes) {
				var sectionNotes:Array<Dynamic> = section.sectionNotes;
				sectionNotes.sort((a, b) -> a[0] - b[0]);
				for (i in 0...sectionNotes.length) {
					var note:VanillaChartNote = sectionNotes[i];

					var newNote:ChartNote = new ChartNote(
						PlayField.betterInt64FromFloat(note.position * 100),
						Math.floor(note.duration * 0.2), // Equal to `note.duration / 5`.
						note.index,
						0,
						note.lane
					);

					chart.writeInt32((newNote.toNumber().high:Int));
					chart.writeInt32((newNote.toNumber().low:Int));
					Sys.println('Position: ${newNote.position}, Duration: ${newNote.duration}, Id: ${newNote.index}, Type: ${newNote.type}, Lane: ${newNote.lane}');
				}
			}
		} catch (e) {
			Sys.println(e);
			Sys.println("This may be an invalid base game chart format or there\'s an error in the file.");
		}

		chart.close();
	}
}

/**
	The base-game chart note.
	The only way you can construct it is that if you input a float array.
**/
#if !debug
@:noDebug
#end
@:publicFields
abstract VanillaChartNote(Array<Float>) from Array<Float> {
	/**
		The note's position.
		Assigns the visual representation of a note at a specific time in the song.
	**/
	var position(get, never):Float;

	/**
		The note's index.
		Where the note should spawn at.
	**/
	var index(get, never):Int;

	/**
		The note's hold duration.
		Assigns the note's visual representation of the hold note with the length.
	**/
	var duration(get, never):Float;

	/**
		The note's strumline lane.
		Specifies the position of the note it's assigned to.
	**/
	var lane(get, never):Int;

	/**
		Get the note's position.
		Assigns the visual representation of a note at a specific time in the song.
	**/
	inline function get_position():Float {
		return this[0];
	}

	/**
		Get the note's index.
		Where the note should spawn at.
	**/
	inline function get_index():Int {
		return Math.floor(this[1]) & 3;
	}

	/**
		Get the note's hold duration.
		Assigns the note's visual representation of the hold note with the length.
	**/
	inline function get_duration():Float {
		return this[2];
	}

	/**
		Get the note's strumline lane.
		Specifies the position of the note it's assigned to.
	**/
	inline function get_lane():Int {
		return Math.floor(this[1]) >> 2;
	}
}