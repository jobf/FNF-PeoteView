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
	var conductor:Conductor;

	var position:Float = 0;

	var chart:Chart;

	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window);
		display = new Display(0, 0, window.width, window.height, Color.GREY2);

		peoteView.addDisplay(display);

		chart = new Chart("assets/songs/milf");

		var timeSig = chart.header.timeSig;
		conductor = new Conductor(chart.header.bpm, timeSig[0], timeSig[1]);

		conductor.onBeat.add((beat:Float) -> {
			Sys.println(beat);
		});

		UISprite.healthBarDimensions = Tools.parseHealthBarConfig('assets/ui');
		Note.offsetAndSizeFrames = Tools.parseFrameOffsets('assets/notes');

		playField = new PlayField(display, true);
		playField.scrollSpeed = 2.0;

		var dimensions = playField.sustainDimensions;

		var sW = dimensions[0];
		var sH = dimensions[1];

		var notes = chart.bytes;
		for (i in 0...notes.length) {
			var note = notes[i];
			var noteSpr = new Note(9999, 0, 0, 0);
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
		playField.onNoteHit.add((note:ChartNote, timing:Int) -> {
			//Sys.println('Hit ${note.index}, ${note.lane} - Timing: $timing');

			// Accumulate the combo and start determining the rating judgement

			++playField.combo;

			// This shows you how ratings work

			if (timing == 0) return; // Don't execute ratings if an opponent note has executed it or you somehow hit a note exactly at the receptor

			// Add the health

			playField.health += 0.05;

			if (playField.health > 1) {
				playField.health = 1;
			}

			var absTiming = Math.abs(timing);

			if (absTiming > 60) {
				playField.respondWithRatingID(3);
				playField.score += 50;

				return;
			}

			if (absTiming > 45) {
				playField.respondWithRatingID(2);
				playField.score += 100;

				return;
			}

			if (absTiming > 30) {
				playField.respondWithRatingID(1);
				playField.score += 200;

				return;
			}

			playField.respondWithRatingID(0);
			playField.score += 400;
		});

		playField.onNoteMiss.add((note:ChartNote) -> {
			//Sys.println('Miss ${note.index}, ${note.lane}');

			// Zero the combo
			playField.combo = 0;

			// Increment the misses
			++playField.misses;

			// Hurt the health
			playField.health -= 0.05;

			// Trigger a game over
			if (playField.health < 0) {
				Sys.println("Game Over");
				Sys.exit(1);
			}
		});

		playField.onSustainComplete.add((note:ChartNote) -> {
			//Sys.println('Complete ${note.index}, ${note.lane}');
		});

		playField.onSustainRelease.add((note:ChartNote) -> {
			//Sys.println('Release ${note.index}, ${note.lane}');
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

		conductor.time = position;
	}
}