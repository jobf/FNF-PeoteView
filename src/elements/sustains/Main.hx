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

		trace('MAX UNITS ${peoteView.gl.getParameter(peoteView.gl.MAX_TEXTURE_IMAGE_UNITS)}');

		var texture = new Texture(76, 35, null, {smoothExpand: true, smoothShrink: true, powerOfTwo: false});

		var textureBytes = sys.io.File.getBytes('assets/sustains/3.png');
		var textureData = TextureData.RGBAfrom(TextureData.fromFormatPNG(textureBytes));

		texture.setData(textureData);

		Default.init(display, "def", texture); new Default(600, 600, 150, 50);

		HSlice.init(display, "def1", texture); new HSlice(0, 100, 250, 50);
		new HSlice(0, 200, 400, 50);
		new HSlice(0, 300, 300, 50);

		HSliceRepeat.init(display, "texRepeat", texture);

		#if stressTest
		for (j in 0...4000) {
			var sustain = new HSliceRepeat(30 + j, 30, 450, 35);
			sustain.c.aF = 0.003;
			HSliceRepeat.buffer.updateElement(sustain);
		}
		#else
		new HSliceRepeat(30, 30, 450, 35);
		#end

		window.onRender.add(_update);

		peoteView.start();
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
