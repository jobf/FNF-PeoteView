package elements.actor.sparrow;

import atlas.SparrowAtlas.SubTexture;
import elements.actor.*;
using StringTools;

/**
	Sparrow atlas actor element object meant to be in the field of the gameplay state.
**/
@:publicFields
class Actor extends ActorElement
{
	// Stuff for initialization and shit

	static var buffers:Map<String, Buffer<ActorElement>> = [];
	static var programs:Map<String, Program> = [];
	static var copiesOfCharacters:Map<String, Int> = [];

	var name(default, null):String;
	var displayName(default, null):String;
	var atlas(default, null):SparrowAtlas;
	var data(default, null):ActorData;

	var finishAnim:String = "";
	var finishCallback:Void->Void;

	private var folder:String = "";

	var display(default, null):CustomDisplay;

	function new(display:CustomDisplay, name:String, x:Int = 0, y:Int = 0, fps:Int = 24, folder:String = "characters/", addBufferAndProgram:Bool = true) {
		this.display = display;

		super(x, y);

		this.folder = folder;

		this.name = displayName = name;

		var spritesheetDataPath = "";

		if (pathExists(name, folder, XML)) {
			spritesheetDataPath = path(name, folder, XML);
			atlas = SparrowAtlas.parse(sys.io.File.getContent(spritesheetDataPath));
		} else {
			throw "Atlas data doesn't exist: " + path(name, folder, NONE);
		}

		if (pathExists(name, folder, DATA)) {
			data = ActorData.parse(path(name, folder, DATA));
		}

		if (atlas.imagePath != "" && addBufferAndProgram) {
			if (buffers.exists(displayName)) {
				if (!copiesOfCharacters.exists(name)) {
					copiesOfCharacters[name] = 0;
				}
				displayName += Std.string(copiesOfCharacters[name]++);
			}

			if (!buffers.exists(displayName)) {
				buffers[displayName] = new Buffer<ActorElement>(1);
			}

			if (!programs.exists(displayName)) {
				var program = programs[displayName] = new Program(buffers[displayName]);
				program.blendEnabled = true;
			}

			display.addProgram(programs[displayName]);

			var texName = name + "Char";
			TextureSystem.createTexture(texName, spritesheetDataPath.replace("data.xml", atlas.imagePath));
			TextureSystem.setTexture(programs[displayName], texName, texName);
		}

		setFps(fps);

		mirror = !data.flip;
		scale = data.scale;
	}

	inline function addToBuffer() {
		buffers[displayName].addElement(this);
	}

	static function path(name:String, folder:String, type:CharacterPathType) {
		var result = 'assets/$folder$name';

		switch (type) {
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
	static function pathExists(name:String, folder:String, type:CharacterPathType) {
		return sys.FileSystem.exists(path(name, folder, type));
	}

	// Now for the animation stuff
	// Part of the code is originally from jobf's sparrow atlas demo on peote-view

	private var startingFrameIndex:Int;
	private var endingFrameIndex:Int;
	private var frameIndex:Int;
	private var fps:Float;
	private var frameDurationMs:Float;
	private var frameTimeRemaining:Float;
	private var loop:Bool;
	private var indicesMode:Bool;
	private var indices:Vector<Int>;
	private var firstFrameWidth(get, default):Float;

	inline function get_firstFrameWidth() {
		return firstFrameWidth * scale;
	}

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
		this.loop = loop;

		var animDataMap = data.data;
		if (animDataMap.exists(name)) {
			var oldName = name;

			var animData = animDataMap[name];

			name = animData.name;

			adjust_x = -animData.offsets[0];
			if (mirror) adjust_x = -adjust_x;
			adjust_y = -animData.offsets[1];

			var ind = animData.indices;

			indicesMode = ind != null && ind.length != 0;

			if (indicesMode) {
				indices = ind;
				frameIndex = indices[0];
			}

			loop = animData.loop;

			setFps(animData.fps);
		} else {
			indicesMode = false;
			indices = null;
		}

		var animMap = atlas.animMap[name];
		startingFrameIndex = animMap[0];
		endingFrameIndex = animMap[1];
		animationRunning = true;

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
				if (finishCallback != null) {
					finishCallback();
					finishCallback = null;
				}
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

			if (shake && frameIndex > endingShakeFrame) {
				frameIndex = startingShakeFrame;
			}

			if (indicesMode && indices != null) frameIndex = indices[frameIndex];

			if (endOfAnimation()) {
				return;
			}

			changeFrame();
			frameTimeRemaining = frameDurationMs;
		}

		buffers[displayName].updateElement(this);
	}

	public function configure(config:SubTexture) {
		var width = config.width;
		var height = config.height;

		var xOffset = config.frameX == null ? 0 : config.frameX;
		var yOffset = config.frameY == null ? 0 : config.frameY;
		var flipX = config.flipX == null ? false : config.flipX;
		var flipY = config.flipY == null ? false : config.flipY;
		var frameWidth = config.frameWidth == null ? 0 : config.frameWidth;

		off_x = -xOffset * scale;
		if (mirror) off_x = -off_x + (frameWidth - width); // This needs done
		off_y = -yOffset * scale;

		w = width;
		h = height;
		this.flipX = flipX;
		this.flipY = flipY;
		clipX = config.x;
		clipY = config.y;
		clipWidth = width;
		clipHeight = height;
	}

	function changeFrame() {
		configure(atlas.subTextures[startingFrameIndex + frameIndex]);
	}

	function dispose() {
		display.removeProgram(programs[displayName]);
		display = null;

		buffers[displayName].clear();
	}
}