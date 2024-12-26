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

    var tex(default, null):Texture;
    var name(default, null):String;
    var atlas(default, null):ActorAtlas;
    var loop:Bool;

    static function init(parent:PlayField) {
        var view = parent.view;

        buffer = new Buffer<ActorElement>(128, 128, true);
        program = new Program(buffer);
        program.blendEnabled = true;

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
        } else {
            throw "Image doesn't exist: " + path(IMAGE);
        }

        if (pathExists(XML)) {
            atlas = ActorAtlas.parseSparrow(path(XML));
        } else if (pathExists(JSON)) {
            atlas = null; // TODO
        } else {
            throw "Atlas data doesn't exist: " + path(NONE);
        }

        program.addTexture(tex, name);
    }

    function dispose() {
        program.removeTexture(tex, name);
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
    private var animationRunning:Bool;
	private var frameIndex:Int;
	private var fps:Float;
	private var frameDurationMs:Float;
	private var frameTimeRemaining:Float;

	function setFps(fps:Float) {
		this.fps = fps;
		frameDurationMs = 1000.0 / fps;
		frameTimeRemaining = frameDurationMs;
	}

	function playAnimation(startingFrame:Int, endingFrame:Int) {
        startingFrameIndex = startingFrame;
        endingFrameIndex = endingFrame;
		frameIndex = 0;
        animationRunning = true;
	}

    inline function stopAnimation() {
        animationRunning = false;
    }

	function update(deltaTime:Float) {
        if (!animationRunning) return;
        if (atlas.sparrow != null) {
            if (frameIndex >= endingFrameIndex - startingFrameIndex) {
                animationRunning = false;
                return;
            }

            frameTimeRemaining -= deltaTime;
    
            if (frameTimeRemaining <= 0) {
                if (loop) frameIndex = (frameIndex + 1) % (endingFrameIndex - startingFrameIndex);
                else frameIndex++;
                configure(x, y, atlas.getAtlas().subTextures[startingFrameIndex + frameIndex]);
                frameTimeRemaining = frameDurationMs;
            }
        } else {
            // TODO
        }
	}

	public function configure(x:Int, y:Int, config:SubTexture) {
		var width = config.frameWidth == null ? config.width : config.frameWidth;
		var height = config.frameHeight == null ? config.height : config.frameHeight;
		var xOffset = config.frameX == null ? 0 : config.frameX;
		var yOffset = config.frameY == null ? 0 : config.frameY;

		this.off_x = x;
		this.off_y = y;
		this.w = width;
		this.h = height;
		this.clipX = config.x + xOffset;
		this.clipY = config.y + yOffset;
		this.clipWidth = width;
		this.clipHeight = height;
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

    @posX @formula("x + off_x + px") var x:Int;
    @posY @formula("y + off_y + py") var y:Int;
    @sizeX @formula("w * scale") var w:Int;
    @sizeY @formula("h * scale") var h:Int;

	@pivotX @formula("w * 0.5") var px:Int;
	@pivotY @formula("h * 0.5") var py:Int;

    @rotation var r:Float;

    @varying @custom @formula("off_x * scale") var off_x:Int;
    @varying @custom @formula("off_y * scale") var off_y:Int;
    @varying @custom var scale:Float = 1.0;

    function new(x:Int = 0, y:Int = 0) {
        this.x = x;
        this.y = y;
    }
}

/**
    Character path type.
**/
enum abstract CharacterPathType(cpp.UInt8) {
    var IMAGE;
    var INFO;
    var XML;
    var JSON;
    var NONE;
}

/**
    Actor atlas.
    You choose between sparrow atlas and animate atlas.
**/
@:publicFields
@:structInit
class ActorAtlas {
    var sparrow(default, null):SparrowAtlas;
    var animate(default, null):Dynamic;

    function getAtlas() {
        if (sparrow != null) {
            return sparrow;
        } else if (animate != null) {
            return animate;
        } else {
            return null;
        }
    }

    static function parseSparrow(path:String):ActorAtlas {
        var content = sys.io.File.getContent(path);
        return {sparrow: SparrowAtlas.parse(content), animate: null};
    }
}