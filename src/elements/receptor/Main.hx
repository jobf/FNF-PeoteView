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
	
	public function startSample(window:Window)
	{
		peoteView = new PeoteView(window);
		var display = new Display(0, 0, window.width, window.height, Color.GREY2);

		peoteView.addDisplay(display);

		var texture = new Texture(485, 164, null, {tilesX: 3, smoothExpand: true, smoothShrink: true, powerOfTwo: false});

		var textureBytes = sys.io.File.getBytes('assets/receptor/normal.png');
		var textureData = TextureData.RGBAfrom(TextureData.fromFormatPNG(textureBytes));

		texture.setData(textureData);

		Receptor.init(display, "receptorTex", texture);

		Receptor.keybindMap[KeyCode.A] = Receptor.keybindMap[KeyCode.LEFT] = 0;
		Receptor.keybindMap[KeyCode.S] = Receptor.keybindMap[KeyCode.DOWN] = 1;
		Receptor.keybindMap[KeyCode.W] = Receptor.keybindMap[KeyCode.UP] = 2;
		Receptor.keybindMap[KeyCode.D] = Receptor.keybindMap[KeyCode.RIGHT] = 3;

		var angles = [0, -90, 90, 180];

		for (i in 0...2) {
			for (j in 0...4) {
				var receptor = new Receptor(30 + (112 * j) + (640 * i), 30, 162, 164);
				receptor.r = angles[j];
			}
		}

		window.onKeyDown.add(Receptor.keyPress);
		window.onKeyUp.add(Receptor.keyRelease);

		peoteView.start();
	}

	override function update(deltaTime:Int) {
		var buffer = Receptor.buffer;
		for (i in 0...buffer.length) {
			buffer.updateElement(buffer.getElement(i));
		}
	}
}
