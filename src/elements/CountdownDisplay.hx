package elements;

import lime.app.Event;

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
		The underlying conductor for this countdown display.
	**/
	private var conductor(default, null):Conductor;

	/**
		The finish callback.
	**/
	var onFinish:Event<String->Void> = new Event<String->Void>();

	/**
		Whenever this countdown display has stopped.
	**/
	var stopped:Bool;

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
		Constructs a countdown display from chart.
		@param chart The chart you want the countdown display to input the chart onto.
		@param fromDisplay The underlying display that is required to add the underlying program.
		@param fromProgram The underlying program that is required to get added onto the underlying display.
	**/
	function new(fromConductor:Conductor, fromChart:Chart, fromDisplay:Display) {
		buffer = new Buffer<Sprite>(1, 0, true);
		program = new Program(buffer);

		if (!fromDisplay.hasProgram(program)) {
			fromDisplay.addProgram(program);
		}

		TextureSystem.createMultiTexture("tex1", ["assets/countdown/ready.png", "assets/countdown/set.png", "assets/countdown/go.png"]);
		TextureSystem.setTexture(program, "tex1", "custom");

		sprite = new Sprite();

		sprite.setSizeToTexture(TextureSystem.getTexture("tex1"));
		sprite.h = Math.floor(sprite.h / 3);
		sprite.screenCenter();

		buffer.addElement(sprite);
		sprite.c.setFloatAlpha(0);
		buffer.updateElement(sprite);

		selectedChart = fromChart;

		conductor = fromConductor;

		conductor.onBeat.add(onCountdownTick);
		conductor.active = false;
		conductor.time = -conductor.crochet * 5;
		conductor.active = true;
	}

	function onCountdownTick(beat:Float) {
		if (beat == -4) {
			return;
		}

		if (beat == 0) {
			onFinish.dispatch(selectedChart.header.title);

			stopped = true;
			conductor.onBeat.remove(onCountdownTick);
			return;
		}

		sprite.slot = Math.floor(beat) + 3;
		sprite.c.setFloatAlpha(1);
	}

	/**
		Updates the countdown display.
		@param deltaTime The delta time.
	**/
	inline function update(deltaTime:Int) {
		if (!stopped) {
			conductor.time += deltaTime;

			if (sprite.c.aF != 0) {
				sprite.c.setFloatAlpha(Math.max(sprite.c.aF - (conductor.crochet * (deltaTime * 0.000012)), 0));
				buffer.updateElement(sprite);
			}
		}
	}

	/**
		Disposes the countdown display.
	**/
	function dispose() {
		conductor = null;
		onFinish = null;
	}
}