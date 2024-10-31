package system;

typedef GCBackend = #if cpp cpp.vm.Gc; #else Int #end

/**
	The GC class abstracting over its target-specific gc implementations.
	WARNING: USE THIS WISELY.
**/
#if !debug
@:noDebug
#end
@:publicFields
abstract GC(GCBackend) {
	/**
		Enable the GC.
		@param inEnable 
	**/
	static function enable(inEnable:Bool) {
		#if cpp
		GCBackend.enable(inEnable);
		#end
	}

	/**
		Run the GC.
	**/
	static function run() {
		#if cpp
		GCBackend.run(true);
		#end
	}
}