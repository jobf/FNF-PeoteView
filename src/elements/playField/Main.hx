package elements.playField;

import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;
import lime.ui.KeyCode;

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
		new ChartNote(0, 120, 0, 0, 0),
		new ChartNote(60000, 120, 1, 0, 0),
		new ChartNote(75000, 0, 0, 0, 1),
		new ChartNote(90000, 0, 3, 0, 1),
		new ChartNote(105000, 0, 2, 0, 1),
		new ChartNote(120000, 120, 2, 0, 0),
		new ChartNote(120000, 120, 2, 0, 1),
		new ChartNote(180000, 120, 3, 0, 0),
		new ChartNote(180000, 120, 3, 0, 1),
		new ChartNote(240000, 0, 0, 0, 2),
		//new ChartNote(247500, 0, 0, 0, 1),
		new ChartNote(255000, 0, 0, 0, 2),
		//new ChartNote(262500, 0, 0, 0, 1),
		new ChartNote(270000, 0, 0, 0, 2),
		//new ChartNote(277500, 0, 0, 0, 1),
		new ChartNote(285000, 0, 0, 0, 2),
		//new ChartNote(292500, 0, 0, 0, 1),
		new ChartNote(300000, 120, 1, 0, 2),
		new ChartNote(360000, 120, 2, 0, 2),
		new ChartNote(420000, 30, 3, 0, 2),
		new ChartNote(450000, 30, 3, 0, 1),
		new ChartNote(480000, 960, 2, 0, 0),
		new ChartNote(480000, 960, 2, 0, 1),
		new ChartNote(480000, 960, 2, 0, 2)
	];

	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window);
		display = new Display(0, 0, window.width, window.height, Color.GREY2);

		peoteView.addDisplay(display);

		playField = new PlayField(display, true);
		playField.scrollSpeed = 2.0;

		var prop = playField.textureMapProperties;

		var nW = prop[0];
		var nH = prop[1];
		var sW = prop[2];
		var sH = prop[3];

		for (i in 0...notes.length) {
			var note = notes[i];
			var noteSpr = new Note(9999, 0, nW, nH);
			noteSpr.data = note;
			noteSpr.toNote();
            noteSpr.r = playField.strumlineMap[note.lane][note.index][0];
			playField.addNote(noteSpr);

			if (note.duration > 5) {
				var susSpr = new Sustain(9999, 0, sW, sH);
				susSpr.length = ((note.duration << 2) + note.duration) - 25;
				susSpr.w = susSpr.length;
				susSpr.r = playField.downScroll ? -90 : 90;
				susSpr.c.aF = Sustain.defaultAlpha;
				playField.addSustain(susSpr);

				susSpr.parent = noteSpr;
				noteSpr.child = susSpr;
			}
		}

		playField.numOfNotes = @:privateAccess playField.notesBuf.length - playField.numOfReceptors;

		window.onKeyDown.add(playField.keyPress);
		window.onKeyDown.add(changeTime);
		window.onKeyUp.add(playField.keyRelease);

		//// CALLBACK TEST ////
		playField.onNoteHit.add((note:ChartNote) -> {
			Sys.println('Hit ${note.index}, ${note.lane}');
		});

		playField.onNoteMiss.add((note:ChartNote) -> {
			Sys.println('Miss ${note.index}, ${note.lane}');
		});

		playField.onSustainComplete.add((note:ChartNote) -> {
			Sys.println('Complete ${note.index}, ${note.lane}');
		});

		playField.onSustainRelease.add((note:ChartNote) -> {
			Sys.println('Release ${note.index}, ${note.lane}');
		});
		///////////////////////

		peoteView.start();
	}

	function changeTime(code:KeyCode, mod) {
		switch (code) {
			case KeyCode.EQUALS:
				position += 2000;
				playField.setTime(position);
			case KeyCode.MINUS:
				position -= 2000;
				playField.setTime(position);
			default:
		}
	}

	override function update(deltaTime:Int) {
		position += deltaTime;
		//Sys.println(position);

		playField.update(position);
	}
}