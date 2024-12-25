package;

import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;
import lime.ui.KeyCode;

@:publicFields
class Main extends Application
{
	/**
	 * FNF's standard resolution is 720p.
	 * Resizing the window won't make the game look crispier
	 * unless you create a higher resolution version of your images.
	**/
	static inline var INITIAL_WIDTH = 1280;
	static inline var INITIAL_HEIGHT = 720;

	override function onWindowCreate()
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
	// ------------------- SAMPLE STARTS HERE ---------------------
	// ------------------------------------------------------------

	static var conductor:Conductor;

	var peoteView:PeoteView;

	var bottomDisplay:CustomDisplay;
	var middleDisplay:CustomDisplay;
	var topDisplay:CustomDisplay;

	var playField:PlayField;

	var _started:Bool;

	public function startSample(window:Window)
	{
		Sound.init();

		peoteView = new PeoteView(window);

		haxe.Timer.delay(function() {
			var stamp = haxe.Timer.stamp();
			trace("Preloading textures...");
			TextureSystem.createTexture("noteTex", "assets/notes/noteSheet.png");
			TextureSystem.createTexture("sustainTex", "assets/notes/sustain.png");
			TextureSystem.createTexture("uiTex", "assets/ui/uiSheet.png");
			TextureSystem.createTexture("vcrTex", "assets/fonts/vcrAtlas.png");
			TextureSystem.createTexture("pauseOptionShiz", "assets/ui/pauseOptionShiz.png");
			trace('Done! Took ${(haxe.Timer.stamp() - stamp) * 1000}ms');

			bottomDisplay = new CustomDisplay(0, 0, window.width, window.height, 0x00000000);
			bottomDisplay.hide();

			// Coming soon...

			middleDisplay = new CustomDisplay(0, 0, window.width, window.height, 0x111111FF);

			topDisplay = new CustomDisplay(0, 0, window.width, window.height, 0x00000000);

			peoteView.start();

			peoteView.addDisplay(bottomDisplay);
			peoteView.addDisplay(middleDisplay);
			peoteView.addDisplay(topDisplay);

			resize(peoteView.width, peoteView.height);

			conductor = new Conductor();

			playField = new PlayField(Sys.args()[0]);
			playField.init(middleDisplay);

			playField.downScroll = true;

			window.onKeyDown.add(changeTime);

			GC.run(10);
			GC.enable(false);

			_started = true;

			window.onResize.add(resize);
			window.onFullscreen.add(fullscreen);

			if (RenderingMode.enabled) {
				RenderingMode.initRender(this);
			}
		}, 100);
	}

	function changeTime(code:KeyCode, mod) {
		if (!_started) return;

		switch (code) {
			case KeyCode.EQUALS:
				playField.setTime(playField.songPosition + 2000);
			case KeyCode.MINUS:
				playField.setTime(playField.songPosition - 2000);
			case KeyCode.F8:
				playField.flipHealthBar = !playField.flipHealthBar;
			case KeyCode.LEFT_BRACKET:
				if (playField.songStarted)
					playField.latencyCompensation -= 10;
			case KeyCode.RIGHT_BRACKET:
				if (playField.songStarted)
					playField.latencyCompensation += 10;
			case KeyCode.B:
				if (playField.songStarted)
					playField.botplay = !playField.botplay;
			default:
		}
	}

	var newDeltaTime:Float = 0;
	var timeStamp:Float = 0;

	override function update(deltaTime:Int) {
		Tools.profileFrame();

		if (_started) {
			var ts:Float = stamp();

			newDeltaTime = (ts - timeStamp) * 1000;

			if (RenderingMode.enabled) {
				newDeltaTime = 1000 / 60;
			}

			if (!playField.disposed && !playField.paused) {
				playField.update(newDeltaTime);

				if (RenderingMode.enabled && !playField.songEnded) {
					RenderingMode.pipeFrame();
				}
			}

			timeStamp = stamp();
		}

		Tools.profileFrame();
	}

	function resize(w:Int, h:Int) {
		var scale = h / INITIAL_HEIGHT;

		peoteView.resize(w, h);

		bottomDisplay.width = w;
		bottomDisplay.height = h;
		bottomDisplay.scale = scale;

		middleDisplay.width = w;
		middleDisplay.height = h;
		middleDisplay.scale = scale;

		topDisplay.width = w;
		topDisplay.height = h;
		middleDisplay.scale = scale;
	}

	inline function fullscreen() {
		var display = Application.current.window.displayMode;
		resize(display.width, display.height);
	}

	inline function stamp() {
		return Timestamp.get();
	}

	// ------------------------------------------------------------
	// -------------------- SAMPLE ENDS HERE ----------------------
	// ------------------------------------------------------------
}
