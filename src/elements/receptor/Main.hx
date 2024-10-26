package elements.receptor;

import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;

class Main extends Application
{
	override function onWindowCreate():Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try startSample(window)
				catch (_) trace(CallStack.toString(CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}
	
	// ------------------------------------------------------------
	// --------------- SAMPLE STARTS HERE -------------------------
	// ------------------------------------------------------------	
	var peoteView:PeoteView;
	var display:Display;
	var playField:PlayField;

	var position:Float = -1000;

	var notes:Array<ChartNote> = [
		new ChartNote(0, 120, 0, 0, 1),
		new ChartNote(60000, 120, 1, 0, 1),
		new ChartNote(120000, 120, 2, 0, 1),
		new ChartNote(180000, 120, 3, 0, 1),
	];
	
	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window);
		display = new Display(0, 0, window.width, window.height, Color.GREY2);

		peoteView.addDisplay(display);

		playField = new PlayField(display);

		var prop = playField.textureMapProperties;

		var front = playField.frontBuf;
		var behind = playField.behindBuf;

		var nW = prop[0];
		var nH = prop[1];
		var sW = prop[2];
		var sH = prop[3];

		for (i in 0...notes.length) {
			var note = notes[i];
			var noteSpr = new Note(-nW, -nH, nW, nH);

			if (note.duration > 5) {
				var susSpr = new Sustain(-sW, -sH, sW, sH);
				behind.addElement(susSpr);

				susSpr.length = ((note.duration << 2) + note.duration) - 25;
				susSpr.r = 90;
				behind.updateElement(susSpr);

				noteSpr.child = susSpr;
			}

			noteSpr.data = note;
			noteSpr.toNote();
			front.addElement(noteSpr);
		}

		playField.numOfNotes = playField.frontBuf.length - playField.numOfReceptors;

		window.onKeyDown.add(playField.keyPress);
		window.onKeyUp.add(playField.keyRelease);

		peoteView.start();
	}

	override function update(deltaTime:Int) {
		position += deltaTime;

		playField.update(position);
	}
}