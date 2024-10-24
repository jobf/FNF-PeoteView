package elements.receptor;

import lime.ui.KeyCode;
import sys.io.File;

@:publicFields
class ReceptorState {
    var buffer:Buffer<Note>;
    var program:Program;

    var rec:Note;

    function new(display:Display) {
        // Note to self: set the texture size exactly to the image's size
        var tilesheetTex = new Texture(810, 164, null, {tilesX: 5, smoothExpand: true, smoothShrink: true, powerOfTwo: false});

		var data = TextureData.fromFormatPNG(File.getBytes("assets/notes/normal/sheet.png"));
		tilesheetTex.setData(data);

        buffer = new Buffer<Note>(8192, 8192, false);
        program = new Program(buffer);

		Note.init(program, "tilesheetTex", tilesheetTex);
		display.addProgram(program);

		rec = new Note(0, 0, 162, 164);
        buffer.addElement(rec);

		var note = new Note(rec.x, rec.y + 185, 162, 164);
        note.toNote();
        note.c.aF = 0.5;
        buffer.addElement(note);

		var sus = new Note(note.x, note.y, 162, 164);
        sus.toSustain();
        //sus.r = 90;
        sus.tailPoint = 58;
        sus.w = 1100;
        buffer.addElement(sus);
    }

    function keyPress(code:KeyCode, mod) {
        switch (code) {
            case SPACE:
                rec.press();
                buffer.updateElement(rec);
            case RETURN:
                rec.confirm();
                buffer.updateElement(rec);
            default:
        }
    }

    function keyRelease(code:KeyCode, mod) {
        if (code == SPACE || code == RETURN) {
            rec.reset();
            buffer.updateElement(rec);
        }
    }
}