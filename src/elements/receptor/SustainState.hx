package elements.receptor;

@:publicFields
class SustainState {
    var buffer:Buffer<Sustain>;
    var program:Program;

    function new(display:Display) {
        var texture = new Texture(162, 164, null, {tilesX: 3, tilesY: 2, smoothExpand: true, smoothShrink: true, powerOfTwo: false});

		var textureBytes = sys.io.File.getBytes("assets/notes/normal/sheet.png");
		var textureData = TextureData.fromFormatPNG(textureBytes);

		texture.setData(textureData);

        buffer = new Buffer<Sustain>(8192, 8192, false);
        program = new Program(buffer);

		Sustain.init(display, program, "noteSkinTex", texture);

		var sustain = new Sustain(50, 50, 162, 164);
        buffer.addElement(sustain);
    }
}