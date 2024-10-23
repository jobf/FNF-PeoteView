package elements.receptor;

@:publicFields
class ReceptorAndSteps {
    // This is where sustains will go
    var bottomBuffer:Buffer<Sustain>;
    var bottomProgram:Program;

    // This is where the receptor will go
    var middleBuffer:Buffer<Receptor>;
    var middleProgram:Program;

    // This is where steps will go
    var topBuffer:Buffer<Note>;
    var topProgram:Program;

    var receptor:Receptor;

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

    private var nW(default, null):Int;
    private var nH(default, null):Int;
    private var sW(default, null):Int;
    private var sH(default, null):Int;

    function new(x:Int, y:Int,
        w:Int, h:Int,
        nW:Int, nH:Int,
        sW:Int, sH:Int,
        display:Display,
        receptorPath:String, receptorName:String,
        notePath:String, noteName:String,
        sustainPath:String, sustainName:String) {
        this.nW = nW;
        this.nH = nH;
        this.sW = sW;
        this.sH = sH;

        // Receptor and note group setup

        middleBuffer = new Buffer<Receptor>(1, 0, false);
        middleProgram = new Program(middleBuffer);
        middleProgram.blendEnabled = true;

        if (!textures.exists(receptorName)) {
            var texture = new Texture(w * 3, h, null, {tilesX: 3, smoothExpand: true, smoothShrink: true, powerOfTwo: false});

            var textureBytes = sys.io.File.getBytes(receptorPath);
            var textureData = TextureData.fromFormatPNG(textureBytes);

            texture.setData(textureData);
            textures[receptorName] = texture;
        }

		middleProgram.setTexture(textures[receptorName], receptorName, true);

        receptor = new Receptor(x, y, w, h, -27, -27);
        middleBuffer.addElement(receptor);

        // Note group setup

        topBuffer = new Buffer<Note>(2048, 2048, false);
        topProgram = new Program(topBuffer);
        topProgram.blendEnabled = true;

        if (!textures.exists(noteName)) {
            var texture = new Texture(nW, nH, null, {smoothExpand: true, smoothShrink: true, powerOfTwo: false});

            var textureBytes = sys.io.File.getBytes(notePath);
            var textureData = TextureData.fromFormatPNG(textureBytes);

            texture.setData(textureData);
            textures[noteName] = texture;
        }

		topProgram.setTexture(textures[noteName], noteName, true);

        var note = new Note(x, y + 450, nW, nH);
        topBuffer.addElement(note);

        // Note group setup

        bottomBuffer = new Buffer<Sustain>(2048, 2048, false);
        bottomProgram = new Program(bottomBuffer);
        bottomProgram.blendEnabled = true;

        if (!textures.exists(sustainName)) {
            var texture = new Texture(sW, sH, null, {smoothExpand: true, smoothShrink: true, powerOfTwo: false});

            var textureBytes = sys.io.File.getBytes(sustainPath);
            var textureData = TextureData.fromFormatPNG(textureBytes);

            texture.setData(textureData);
            textures[sustainName] = texture;
        }

        // Do this to finalize this instance.

		Sustain.init(display, bottomProgram, sustainName, textures[sustainName]);
		display.addProgram(middleProgram);
		display.addProgram(topProgram);

        var sustain = new Sustain(note.x + (nW >> 1), note.y + ((nH - sH) >> 1), sW, sH);
        sustain.tailPoint = 45;
        sustain.r = 90;
        sustain.w = 100;
        bottomBuffer.addElement(sustain);
    }

    inline function updateReceptor() {
        middleBuffer.updateElement(receptor);
    }
}