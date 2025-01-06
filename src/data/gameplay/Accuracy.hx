package data.gameplay;

@:publicFields
abstract Accuracy(Vector<Float>) {
	var left(get, never):Float;

	inline function get_left() {
		return this[0];
	}

	var right(get, never):Float;

	inline function get_right() {
		return this[1];
	}

	inline function increment(value:Float = 1.0, missed:Bool = false) {
		if (!missed) this[0] += value;
		++this[1];
	}

	inline function new() {
		this = new Vector<Float>(2);
	}

	inline function toString() {
		var calc = left / (right == 0 ? 1 : right);
		var result = Math.floor(calc * 10000) * 0.01;
		return Std.string(result) + '%';
	}
}