package system;

import sys.io.File;
using StringTools;

#if !debug
@:noDebug
#end
@:publicFields
class ChartSystem
{
	static function parseHeader(path:String):Header {
		var contents = File.getContent(path);
		var raw:Dynamic = haxe.Json.parse(contents);
		trace(raw);
		var result:Header = new Header(raw);
		trace(new Header(raw));
		return result;
	}
}