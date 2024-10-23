package elements.receptor;

@:publicFields
class ReceptorAndSteps {
    // This is where sustains will go
    private static var bottomBuffer(default, null):Buffer<Sustain>;
    private static var bottomProgram(default, null):Program;

    // This is where the receptor will go
    private static var middleBuffer(default, null):Buffer<Receptor>;
    private static var middleProgram(default, null):Program;

    // This is where steps will go
    private static var topBuffer(default, null):Buffer<Note>;
    private static var topProgram(default, null):Program;

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

        if (middleBuffer == null) middleBuffer = new Buffer<Receptor>(1, 128, false);

        var middleIsNull = middleProgram == null;
        if (middleIsNull) {
            middleProgram = new Program(middleBuffer);
            middleProgram.blendEnabled = true;

            var texture = new Texture(w * 3, h, null, {tilesX: 3, smoothExpand: true, smoothShrink: true, powerOfTwo: false});

            var textureBytes = sys.io.File.getBytes(receptorPath);
            var textureData = TextureData.fromFormatPNG(textureBytes);

            texture.setData(textureData);

            middleProgram.setTexture(texture, receptorName, true);
        }

        receptor = new Receptor(x, y, w, h, -27, -27);
        middleBuffer.addElement(receptor);

        // Note group setup

        if (topBuffer == null) topBuffer = new Buffer<Note>(1, 2048, false);

        var topIsNull = topProgram == null;
        if (topIsNull) {
            topProgram = new Program(topBuffer);
            topProgram.blendEnabled = true;

            var texture = new Texture(nW, nH, null, {smoothExpand: true, smoothShrink: true, powerOfTwo: false});

            var textureBytes = sys.io.File.getBytes(notePath);
            var textureData = TextureData.fromFormatPNG(textureBytes);

            texture.setData(textureData);
    
            topProgram.setTexture(texture, noteName, true);
        }

        var note = new Note(x, y + 450, nW, nH);
        topBuffer.addElement(note);

        // Note group setup

        if (bottomBuffer == null) bottomBuffer = new Buffer<Sustain>(1, 2048, false);

        var bottomIsNull = bottomProgram == null;
        if (bottomIsNull) {
            bottomProgram = new Program(bottomBuffer);
            bottomProgram.blendEnabled = true;

            var texture = new Texture(sW, sH, null, {smoothExpand: true, smoothShrink: true, powerOfTwo: false});

            var textureBytes = sys.io.File.getBytes(sustainPath);
            var textureData = TextureData.fromFormatPNG(textureBytes);

            texture.setData(textureData);

            Sustain.init(display, bottomProgram, sustainName, texture);
        }

        // Do this to finalize this instance.

		if (middleIsNull) display.addProgram(middleProgram);
		if (topIsNull) display.addProgram(topProgram);

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