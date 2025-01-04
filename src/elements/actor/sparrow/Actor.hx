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

package elements.actor.sparrow;

import atlas.SparrowAtlas.SubTexture;
import elements.actor.*;

/**
	Actor element object meant to be in the field of the gameplay state.
**/
@:publicFields
class Actor extends ActorElement
{
	// Stuff for initialization and shit

	static var buffer : Buffer<ActorElement>;
	static var program : Program;

	static var charToUnits(default, null) : Map<String, Int> = [];
	var name(default, null) : String;
	var atlas(default, null) : SparrowAtlas;
	var data(default, null) : ActorData;

	var finishAnim = "";

	@texUnit("chars") public var unit = 0;

	private var folder = "";

	static function init(parent:PlayField)
	{
		var view = parent.view;

		if (buffer == null)
		{
			buffer = new Buffer<ActorElement>(4, 4, true);
		}

		if (program == null)
		{
			program = new Program(buffer);
			program.blendEnabled = true;
		}

		view.addProgram(program);
	}

	static function loadTexturesOf(chars:Array<String>)
	{
		TextureSystem.createMultiTexture("chars", [for (i in 0...chars.length) {
			var char = chars[i];
			charToUnits[char] = i;
			path(char, "characters/", IMAGE);
		}]);
		TextureSystem.setTexture(program, "chars", "chars");
	}

	static function uninit(parent:PlayField)
	{
		parent.view.removeProgram(program);
		buffer.clear();
	}

	function new(name:String, x=0, y=0, fps=24, folder="characters/") {
		super(x, y);

		this.folder = folder;

		this.name = name;
		setFps(fps);

		if (pathExists(name, folder, XML))
		{
			atlas = SparrowAtlas.parse(sys.io.File.getContent(path(name, folder, XML)));
		}
		else
		{
			throw "Atlas data doesn't exist: " + path(name, folder, NONE);
		}

		if (pathExists(name, folder, DATA))
		{
			data = ActorData.parse(path(name, folder, DATA));
		}

		unit = charToUnits[name];

		mirror = !data.flip;
		scale = data.scale;
	}

	static function path(name:String, folder:String, type:CharacterPathType)
	{
		var result = 'assets/$folder$name';

		switch (type)
		{
			case IMAGE:
				result += '/sheet.png';
			case XML:
				result += '/data.xml';
			case JSON:
				result += '/data.json';
			case DATA:
				result += '/charData.json';
			default:
		}

		return result;
	}

	// This is here to improve readability
	static function pathExists(name:String, folder:String, type:CharacterPathType)
	{
		return sys.FileSystem.exists(path(name, folder, type));
	}

	// Now for the animation stuff
	// Part of the code is originally from jobf's sparrow atlas demo on peote-view

	private var startingFrameIndex : Int;
	private var endingFrameIndex : Int;
	private var frameIndex : Int;
	private var fps : Float;
	private var frameDurationMs : Float;
	private var frameTimeRemaining : Float;
	private var loop : Bool;
	private var indicesMode : Bool;
	private var indices : Vector<Int>;

	var shake : Bool;
	var startingShakeFrame : Int;
	var endingShakeFrame : Int;

	var animationRunning(default, null) : Bool;

	function setFps(fps:Float)
	{
		this.fps = fps;
		frameDurationMs = 1000.0 / fps;
		frameTimeRemaining = frameDurationMs;
	}

	function playAnimation(name:String, loop=false)
	{
		frameIndex = 0;

		var animDataMap = data.data;
		if (animDataMap.exists(name))
		{
			var oldName = name;

			var animData = animDataMap[name];

			name = animData.name;

			adjust_x = -animData.offsets[0];
			if (mirror) adjust_x = -adjust_x;
			adjust_y = -animData.offsets[1];

			var ind = animData.indices;

			indicesMode = ind != null && ind.length != 0;

			if (indicesMode)
			{
				indices = ind;
				frameIndex = indices[0];
			}

			loop = animData.loop;

			setFps(animData.fps);
		}
		else
		{
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

	inline function stopAnimation()
	{
		animationRunning = loop = false;
	}

	inline function endOfAnimation() : Bool
	{
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

	function update(deltaTime:Float)
	{
		if (!animationRunning) return;
		frameTimeRemaining -= deltaTime;

		if (frameTimeRemaining <= 0)
		{
			if (loop) frameIndex = (frameIndex + 1) % (endingFrameIndex - startingFrameIndex);
			else frameIndex++;
			if (indicesMode && indices != null) frameIndex = indices[frameIndex];

			if (shake && frameIndex > endingShakeFrame)
			{
				frameIndex = startingShakeFrame;
			}

			if (endOfAnimation())
			{
				return;
			}

			changeFrame();
			frameTimeRemaining = frameDurationMs;
		}
	}

	public function configure(config:SubTexture)
	{
		var width = config.width;
		var height = config.height;

		var xOffset = config.frameX == null ? 0 : config.frameX;
		var yOffset = config.frameY == null ? 0 : config.frameY;
		var flipX = config.flipX == null ? false : config.flipX;
		var flipY = config.flipY == null ? false : config.flipY;

		off_x = -xOffset;
		if (mirror) off_x += width % xOffset;// This needs done
		off_y = -yOffset;

		w = width;
		h = height;
		this.flipX = flipX;
		this.flipY = flipY;
		clipX = config.x;
		clipY = config.y;
		clipWidth = width;
		clipHeight = height;

		var multiTexLocationMap = TextureSystem.multitexLocMap;

		if (multiTexLocationMap.exists("chars")) {
			clipX += multiTexLocationMap["chars"][unit];
		}
	}

	function changeFrame()
	{
		configure(atlas.subTextures[startingFrameIndex + frameIndex]);
	}
}