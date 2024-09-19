package;

import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;
import lime.graphics.Image;
import utils.Loader;
import peote.view.*;

class Main extends Application {
	var screenSprite:Sprite;
	var screenBuffer:Buffer<Sprite>;


	override function onWindowCreate():Void {
		switch (window.context.type) {
			case WEBGL, OPENGL, OPENGLES:
				try
					startSample(window)
				catch (_)
					trace(CallStack.toString(CallStack.exceptionStack()), _);
			default:
				throw("Sorry, only works with OpenGL.");
		}
	}

	// ------------------------------------------------------------
	// --------------- SAMPLE STARTS HERE -------------------------
	// ------------------------------------------------------------

	public function startSample(window:Window) {
		var peoteView = new PeoteView(window);

		// display that will render the final pixels
		var screen = new Display(0, 0, window.width, window.height);
		peoteView.addDisplay(screen);

		// display that will render bunny sprite on (notice it is not added to peote-view like a normal display but added as a framebuffer)
		var framebufferDisplay = new Display(0, 0, window.width, window.height, Color.GREY1);
		peoteView.addFramebufferDisplay(framebufferDisplay);

		// texture that the framebuffer display will render to
		var framebufferTexture = new Texture(framebufferDisplay.width, framebufferDisplay.height);
		framebufferDisplay.setFramebuffer(framebufferTexture);

		// we need an element that renders the framebuffer texture so set that up with program etc
		screenBuffer = new Buffer<Sprite>(1);
		var screenProgram = new Program(screenBuffer);
		screen.addProgram(screenProgram);
		screenProgram.addTexture(framebufferTexture, "framebufferTexture");
		screenSprite = new Sprite();
		screenSprite.w = screen.width;
		screenSprite.h = screen.height;
		// sets the pivot (center) to the middle of the sprite, so it rotates from the middle

		screenBuffer.addElement(screenSprite);


		Loader.image("assets/peote_tiles_bunnys.png", (image:Image) -> {

			var bunnyCount = 1000;
			var buffer = new Buffer<Sprite>(bunnyCount);
			var program = new Program(buffer);
			// add the program to the frame buffer display (not the display that peote-view is rendering directly)
			framebufferDisplay.addProgram(program);

			// set the buny texture
			var texture = Texture.fromData(image);

			// here we say the texture is 16 tiles wide and 16 tiles high, each tile within is indexed 
			texture.tilesX = 16;
			texture.tilesY = 16;
			program.addTexture(texture, "bunnies");

			var maximumTileIndex = 31;
			for (i in 0...bunnyCount) {
				var bunny = new Sprite();
				// set the index to set which tile should be used
				bunny.tileIndex = Std.int(maximumTileIndex * Math.random());
				bunny.x = Std.int(framebufferDisplay.width * Math.random());
				bunny.y = Std.int(framebufferDisplay.height * Math.random());
				buffer.addElement(bunny);
			}

		});
	}

	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------

	override function onPreloadComplete():Void {
		// access embeded assets from here
	}

	override function update(deltaTime:Int):Void {
		// rotate the "screen" by changing the angle of the sprite
		screenSprite.r += 0.25;
		screenBuffer.updateElement(screenSprite);
	}

	// override function render(context:lime.graphics.RenderContext):Void {}
	// override function onRenderContextLost ():Void trace(" --- WARNING: LOST RENDERCONTEXT --- ");
	// override function onRenderContextRestored (context:lime.graphics.RenderContext):Void trace(" --- onRenderContextRestored --- ");
	// ----------------- MOUSE EVENTS ------------------------------
	// override function onMouseMove (x:Float, y:Float):Void {}
	// override function onMouseDown (x:Float, y:Float, button:lime.ui.MouseButton):Void {}
	// override function onMouseUp (x:Float, y:Float, button:lime.ui.MouseButton):Void {}
	// override function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:lime.ui.MouseWheelMode):Void {}
	// override function onMouseMoveRelative (x:Float, y:Float):Void {}
	// ----------------- TOUCH EVENTS ------------------------------
	// override function onTouchStart (touch:lime.ui.Touch):Void {}
	// override function onTouchMove (touch:lime.ui.Touch):Void	{}
	// override function onTouchEnd (touch:lime.ui.Touch):Void {}
	// ----------------- KEYBOARD EVENTS ---------------------------
	// override function onKeyDown (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}
	// override function onKeyUp (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}
	// -------------- other WINDOWS EVENTS ----------------------------
	// override function onWindowResize (width:Int, height:Int):Void { trace("onWindowResize", width, height); }
	// override function onWindowLeave():Void { trace("onWindowLeave"); }
	// override function onWindowActivate():Void { trace("onWindowActivate"); }
	// override function onWindowClose():Void { trace("onWindowClose"); }
	// override function onWindowDeactivate():Void { trace("onWindowDeactivate"); }
	// override function onWindowDropFile(file:String):Void { trace("onWindowDropFile"); }
	// override function onWindowEnter():Void { trace("onWindowEnter"); }
	// override function onWindowExpose():Void { trace("onWindowExpose"); }
	// override function onWindowFocusIn():Void { trace("onWindowFocusIn"); }
	// override function onWindowFocusOut():Void { trace("onWindowFocusOut"); }
	// override function onWindowFullscreen():Void { trace("onWindowFullscreen"); }
	// override function onWindowMove(x:Float, y:Float):Void { trace("onWindowMove"); }
	// override function onWindowMinimize():Void { trace("onWindowMinimize"); }
	// override function onWindowRestore():Void { trace("onWindowRestore"); }
}