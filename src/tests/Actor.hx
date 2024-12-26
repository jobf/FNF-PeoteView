/**
 * CONCEPT:
 * Poses:
 LA, LE, LI, LO, LU,
 DA, DE, DI, DO, DU,
 UA, UE, UI, UO, UU,
 RA, RE, RI, RO, RU,
 XA, XE, XI, XO, XU,
 LM, DM, UM, RD, XM
**/

package tests;

import atlas.SparrowAtlas.SubTexture;

/**
	Actor element object meant to be in the field of the gameplay state.
**/
@:publicFields
class Actor extends ActorElement
{
	// Stuff for initialization and shit

	static var buffer:Buffer<ActorElement>;
	static var program:Program;

	static var tex(default, null):Texture;
	var name(default, null):String;
	var atlas(default, null):SparrowAtlas;

	var finishAnim:String = "";

	static function init(parent:PlayField) {
		var view = parent.view;

		buffer = new Buffer<ActorElement>(128, 128, true);
		program = new Program(buffer);
		program.blendEnabled = true;

		/*program.injectIntoFragmentShader('
			vec4 flipTex( int textureID, float flipX, float flipY, float mirror )
			{
				vec2 coord = vTexCoord;

				if (flipX != 0.0) {
					coord.x = 1.0 - coord.x;
				}

				if (flipY != 0.0) {
					coord.y = 1.0 - coord.y;
				}

				if (mirror != 0.0) {
					coord.x = 1.0 - coord.x;
				}

				return getTextureColor( textureID, coord );
			}
		');

		program.setColorFormula('c * flipTex(chars_ID, _flipX, _flipY, _mirror)');*/

		view.addProgram(program);
	}

	static function uninit(parent:PlayField) {
		var view = parent.view;

		program = null;
		buffer.clear();
		buffer = null;
		view.removeProgram(program);
	}

	function new(name:String, x:Int = 0, y:Int = 0, fps:Int = 24) {
		super(x, y);

		this.name = name;
		setFps(fps);

		if (pathExists(IMAGE)) {
			var bytes = sys.io.File.getBytes(path(IMAGE));
			var pngData = TextureData.fromFormatPNG(bytes);
			tex = Texture.fromData(pngData);
			tex.smoothExpand = tex.smoothShrink = true;
		} else {
			throw "Image doesn't exist: " + path(IMAGE);
		}

		if (pathExists(XML)) {
			atlas = SparrowAtlas.parse(sys.io.File.getContent(path(XML)));
		} else if (pathExists(JSON)) {
			atlas = null; // TODO
		} else {
			throw "Atlas data doesn't exist: " + path(NONE);
		}

		changeFrame();

		program.addTexture(tex, "chars");
	}

	function dispose() {
		program.removeTexture(tex, "chars");
		tex.dispose();
		tex = null;
	}

	function path(type:CharacterPathType) {
		var result = 'assets/characters/$name';

		switch (type) {
			case IMAGE:
				result += '/sheet.png';
			case INFO:
				result += '/info.json';
			case XML:
				result += '/data.xml';
			case JSON:
				result += '/data.json';
			default:
		}

		return result;
	}

	// This is here to improve readability
	inline function pathExists(type:CharacterPathType) {
		return sys.FileSystem.exists(path(type));
	}

	// Now for the animation stuff
	// Part of the code is originally from jobf's sparrow atlas demo on peote-view

	private var frames:Array<SubTexture>;
	private var startingFrameIndex:Int;
	private var endingFrameIndex:Int;
	private var frameIndex:Int;
	private var fps:Float;
	private var frameDurationMs:Float;
	private var frameTimeRemaining:Float;
	private var loop:Bool;

	var animationRunning(default, null):Bool;

	function setFps(fps:Float) {
		this.fps = fps;
		frameDurationMs = 1000.0 / fps;
		frameTimeRemaining = frameDurationMs;
	}

	function playAnimation(name:String, loop:Bool = false) {
		var animMap = atlas.animMap[name];
		startingFrameIndex = animMap[0];
		endingFrameIndex = animMap[1];
		frameIndex = 0;
		animationRunning = true;
		this.loop = loop;
	}

	inline function stopAnimation() {
		animationRunning = false;
		loop = false;
	}

	function update(deltaTime:Float) {
		if (!animationRunning) return;
		if (frameIndex >= endingFrameIndex - startingFrameIndex) {
			loop = false;
			animationRunning = false;
			if (finishAnim != "") {
				playAnimation(finishAnim);
				finishAnim = "";
			}
			return;
		}

		frameTimeRemaining -= deltaTime;

		if (frameTimeRemaining <= 0) {
			if (loop) frameIndex = (frameIndex + 1) % (endingFrameIndex - startingFrameIndex);
			else frameIndex++;
			changeFrame();
			frameTimeRemaining = frameDurationMs;
		}
	}

	public function configure(config:SubTexture) {
		var width = 0;

		if (config.frameWidth != 0) {
			width = config.frameWidth;
		} else if (config.width != 0) {
			width = config.width;
		}

		var height = 0;

		if (config.frameHeight != 0) {
			height = config.frameHeight;
		} else if (config.height != 0) {
			height = config.height;
		}

		var xOffset = config.frameX == null ? 0 : config.frameX;
		var yOffset = config.frameY == null ? 0 : config.frameY;

		this.w = width;
		this.h = height;
		this.clipX = config.x + xOffset;
		this.clipY = config.y + yOffset;
		this.clipWidth = width;
		this.clipHeight = height;
	}

	function changeFrame() {
		configure(atlas.subTextures[startingFrameIndex + frameIndex]);
	}

	// The rest

	/*@varying @custom private var _flipX(default, null):Float = 0.0;

	var flipX(default, set):Bool;

	inline function set_flipX(value:Bool) {
		_flipX = value ? 1.0 : 0.0;
		return flipX = value;
	}

	@varying @custom private var _flipY(default, null):Float = 0.0;

	var flipY(default, set):Bool;

	inline function set_flipY(value:Bool) {
		_flipX = value ? 1.0 : 0.0;
		return flipY = value;
	}

	@varying @custom private var _mirror(default, null):Float = 0.0;

	var mirror(default, set):Bool;

	inline function set_mirror(value:Bool) {
		_mirror = value ? 1.0 : 0.0;
		return mirror = value;
	}*/
}

/**
	Basic actor element.
**/
@:publicFields
class ActorElement implements Element {
	@texX var clipX:Int = 0;
	@texY var clipY:Int = 0;
	@texW var clipWidth(default, set):Int = 1;
	@texH var clipHeight(default, set):Int = 1;

	inline function set_clipWidth(value:Int) {
		clipWidth = value;
		clipSizeX = value;
		return value;
	}

	inline function set_clipHeight(value:Int) {
		clipHeight = value;
		clipSizeY = value;
		return value;
	}

	@texSizeX private var clipSizeX:Int = 1;
	@texSizeY private var clipSizeY:Int = 1;

	@posX @formula("x + off_x + px + adjust_x") var x:Int;
	@posY @formula("y + off_y + py + adjust_x") var y:Int;
	@sizeX @formula("w * scale") var w:Int;
	@sizeY @formula("h * scale") var h:Int;

	@pivotX @formula("w * 0.5") var px:Int;
	@pivotY @formula("h * 0.5") var py:Int;

	@rotation var r:Float;

	@varying @custom @formula("off_x * scale") var off_x:Int;
	@varying @custom @formula("off_y * scale") var off_y:Int;
	@varying @custom var adjust_x:Int;
	@varying @custom var adjust_y:Int;
	@varying @custom var scale:Float = 1.0;

	function new(x:Int = 0, y:Int = 0) {
		this.x = x;
		this.y = y;
	}
}