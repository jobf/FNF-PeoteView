package music.chart;

@dox(hide)
typedef _Number = #if FV_BIG_BYTES Int64 #else Int #end;

/**
	The chart's file.
	This abstracts over `Bytes`/`BigBytes`.
**/
@:publicFields
abstract File (
	// This is the type selection.
	#if FV_BIG_BYTES
	hx.io.BigBytes
	#else
	haxe.io.Bytes
	#end
)
{
	/**
		Gets how many notes in the chart file there are in total.
	**/
	var length(get, never):_Number;

	/**
		The length getter.
	**/
	inline function get_length():_Number {
		return this.length >> 3;
	}

	/**
		Creates a chart file.
		@param path The chart path you want to load the data from.
	**/
	inline function new(path:String) {
		#if FV_BIG_BYTES
		this = hx.io.BigBytes.fromFile(path);
		#else
		this = sys.io.File.getBytes(path);
		#end
	}

	/**
		Gets the chart note from the index of this chart file.
		@param id The id you want to access the note from.
		@returns ChartNote
	**/
	inline function getNote(id:_Number):ChartNote {
		return this.getInt64(id << 3);
	}
}