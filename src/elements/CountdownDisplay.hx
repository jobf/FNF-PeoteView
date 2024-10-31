package elements;

/**
	The countdown display.
	This is a helper class for the gameplay state.
	Inspired from defective engine's countdown class.
	This uses a tiled texture for the element.
**/
#if !debug
@:noDebug
#end
@:publicFields
class CountdownDisplay {
	/**
		The countdown display's buffer.
		This holds one single sprite.
	**/
	var buffer:Buffer<UISprite>;

	/**
		The countdown display's sprite.
		This is held on by the buffer that actually gets rendered by the program's display.
	**/
	private var sprite:UISprite;

	/**
		The countdown display's sound suffix.
	**/
	var suffix:String = "";

	/**
		Constructs a countdown display from chart.
		@param chart The chart you want the countdown display to input the chart onto.
		@param display The underlying display that is required to add the underlying program.
	**/
	function new(display:Display, buffer:Buffer<UISprite>, program:Program) {
		this.buffer = buffer;

		sprite = new UISprite();
		sprite.type = COUNTDOWN_POPUP;
		sprite.changeID(0);

		sprite.x = (display.width - sprite.w) >> 1;
		sprite.y = (display.height - sprite.h) >> 1;

		sprite.c.aF = 0.0;

		buffer.addElement(sprite);
	}

	/**
		Ticks the countdown.
		@param id The countdown's tick index.
	**/
	function countdownTick(id:Int) {
		//Audio.playSound('assets/countdown/${3 - id}${suffix != "" ? '-$suffix' : ''}.wav');

		if (id != 0) {
			var idBelowZero = id < 0;
			sprite.changeID(idBelowZero ? 0 : id - 1);
			sprite.c.aF = idBelowZero ? 0.0 : 1.0;
			buffer.updateElement(sprite);
		}
	}

	/**
		Updates the countdown.
		@param deltaTime The time since the last frame.
	**/
	function update(deltaTime:Float) {
		if (sprite.c.aF != 0) {
			var a = sprite.c.aF;
			var multVal = (a * 0.5) * (deltaTime * 0.0145);
			var alphaBoundCheck = a - multVal;

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
		sprite = null;
		TextureSystem.disposeTexture("cdTex");
		GC.run();
	}
}