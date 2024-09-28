package elements;

/**
	The camera.
**/
@:publicFields
class Camera {
	/**
		Whenever you want to use render-to-texture with the camera rendering system.
		If toggled, may consume more cpu and imply black borders.
	**/
	static var renderToTexture:Bool = false;

	// The camera's x.
	var x(get, set):Int;
	inline function get_x():Int { return screen.x; }
	inline function set_x(value:Int):Int { return screen.x = value; }

	// The camera's y.
	var y(get, set):Int;
	inline function get_y():Int { return screen.y; }
	inline function set_y(value:Int):Int { return screen.y = value; }

	// The camera's width.
	var w(get, set):Int;
	inline function get_w():Int { return screen.width; }
	inline function set_w(value:Int):Int { return screen.width = value; }

	// The camera's height.
	var h(get, set):Int;
	inline function get_h():Int { return screen.height; }
	inline function set_h(value:Int):Int { return screen.height = value; }

	// The camera's angle.
	var r(get, set):Float;
	// TODO: Implement rotation if render-to-texture is off
	inline function get_r():Float { return renderToTexture ? sprite.r : 0; }
	inline function set_r(value:Float):Float { return (renderToTexture ? sprite.r = value : sprite.r = value); }

	// The camera's scroll x.
	var scrollX(get, set):Float;
	inline function get_scrollX():Float { return screen.xOffset; }
	inline function set_scrollX(value:Float):Float { return screen.xOffset = value; }

	// The camera's scroll y.
	var scrollY(get, set):Float;
	inline function get_scrollY():Float { return screen.yOffset; }
	inline function set_scrollY(value:Float):Float { return screen.yOffset = value; }

	// The camera's zoom.
	var zoom(get, set):Float;
	inline function get_zoom():Float { return screen.zoom; }
	inline function set_zoom(value:Float):Float { return screen.zoom = value; }

	/**
		The normal display of the camera.
	**/
	private var screen(default, null):Display;

	/**
		The render-to-texture display of the camera.
	**/
	private var frame(default, null):Display;

	/**
		The camera's texture.
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
	private var buffer2(default, null):Buffer<Sprite>;

	/**
		The camera's second program, used to render the camera itself.
	**/
	private var program2(default, null):Program;

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

		if (renderToTexture) {
			frame = new Display(x, y, width, height, color);
		}

		Screen.view.addDisplay(screen);

		buffer2 = new Buffer<Sprite>(1, 1, true);
		program2 = new Program(buffer2);
		program2.blendEnabled = program2.blendSeparate = true;

		if (renderToTexture) {
			Screen.view.addFramebufferDisplay(frame);
			texture = new Texture(width, height);
			frame.setFramebuffer(texture);

			buffer = new Buffer<Sprite>(1, 0, true);
			program = new Program(buffer);
			screen.addProgram(program);
			program.addTexture(texture, "fb");
			program.blendEnabled = program.blendSeparate = true;

			sprite = new Sprite();
			sprite.w = screen.width;
			sprite.h = screen.height;
			buffer2.addElement(sprite);
		}

		(renderToTexture ? frame : screen).addProgram(program2);
	}

	/**
		Add an element onto the camera.
		@param element The sprite to add.
	**/
	inline function add(element:Sprite) {
		buffer2.addElement(element);
	}

	/**
		Add an element onto the camera.
		@param element The sprite to update. If null, every element will be updated.
	**/
	inline function update(?element:Sprite) {
		if (element == null) {
			buffer2.update();
		} else {
			buffer2.updateElement(element);
		}

		if (renderToTexture && buffer != null) {
			buffer.updateElement(sprite);
		}
	}

	/**
		Removes an element from the camera.
		@param element The sprite to remove.
	**/
	inline function remove(element:Sprite) {
		buffer2.removeElement(element);
	}

	/**
		Disposes the camera.
	**/
	inline function dispose() {
		Screen.view.removeDisplay(screen);
		screen = null;
		buffer2 = null;
		program2 = null;
		sprite = null;

		if (renderToTexture) {
			Screen.view.removeFramebufferDisplay(frame);
			frame = null;
			texture = null;
			buffer = null;
			program = null;
		}

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
		program2.setTexture(TextureSystem.getTexture(texKey), texValue);
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