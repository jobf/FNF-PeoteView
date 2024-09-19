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
		Whenever the countdown's active.
	**/
	var active:Bool = true;

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
	}

	/**
		The countdown's beat offset,
	**/
	var beatOffset:Float = 0;

	/**
		Ticks the countdown.
		@param beat The conductor's current beat.
	**/
	function onCountdownTick(beat:Float) {
		beat -= Math.ffloor(beatOffset);
		trace(beat);

		if (!active) {
			return;
		}

		if (beat != 0) {
			Audio.playSound('assets/countdown/${-beat - 1}.wav');
		}

		if (beat == -4) {
			return;
		}

		if (beat == 0) {
			onFinish.dispatch(selectedChart.header.title);
			active = false;
			return;
		}

		sprite.slot = Math.floor(beat) + 3;
		sprite.c.setFloatAlpha(1);
	}

	/**
		Updates the countdown.
		@param deltaTime The time since the last frame.
	**/
	inline function update(deltaTime:Int) {
		if (active && sprite.c.aF != 0) {
			var multVal = deltaTime * 0.000012;
			var alphaDecrease = Math.min(conductor.crochet * multVal, multVal * 250);
			var alphaBoundCheck = sprite.c.aF - alphaDecrease;

			if (alphaBoundCheck < 0) {
				sprite.c.aF = 0;
			} else {
				sprite.c.aF -= alphaDecrease;
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
		conductor = null;
		onFinish = null;

		if (State.useGC) {
			GC.run();
		}
	}
}