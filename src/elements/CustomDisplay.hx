package elements;

@:publicFields
class CustomDisplay extends Display {
	var scroll(default, null):Point = {x: 0, y: 0};

	var scale(default, set):Float = 1;

	inline function set_scale(value:Float) {
		if (value != scale) {
			scale = value;
			zoom = value * fov;
			scroll.update();
		}
		return value;
	}

	var fov(default, set):Float = 1;

	inline function set_fov(value:Float) {
		if (value != fov) {
			fov = value;
			zoom = fov * scale;
			scroll.update();
		}
		return value;
	}

	function new(x:Int, y:Int, w:Int, h:Int, c:Color) {
		super(x, y, w, h, c);

		scroll.update = updateScroll;
	}

	function updateScroll() {
		var scrollShiftMult = zoom - scale;
		xOffset = scroll.x - ((Main.INITIAL_WIDTH >> 1) * scrollShiftMult);
		yOffset = scroll.y - ((Main.INITIAL_HEIGHT >> 1) * scrollShiftMult);
	}
}