package elements.receptor;

@:publicFields
class ReceptorAndSteps {
    var bottomBuffer:Buffer<Sustain>;
    var bottomProgram:Program;

    var topBuffer:Buffer<Note>;
    var topProgram:Program;

    var receptor:Note;

    var x(get, set):Int;

    inline function get_x() {
        return receptor.x;
    }

    inline function set_x(value:Int) {
        return receptor.x = value;
    }

    var y(get, set):Int;

    inline function get_y() {
        return receptor.y;
    }

    inline function set_y(value:Int) {
        return receptor.y = value;
    }

    var r(get, set):Float;

    inline function get_r() {
        return receptor.r;
    }

    inline function set_r(value:Float) {
        return receptor.r = value;
    }

    var scale(get, set):Float;

    inline function get_scale() {
        return receptor.scale;
    }

    inline function set_scale(value:Float) {
        return receptor.scale = value;
    }

    private static var textures(default, null):Map<String, Texture> = [];

    function new(x:Int, y:Int, w:Int, h:Int, display:Display, path:String, name:String) {
        bottomBuffer = new Buffer<Sustain>(2048, 2048, false);
        bottomProgram = new Program(bottomBuffer);

        topBuffer = new Buffer<Note>(2048, 2048, false);
        topProgram = new Program(topBuffer);

        // Receptor and note group setup
        if (!textures.exists(name)) {
            var texture = new Texture(485, 164, null, {tilesX: 3, smoothExpand: true, smoothShrink: true, powerOfTwo: false});

            var textureBytes = sys.io.File.getBytes(path);
            var textureData = TextureData.RGBAfrom(TextureData.fromFormatPNG(textureBytes));

            texture.setData(textureData);
            textures[name] = texture;
        }

		topProgram.setTexture(textures[name], name, true);

		display.addProgram(topProgram);

        receptor = new Note(x, y, w, h);
        topBuffer.addElement(receptor);

        // Sustain group setup
    }
}