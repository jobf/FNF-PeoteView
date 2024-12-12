package utils;

/**
	2 dimensional point class with the update callback.
**/
@:structInit
@:publicFields
class Point {
	var x(default, set):Float;

	inline function set_x(value:Float) {
		if (value != x) {
			x = value;
			update();
		}
		return value;
	}

	var y(default, set):Float;

	inline function set_y(value:Float) {
		if (value != y) {
			y = value;
			update();
		}
		return value;
	}

	dynamic function update():Void {}
}