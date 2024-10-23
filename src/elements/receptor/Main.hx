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
	var playField:PlayField;
	
	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window);

		playField = new PlayField(peoteView,
			window.width, window.height, Color.GREY2,
			162, 164,
			108, 110,
			45, 35,
			"assets/notes/normal/receptor.png", "receptorTex",
			"assets/notes/normal/note.png", "noteTex",
			"assets/notes/normal/sustain.png", "sustainTex"
		);

		//window.onKeyDown.add(Receptor.keyPress);
		//window.onKeyUp.add(Receptor.keyRelease);

		peoteView.start();
	}
}
