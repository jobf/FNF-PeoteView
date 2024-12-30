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

package elements;

import atlas.SparrowAtlas.SubTexture;
import elements.actor.*;

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
	var data(default, null):ActorData;

	var animRedirectionMap:Map<String, String>;

	var finishAnim:String = "";

	static function init(parent:PlayField) {
		var view = parent.view;

		buffer = new Buffer<ActorElement>(128, 128, true);
		program = new Program(buffer);
		program.blendEnabled = true;

		view.addProgram(program);
	}

	static function uninit(parent:PlayField) {
		var view = parent.view;

		view.removeProgram(program);
		program = null;
		buffer.clear();
		buffer = null;
	}

	function new(name:String, x:Int = 0, y:Int = 0, fps:Int = 24) {
		super(x, y);

		this.name = name;
		setFps(fps);

		if (pathExists(IMAGE)) {
			TextureSystem.createTexture(name, path(IMAGE));
			tex = TextureSystem.getTexture(name);
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

		if (pathExists(PSYCH_DATA)) {
			data = ActorData.fromPsychJSON(path(PSYCH_DATA));
		} else if (pathExists(FV_DATA)) {
			data = null; // TODO
		}

		mirror = data.flip;

		TextureSystem.setTexture(program, name, name);
	}

	function dispose() {
	}

	function path(type:CharacterPathType) {
		var result = 'assets/characters/$name';

		switch (type) {
			case IMAGE:
				result += '/sheet.png';
			case XML:
				result += '/data.xml';
			case JSON:
				result += '/data.json';
			case PSYCH_DATA:
				result += '/charDataP.json';
			case FV_DATA:
				result += '/charData.json';
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
	private var indicesMode:Bool;
	private var indices:Array<Int>;

	var shake:Bool;
	var startingShakeFrame:Int;
	var endingShakeFrame:Int;

	var animationRunning(default, null):Bool;

	function setFps(fps:Float) {
		this.fps = fps;
		frameDurationMs = 1000.0 / fps;
		frameTimeRemaining = frameDurationMs;
	}

	function playAnimation(name:String, loop:Bool = false) {
		frameIndex = 0;

		var animDataMap = data.data;
		if (animDataMap.exists(name)) {
			var oldName = name;

			var animData = animDataMap[name];

			name = animData.name;

			var ind = animData.indices;

			indicesMode = ind != null && ind.length != 0;

			if (indicesMode) {
				indices = ind;
				frameIndex = indices[0];
			}

			setFps(animData.fps);

			adjust_x = -animData.offsets[0];
			if (mirror) adjust_x = -adjust_x;
			adjust_y = -animData.offsets[1];
		} else {
			indicesMode = false;
			indices = null;
		}

		var animMap = atlas.animMap[name];
		startingFrameIndex = animMap[0];
		endingFrameIndex = animMap[1];
		animationRunning = true;
		this.loop = loop;
		changeFrame();
	}

	inline function stopAnimation() {
		animationRunning = loop = false;
	}

	inline function endOfAnimation():Bool {
		if (frameIndex >= endingFrameIndex - startingFrameIndex) {
			loop = false;
			animationRunning = false;
			if (finishAnim != "") {
				playAnimation(finishAnim);
				finishAnim = "";
			}
			return true;
		}
		return false;
	}

	function update(deltaTime:Float) {
		if (!animationRunning) return;
		frameTimeRemaining -= deltaTime;

		if (frameTimeRemaining <= 0) {
			if (loop) frameIndex = (frameIndex + 1) % (endingFrameIndex - startingFrameIndex);
			else frameIndex++;
			if (indicesMode && indices != null) frameIndex = indices[frameIndex];

			if (shake && frameIndex > endingShakeFrame) {
				frameIndex = startingShakeFrame;
			}

			if (endOfAnimation()) {
				return;
			}

			changeFrame();
			frameTimeRemaining = frameDurationMs;
		}
	}

	public function configure(config:SubTexture) {
		var width = config.width;
		var height = config.height;

		var xOffset = config.frameX == null ? 0 : config.frameX;
		var yOffset = config.frameY == null ? 0 : config.frameY;
		var flipX = config.flipX == null ? false : config.flipX;
		var flipY = config.flipY == null ? false : config.flipY;

		off_x = -xOffset;
		if (mirror) off_x = 0;
		off_y = -yOffset;

		w = width;
		h = height;
		this.flipX = flipX;
		this.flipY = flipY;
		clipX = config.x;
		clipY = config.y;
		clipWidth = w;
		clipHeight = h;
	}

	function changeFrame() {
		configure(atlas.subTextures[startingFrameIndex + frameIndex]);
	}
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

	@varying @custom @formula("_mirror == 1 ? (_flipX == 0 ? 1 : 0) : _flipX") var _flipX:Int = 0;
	@varying @custom var _flipY:Int = 0;
	@varying @custom var _mirror:Int = 0;

	var flipX(default, set):Bool;

	inline function set_flipX(value:Bool):Bool {
		_flipX = value ? 1 : 0;
		return flipX = value;
	}

	var flipY(default, set):Bool;

	inline function set_flipY(value:Bool):Bool {
		_flipY = value ? 1 : 0;
		return flipY = value;
	}

	var mirror(default, set):Bool;

	inline function set_mirror(value:Bool):Bool {
		_mirror = value ? 1 : 0;
		return mirror = value;
	}

	@posX @formula("x + off_x + px + adjust_x + (w * (_mirror == 1 ? _flipX : -_flipX))") var x:Int;
	@posY @formula("y + off_y + py + adjust_y + (h * _flipY)") var y:Int;
	@sizeX @formula("(w * scale) * (_flipX == 1 ? -1 : 1)") var w:Int;
	@sizeY @formula("(h * scale) * (_flipY == 1 ? -1 : 1)") var h:Int;

	@pivotX @formula("(w < 0 ? -w : w) * 0.5") var px:Int;
	@pivotY @formula("(h < 0 ? -h : h) * 0.5") var py:Int;

	@rotation var r:Float;

	@varying @custom @formula("off_x * scale") var off_x:Int;
	@varying @custom @formula("off_y * scale") var off_y:Int;
	@varying @custom var adjust_x:Int;
	@varying @custom var adjust_y:Int;
	@varying @custom var scale:Float = 1.0;

	@color var c:Color = 0xFFFFFFFF;

	function new(x:Int = 0, y:Int = 0) {
		this.x = x;
		this.y = y;
	}
}