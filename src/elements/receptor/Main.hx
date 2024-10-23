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
	var receptors:Array<ReceptorAndSteps> = [];
	
	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window);
		display = new Display(0, 0, window.width, window.height, Color.GREY2);

		peoteView.addDisplay(display);

		var angles = [0, -90, 90, 180];

		if (false) {
			var receptor = new ReceptorAndSteps(50, 50,
			162, 164,
			108, 110,
			45, 35,
			display,
			"assets/notes/normal/receptor.png", "receptorTex",
			"assets/notes/normal/note.png", "noteTex",
			"assets/notes/normal/sustain.png", "sustainTex");
			receptors.push(receptor);
		} else {
			for (j in 0...4) {
				var receptor = new ReceptorAndSteps(50 + (112 * j) + 640, 50,
				162, 164,
				108, 110,
				45, 35,
				display,
				"assets/notes/normal/receptor.png", "receptorTex",
				"assets/notes/normal/note.png", "noteTex",
				"assets/notes/normal/sustain.png", "sustainTex");
				receptor.r = angles[j];
				receptors.push(receptor);
			}
		}

		//window.onKeyDown.add(Receptor.keyPress);
		//window.onKeyUp.add(Receptor.keyRelease);

		peoteView.start();
	}

	override function update(deltaTime:Int) {
		for (i in 0...receptors.length) {
			var receptor = receptors[i];
			receptor.updateReceptor();
		}
	}
}