package elements.receptor;

import lime.ui.KeyCode;
import sys.io.File;

@:publicFields
class ReceptorState {
    // Behind the receptor system
    var behindBuf:Buffer<Sustain>;
    var frontBuf:Buffer<Note>;

    // Above the receptor system
    var behindProg:Program;
    var frontProg:Program;

    var rec:Note;

    function new(display:Display) {
        // Note to self: set the texture size exactly to the image's size

        // NOTE SHEET SETUP
        var tilesheetTex = new Texture(648, 164, null, {tilesX: 4, smoothExpand: true, smoothShrink: true, powerOfTwo: false});

		var data = TextureData.fromFormatPNG(File.getBytes("assets/notes/normal/noteSheet.png"));
		tilesheetTex.setData(data);

        frontBuf = new Buffer<Note>(8192, 8192, false);
        frontProg = new Program(frontBuf);
        frontProg.blendEnabled = true;
        frontProg.setTexture(tilesheetTex, "noteTex");

        // SUSTAIN SETUP

        var sustainTex = new Texture(45, 35, null, {smoothExpand: true, smoothShrink: true, powerOfTwo: false});

		var data = TextureData.fromFormatPNG(File.getBytes("assets/notes/normal/sustain.png"));
		sustainTex.setData(data);

        behindBuf = new Buffer<Sustain>(8192, 8192, false);
        behindProg = new Program(behindBuf);
        behindProg.blendEnabled = true;

		Sustain.init(behindProg, "sustainTex", sustainTex);

		display.addProgram(behindProg);
		display.addProgram(frontProg);

		rec = new Note(50, 50, 162, 164);
        frontBuf.addElement(rec);

        //for (i in 0...20) {
            var note = new Note(rec.x, rec.y + (25/* * (i + 1)*/), 162, 164);
            note.toNote();
            //note.c.aF = 0.5;
            frontBuf.addElement(note);

            var sus = new Sustain(note.x, note.y, 45, 35);
            sus.x += note.w >> 1;
            sus.y += (note.h - sus.initH) >> 1;

            //sus.r = 90;
            sus.sustainLength = 30;
            //sus.speed = 2;
            behindBuf.addElement(sus);
        //}
    }

    function keyPress(code:KeyCode, mod) {
        switch (code) {
            case SPACE:
                rec.press();
                frontBuf.updateElement(rec);
            case RETURN:
                rec.confirm();
                frontBuf.updateElement(rec);
            default:
        }
    }

    function keyRelease(code:KeyCode, mod) {
        if (code == SPACE || code == RETURN) {
            rec.reset();
            frontBuf.updateElement(rec);
        }
    }
}