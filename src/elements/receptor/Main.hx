package elements.receptor;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.KeyCode;
import lime.graphics.Image;

import peote.view.*;

import utils.Loader;

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
	
	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window);
		display = new Display(0, 0, window.width, window.height, Color.GREY2);

		peoteView.addDisplay(display);

		var angles = [0, -90, 180, 90, 0, 90, 180];

		var receptor = new ReceptorAndSteps(50, 50, 162, 164, display, "assets/receptor/normal.png", "receptorTex");
		/*for (i in 0...2) {
			for (j in 0...7) {
				var receptor = new ReceptorAndSteps(50 + (78 * j) + (640 * i), 50, 162, 164, display, "assets/receptor/normal.png", "receptorTex");
				receptor.scale = 0.75;
				receptor.r = angles[j];
			}
		}*/

		//window.onKeyDown.add(Receptor.keyPress);
		//window.onKeyUp.add(Receptor.keyRelease);

		peoteView.start();
	}
}
