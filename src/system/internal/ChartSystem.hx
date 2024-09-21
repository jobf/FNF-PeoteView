#if !doc_gen
package system.internal;

import cpp.UInt8;
import cpp.Int64;
import sys.io.File;
using StringTools;

/**
 * ...
 * @author Christopher Speciale
 */
@:include('./ChartSystem.cpp')
extern class ChartSystem 
{
	@:native("file_contents_chart")
	extern static function _file_contents_chart(path:String):Array<Int64>;

	@:runtime extern inline static function parseHeader(path:String):ChartHeader {
		var input = File.read(path, false);

		var title = input.readLine().split(": ")[1].trim();
		var artist = input.readLine().split(": ")[1].trim();
		var genres:Array<SongGenre> = input.readLine().split(": ")[1].trim().split(", ");
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
			title: title,
			artist: artist,
			genres: genres,
			speed: speed,
			bpm: bpm,
			characters: characterData
		};
		trace(result);

		return result;
	}
}
#end