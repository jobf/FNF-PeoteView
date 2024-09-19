package elements;

import lime.app.Event;

/**
	The countdown display.
	This is a helper class for the gameplay state.
	Inspired from defective engine's countdown class.
	**KEEP M
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
		Constructs a countdown display from chart.
		@param chart The chart you want the countdown display to input the chart onto.
		@param fromDisplay The underlying display that is required to add the underlying program.
		@param fromProgram The underlying program that is required to get added onto the underlying display.
	**/
	function new(chart:Chart, fromDisplay:Display) {
		buffer = new Buffer<Sprite>(1, 0, true);
		program = new Program(buffer);

		if (!fromDisplay.hasProgram(program)) {
			fromDisplay.addProgram(program);
		}

		TextureSystem.createMultiTexture("tex1", ["assets/countdown/ready.png", "assets/countdown/set.png", "assets/countdown/go.png"]);
		TextureSystem.setTexture(program, "tex1", "custom");

		sprite = new Sprite();

		sprite.setSizeToTexture(TextureSystem.getTexture("tex1"));
		trace(sprite.w, sprite.h);
		sprite.w = Math.floor(sprite.w / 3);
		sprite.screenCenter();

		trace(sprite.x, sprite.y);

		buffer.addElement(sprite);

		conductor = new Conductor(chart.header.bpm);

		conductor.onBeat.add(function(beat) {
			if (beat == 4) {
				onFinish.dispatch(chart.header.title);
			}

			sprite.slot = Math.floor(beat);
			buffer.updateElement(sprite);
			sprite.c.alpha = 0xFF;
		});
	}

	/**
		Updates the countdown display.
	**/
	inline function update(deltaTime:Int) {
		if (!stopped) {
			conductor.time += deltaTime;
			sprite.c.aF -= conductor.crochet * 0.1;
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