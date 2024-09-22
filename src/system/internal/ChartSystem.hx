#if !doc_gen
package system.internal;

import sys.io.File;
using StringTools;

#if !debug
@:noDebug
#end
@:publicFields
class ChartSystem 
{
	inline static function parseHeader(path:String):ChartHeader {
		var input = File.read(path, false);

		var title = input.readLine().split(": ")[1].trim();
		var artist = input.readLine().split(": ")[1].trim();
		var genres:Array<SongGenre> = input.readLine().split(": ")[1].trim().split(", ");
		var speed = Std.parseFloat(input.readLine().split(": ")[1].trim());
		var bpm = Std.parseFloat(input.readLine().split(": ")[1].trim());
		var stage = input.readLine().split(": ")[1].trim();

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
			title: title,
			artist: artist,
			genres: genres,
			speed: speed,
			bpm: bpm,
			stage: stage,
			characters: characterData
		};
		trace(result);

		return result;
	}
}
#end