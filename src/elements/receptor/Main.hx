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
	var sustainState:ReceptorState;
	
	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window);
		display = new Display(0, 0, window.width, window.height, Color.GREY2);

		peoteView.addDisplay(display);

		var angles = [0, -90, 90, 180];

		sustainState = new ReceptorState(display);

		window.onKeyDown.add(sustainState.keyPress);
		window.onKeyUp.add(sustainState.keyRelease);

		peoteView.start();
	}
}