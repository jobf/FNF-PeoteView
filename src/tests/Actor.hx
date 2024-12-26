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

/**
    Actor element object meant to be in the field of the gameplay state.
**/
@:publicFields
class Actor extends ActorElement
{
    static var buffer:Buffer<ActorElement>;
    static var program:Program;

    var tex(default, null):Texture;
    var name(default, null):String;
    var atlas(default, null):ActorAtlas;

    static function init(parent:PlayField) {
        var view = parent.view;

        buffer = new Buffer<ActorElement>(128, 128, true);
        program = new Program(buffer);
        view.addProgram(program);
    }

    static function uninit(parent:PlayField) {
        var view = parent.view;

        program = null;
        buffer.clear();
        buffer = null;
        view.removeProgram(program);
    }

    function new(name:String) {
        super();

        this.name = name;

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

    @posX @formula("x + off_x + px") var x:Float;
    @posY @formula("y + off_y + py") var y:Float;
    @sizeX @formula("w * scale") var w:Float;
    @sizeY @formula("h * scale") var h:Float;

	@pivotX @formula("w * 0.5") var px:Int;
	@pivotY @formula("h * 0.5") var py:Int;

    @rotation var r:Float;

    @varying @custom var off_x:Float;
    @varying @custom var off_y:Float;
    @varying @custom var scale:Float = 1.0;

    function new(x:Float = 0.0, y:Float = 0.0) {
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
        return {sparrow: SparrowAtlas.parse(path), animate: null};
    }
}