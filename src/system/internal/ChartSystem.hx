package system.internal;

import cpp.UInt8;
import cpp.Int64;

/**
 * ...
 * @author Christopher Speciale
 */
@:include('./ChartSystem.cpp')
extern class ChartSystem 
{
	@:native("file_contents_chart")
	extern static function _file_contents_chart(path:String):Array<Int64>;
	
	
}