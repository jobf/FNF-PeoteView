package music.chart;

import #if FV_BIG_BYTES hx.io.BigBytes #else haxe.io.Bytes #end;
import sys.io.File;

/**
	The chart data.
	This abstracts over `Bytes`.
**/
@:publicFields
#if FV_BIG_BYTES
abstract ChartData(BigBytes) from BigBytes
#else
abstract ChartData(Bytes) from Bytes
#end
{
	/**
		Gets how many notes in the chart data there are in total.
	**/
	var length(get, never):#if FV_BIG_BYTES Int64 #else Int #end;

	/**
		The length getter.
	**/
	inline function get_length() {
		return this.length >> 3;
	}

	/**
		Gets the chart note from the index of this chart data.
		@param id The id you want to access the note from.
		@returns ChartNote
	**/
	inline function getNote(id:#if FV_BIG_BYTES Int64 #else Int #end):ChartNote {
		return this.getInt64(id << 3);
	}
}