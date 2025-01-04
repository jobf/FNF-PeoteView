package system;

import sys.io.File;
using StringTools;

#if !debug
@:noDebug
#end
@:publicFields
class ChartSystem
{
	inline static function parseHeader(path:String) : Header
	{
		var input = File.read(path, false);

		var title = input.readLine().split(": ")[1].trim();
		var artist = input.readLine().split(": ")[1].trim();
		var genres : Array<Genre> = input.readLine().split(": ")[1].trim().split(", ");

		var speed = Std.parseFloat(input.readLine().split(": ")[1].trim());
		var bpm = Std.parseFloat(input.readLine().split(": ")[1].trim());
		var timeSigRaw = input.readLine().split(": ")[1].trim().split("/");
		var timeSig = [Std.parseInt(timeSigRaw[0]), Std.parseInt(timeSigRaw[1])];

		var stage = input.readLine().split(": ")[1].trim();
		var instDir = input.readLine().split(": ")[1].trim();
		var voicesDirs = input.readLine().split(": ")[1].trim().split(", ");

		var mania = Std.parseInt(input.readLine().split(": ")[1].trim());
		var difficulty = Std.parseInt(input.readLine().split(": #")[1].trim()) - 1;

		input.readLine();

		var characterData : Array<Character> = [];

		while (!input.eof())
		{
			var split = input.readLine().split(", ");
			var name = split[0];
			var role : CharacterRole = split[1];

			var posSplit = input.readLine().replace("pos ", "").split(" ");
			var posX = Std.parseFloat(posSplit[0]);
			var posY = Std.parseFloat(posSplit[1]);

			var camSplit = input.readLine().replace("cam ", "").split(" ");
			var camX = Std.parseFloat(camSplit[0]);
			var camY = Std.parseFloat(camSplit[1]);

			var character : Character = { name: name, role:role, x:posX, y:posY, camX:camX, camY:camY };
			characterData.push(character);
		}

		var result : Header =
		{
			title: title,
			artist: artist,
			genres: genres,
			speed: speed,
			bpm: bpm,
			timeSig: timeSig,
			stage: stage,
			instDir: instDir,
			voicesDirs: voicesDirs,
			mania: mania,
			difficulty: difficulty,
			characters: characterData
		};
		//trace(result);

		return result;
	}
}