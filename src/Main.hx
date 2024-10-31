package;

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

	var bottomDisplay:Display;
	var middleDisplay:Display;
	var topDisplay:Display;

	var playField:PlayField;

	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window);

		bottomDisplay = new Display(0, 0, window.width, window.height, 0x00000000);
		bottomDisplay.hide();

		// Coming soon...

		middleDisplay = new Display(0, 0, window.width, window.height, 0x00000000);

		topDisplay = new Display(0, 0, window.width, window.height, 0x00000000);
		topDisplay.hide();

		playField = new PlayField(middleDisplay, true);

		window.onKeyDown.add(playField.keyPress);
		window.onKeyDown.add(changeTime);
		window.onKeyUp.add(playField.keyRelease);

		peoteView.start();

		peoteView.addDisplay(bottomDisplay);
		peoteView.addDisplay(middleDisplay);
		peoteView.addDisplay(topDisplay);

		//GC.enable(false);
	}

	function changeTime(code:KeyCode, mod) {
		switch (code) {
			case KeyCode.EQUALS:
				playField.setTime(playField.songPosition + 2000);
			case KeyCode.MINUS:
				playField.setTime(playField.songPosition - 2000);
			default:
		}
	}

	override function update(deltaTime:Int) {
		playField.songPosition += deltaTime;
		playField.update(deltaTime);
	}
}