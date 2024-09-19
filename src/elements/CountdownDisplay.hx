package elements;

/**
	The countdown display.
	This is a helper class for the gameplay state.
	Inspired from defective engine's countdown class.
	NOTE: You should only use this if necessary to do so. This uses a program per sprite, which uses multitexture.
**/
#if !debug
@:noDebug
#end
@:publicFields
class CountdownDisplay {
	/**
		The countdown display's program.
		This is here to render the textures.
	**/
	var program:Program;

	/**
		The countdown display's buffer.
		This holds one single sprite.
	**/
	var buffer:Buffer<Sprite>;

	/**
		The countdown display's sprite.
		This is held on by the buffer that actually gets rendered by the program's display.
	**/
	var sprite:Sprite;

	/**
		The countdown display's underlying chart.
	**/
	var selectedChart:Chart;

	/**
		The countdown display's sound suffix.
	**/
	var suffix:String = "";

	/**
		Constructs a countdown display from chart.
		@param chart The chart you want the countdown display to input the chart onto.
		@param fromDisplay The underlying display that is required to add the underlying program.
	**/
	function new(fromChart:Chart, fromDisplay:Display) {
		buffer = new Buffer<Sprite>(1, 0, true);
		program = new Program(buffer);

		if (!fromDisplay.hasProgram(program)) {
			fromDisplay.addProgram(program);
		}

		TextureSystem.createMultiTexture("tex1", ["assets/countdown/ready.png", "assets/countdown/set.png", "assets/countdown/go.png"]);
		TextureSystem.setTexture(program, "tex1", "custom");

		sprite = new Sprite();

		sprite.setSizeToTexture(TextureSystem.getTexture("tex1"));
		sprite.w = Math.floor(sprite.w / 3);
		sprite.screenCenter();

		buffer.addElement(sprite);
		sprite.c.setFloatAlpha(0);
		buffer.updateElement(sprite);

		selectedChart = fromChart;
	}

	/**
		Ticks the countdown.
		@param id The countdown's tick index.
	**/
	function countdownTick(id:Int) {
		Audio.playSound('assets/countdown/${3 - id}${suffix != "" ? '-$suffix' : ''}.wav');

		if (id != 0) {
			sprite.slot = id - 1;
			sprite.c.setFloatAlpha(1);
			buffer.updateElement(sprite);
		}
	}

	/**
		Updates the countdown.
		@param deltaTime The time since the last frame.
	**/
	inline function update(deltaTime:Int) {
		if (sprite.c.aF != 0) {
			var multVal = deltaTime * 0.0015;
			var alphaBoundCheck = sprite.c.aF - multVal;

			if (alphaBoundCheck < 0) {
				sprite.c.aF = 0;
			} else {
				sprite.c.aF -= multVal;
			}

			buffer.updateElement(sprite);
		}
	}

	/**
		Disposes the countdown display.
	**/
	function dispose() {
		buffer = null;
		program = null;
		sprite = null;

		if (State.useGC) {
			GC.run();
		}
	}
}