package elements.sustains;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;
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
	
	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window);
		var display = new Display(0, 0, window.width, window.height, Color.GREY2);

		peoteView.addDisplay(display);
		
		Loader.image ("assets/tail.png", true, function (image:Image) 
		{
			var texture = new Texture(image.width, image.height, 2);

			texture.setData(image);

			Default.init(display, "def", texture); new Default(600, 600, 150, 50);

			HSlice.init(display, "def1", texture); new HSlice(0, 100, 250, 50);
			new HSlice(0, 200, 400, 50);
			new HSlice(0, 300, 300, 50);
	
			HSliceRepeat.init(display, "texRepeat", texture);

			#if stressTest
			for (i in 0...4000) {
				var sustain = new HSliceRepeat(30 + Math.floor(i * 0.2), 30, 450, 35);
				sustain.c.aF = 0.0003;
			}
			#else
			var sustain = new HSliceRepeat(30, 30, 450, 35);
			sustain.c.aF = 0.0003;
			#end

			window.onRender.add(_update);

			peoteView.start();
		});
	}

	//var time:Float = 0;
	function _update(ctx):Void {
		//time += deltaTime * 0.01;

		var spr = HSliceRepeat.buffer.getElement(0);

		//spr.w = Math.floor(Math.sin(time) * 200);
		spr.r += 4;
		HSliceRepeat.buffer.updateElement(spr);
	}
}
