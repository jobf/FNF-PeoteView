package elements;

/**
	The camera.
**/
@:publicFields
class Camera {
	/**
		The camera's x.
	**/
	var x(get, set):Int;

	/**
		Get the camera's x.
	**/
	inline function get_x():Int {
		return screen.x;
	}

	/**
		Set the camera's x to a value.
	**/
	inline function set_x(value:Int):Int {
		return screen.x = value;
	}

	/**
		The camera's y.
	**/
	var y(get, set):Int;

	/**
		Get the camera's y.
	**/
	inline function get_y():Int {
		return screen.y;
	}

	/**
		Set the camera's y to a value.
	**/
	inline function set_y(value:Int):Int {
		return screen.y = value;
	}

	/**
		The camera's width.
	**/
	var w(get, set):Int;

	/**
		Get the camera's width.
	**/
	inline function get_w():Int {
		return screen.width;
	}

	/**
		Set the camera's width to a value.
	**/
	inline function set_w(value:Int):Int {
		return screen.width = value;
	}

	/**
		The camera's height.
	**/
	var h(get, set):Int;

	/**
		Get the camera's width.
	**/
	inline function get_h():Int {
		return screen.height;
	}

	/**
		Set the camera's height to a value.
	**/
	inline function set_h(value:Int):Int {
		return screen.height = value;
	}

	/**
		The camera's angle.
	**/
	var r(get, set):Float;

	/**
		Get the camera's angle.
	**/
	inline function get_r():Float {
		return sprite.r;
	}

	/**
		Set the camera's angle to a value.
	**/
	inline function set_r(value:Float):Float {
		return sprite.r = value;
	}

	/**
		The camera's frame.
	**/
	private var screen(default, null):Display;

	/**
		The camera's frame.
	**/
	private var frame(default, null):Display;

	/**
		The camera's screen.
	**/
	private var texture(default, null):Texture;

	/**
		The camera's buffer, which is held on by its program.
	**/
	private var buffer(default, null):Buffer<Sprite>;

	/**
		The camera's program, used to render the camera to a texture.
	**/
	private var program(default, null):Program;

	/**
		The camera's sprite.
	**/
	private var sprite(default, null):Sprite;

	/**
		The camera's second buffer, used to store sprites in the camera.
	**/
	private var bufferAbove(default, null):Buffer<Sprite>;

	/**
		The camera's second program, used to render the camera itself.
	**/
	private var programAbove(default, null):Program;

	/**
		Constructs a camera.
		@param x The camera's x.
		@param y The camera's y.
		@param width The camera's width.
		@param height The camera's height.
		@param color The camera's background color.
	**/
	function new(x:Int = 0, y:Int = 0, width:Int = 0, height:Int = 0, color:Color = 0x00000000) {
		screen = new Display(x, y, width, height, color);
		frame = new Display(x, y, width, height, color);

		Screen.view.addDisplay(screen);
		Screen.view.addFramebufferDisplay(frame);

		texture = new Texture(width, height);
		frame.setFramebuffer(texture);

		buffer = new Buffer<Sprite>(1, 0, true);
		program = new Program(buffer);
		screen.addProgram(program);
		program.addTexture(texture, "fb");

		sprite = new Sprite();
		sprite.w = screen.width;
		sprite.h = screen.height;
		buffer.addElement(sprite);

		bufferAbove = new Buffer<Sprite>(1, 1, true);
		programAbove = new Program(bufferAbove);
		screen.addProgram(programAbove);
	}

	/**
		Add an element onto the camera.
		@param element The sprite to add.
	**/
	inline function add(element:Sprite) {
		bufferAbove.addElement(element);
	}

	/**
		Add an element onto the camera.
		@param element The sprite to update. If null, every element will be updated.
	**/
	inline function update(?element:Sprite) {
		if (element == null) {
			bufferAbove.update();
		} else {
			bufferAbove.updateElement(element);
		}
		buffer.updateElement(sprite);
	}

	/**
		Removes an element from the camera.
		@param element The sprite to remove.
	**/
	inline function remove(element:Sprite) {
		bufferAbove.removeElement(element);
	}

	/**
		Disposes the camera.
	**/
	inline function dispose() {
		Screen.view.removeDisplay(screen);
		Screen.view.removeFramebufferDisplay(frame);

		screen = null;
		frame = null;
		texture = null;
		buffer = null;
		program = null;
		sprite = null;
		bufferAbove = null;
		bufferAbove = null;

		if (State.useGC) {
			GC.run();
		}
	}

	/**
		Sets the camera's program's texture to a key and value.
		@param texKey The texture's key.
		@param texValue The texture's value.
	**/
	inline function setTexture(texKey:String, texValue:String) {
		programAbove.setTexture(TextureSystem.getTexture(texKey), texValue);
	}

	/**
		Adds a program onto the camera.
		@param program The program you want to add onto the camera.
	**/
	inline function addProgram(program:Program) {
		screen.addProgram(program);
	}

	/**
		Removes a program from the camera.
		@param program The program you want to remove from the camera.
	**/
	inline function removeProgram(program:Program) {
		screen.removeProgram(program);
	}

	/**
		Whenever the camera has a specific program.
		@param program The program you want to check.
	**/
	inline function hasProgram(program:Program) {
		return screen.hasProgram(program);
	}
}