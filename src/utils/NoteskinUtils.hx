package utils;

import sys.io.File;

@:publicFields
class NoteskinUtils {
    static function parseFrameOffsets(path:String) {
        var finalData:Array<Int> = [];

        var data = File.read('$path/frameOffsets.txt');

        while (!data.eof()) {
            var line = data.readLine();
            var split = line.split(", ");
            if (split.length != 6) throw "ARGUMENTS ARE NOT EQUAL TO SIX!";

            var x = Std.parseInt(split[0].split(" ")[1]);
            var y = Std.parseInt(split[1].split(" ")[1]);
            var w = Std.parseInt(split[2].split(" ")[1]);
            var h = Std.parseInt(split[3].split(" ")[1]);
            var ox = Std.parseInt(split[4].split(" ")[1]);
            var oy = Std.parseInt(split[5].split(" ")[1]);

            finalData.push(x);
            finalData.push(y);
            finalData.push(w);
            finalData.push(h);
            finalData.push(ox);
            finalData.push(oy);
        }

        return finalData;
    }
}