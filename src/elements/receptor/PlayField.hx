package elements.receptor;

@:publicFields
class PlayField {
	private var textures(default, null):Map<String, Texture> = [];

	// This is where sustains will go
	var bottomBuffer:Buffer<Sustain>;
	var bottomProgram:Program;

	// This is where the receptor will go
	var middleBuffer:Buffer<Receptor>;
	var middleProgram:Program;

	// This is where steps will go
	var topBuffer:Buffer<Note>;
	var topProgram:Program;

	var display:Display;

	private var rW(default, null):Int;
	private var rH(default, null):Int;
	private var nW(default, null):Int;
	private var nH(default, null):Int;
	private var sW(default, null):Int;
	private var sH(default, null):Int;

	function new(view:PeoteView, w:Int, h:Int, c:Color,
		rW:Int, rH:Int,
		nW:Int, nH:Int,
		sW:Int, sH:Int,
		receptorPath:String, receptorName:String,
		notePath:String, noteName:String,
		sustainPath:String, sustainName:String) {
		this.rW = rW;
		this.rH = rH;
		this.nW = nW;
		this.nH = nH;
		this.sW = sW;
		this.sH = sH;

		if (!textures.exists(receptorName)) {
			var texture = new Texture(rW * 3, rH, null, {tilesX: 3, smoothExpand: true, smoothShrink: true, powerOfTwo: false});

			var textureBytes = sys.io.File.getBytes(receptorPath);
			var textureData = TextureData.fromFormatPNG(textureBytes);

			texture.setData(textureData);
			textures[receptorName] = texture;
		}

		if (!textures.exists(noteName)) {
			var texture = new Texture(nW, nH, null, {smoothExpand: true, smoothShrink: true, powerOfTwo: false});

			var textureBytes = sys.io.File.getBytes(notePath);
			var textureData = TextureData.fromFormatPNG(textureBytes);

			texture.setData(textureData);
			textures[noteName] = texture;
		}

		if (!textures.exists(sustainName)) {
			var texture = new Texture(sW, sH, null, {smoothExpand: true, smoothShrink: true, powerOfTwo: false});

			var textureBytes = sys.io.File.getBytes(sustainPath);
			var textureData = TextureData.fromFormatPNG(textureBytes);

			texture.setData(textureData);
			textures[sustainName] = texture;
		}

		display = new Display(0, 0, w, h, c);

		// Receptor and note group setup

		middleBuffer = new Buffer<Receptor>(1, 128, false);
		middleProgram = new Program(middleBuffer);
		middleProgram.blendEnabled = true;

		middleProgram.setTexture(textures[receptorName], receptorName, true);

		// Note group setup

		topBuffer = new Buffer<Note>(1, 1024, false);
		topProgram = new Program(topBuffer);
		topProgram.blendEnabled = true;

		topProgram.setTexture(textures[noteName], noteName, true);

		// Note group setup

		bottomBuffer = new Buffer<Sustain>(1, 1024, false);
		bottomProgram = new Program(bottomBuffer);
		bottomProgram.blendEnabled = true;

		// Do this to finalize this instance.

		Sustain.init(display, bottomProgram, sustainName, textures[sustainName]);
		display.addProgram(middleProgram);
		display.addProgram(topProgram);

		view.addDisplay(display);
	}

	function update(time:Float) {
		var tB = topBuffer;
		for (i in 0...tB.length) {
			var note = tB.getElement(i);
			tB.updateElement(note);
		}
	}

	function dispose() {
		topBuffer = null;
		middleBuffer = null;
		bottomBuffer = null;
		topProgram = null;
		middleProgram = null;
		bottomProgram = null;

		for (texture in textures) texture.dispose();
		textures.clear();
	}
}