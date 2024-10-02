package system.internal;

import lime.ui.Window;

/**
	The screen.
**/
#if !debug
@:noDebug
#end
@:publicFields
class Screen extends Display {
	/**
		The initial state.
	**/
	inline private static var initState:Class<State> = BasicState;

	/**
		The view of the screen.
	**/
	static var view:PeoteView;

	/**
		Initialize the screen.
		@param window The window to initialize the screen on.
	**/
	static function init(window:Window) {
		view = new PeoteView(window);

		switchState(initState);
	}

	/**
		Switch the state.
		@param name The state's name.
		@throws "Invalid State!" If you don't have an existing state or you've inputted null.
	**/
	static function switchState(name:Dynamic) {
		if (name == null) {
			throw "Invalid State!";
		}

		try {
			State.current.dispose();
		} catch (e) {
			throw 'Invalid state dispose!\n$e';
		}

		State.current = null;

		/**
			Free up memory from the old buffer.
		**/
		if (State.useGC)
		{
			GC.run();
		}

		var newState = (name is Class) ? Type.createInstance(name, []) : name;

		if (newState == null) {
			throw "Invalid State!";
		}

		State.current = newState;
	}
}