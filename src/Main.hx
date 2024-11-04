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

		var stamp = haxe.Timer.stamp();
		trace("Preloading textures...");
		TextureSystem.createTexture("noteTex", "assets/notes/noteSheet.png");
		TextureSystem.createTexture("sustainTex", "assets/notes/sustain.png");
		TextureSystem.createTexture("uiTex", "assets/ui/uiSheet.png");
		trace('Done! Took ${(haxe.Timer.stamp() - stamp) * 1000}ms');

		bottomDisplay = new Display(0, 0, window.width, window.height, 0x00000000);
		bottomDisplay.hide();

		// Coming soon...

		middleDisplay = new Display(0, 0, window.width, window.height, 0xFFFFFFFF);

		topDisplay = new Display(0, 0, window.width, window.height, 0x00000000);
		topDisplay.hide();

		playField = new PlayField(Sys.args()[0]);
		playField.init(middleDisplay, true);

		window.onKeyDown.add(playField.keyPress);
		window.onKeyDown.add(changeTime);
		window.onKeyUp.add(playField.keyRelease);

		peoteView.start();

		peoteView.addDisplay(bottomDisplay);
		peoteView.addDisplay(middleDisplay);
		peoteView.addDisplay(topDisplay);

		GC.run(10);
		GC.enable(false);
	}

	function changeTime(code:KeyCode, mod) {
		switch (code) {
			case KeyCode.EQUALS:
				playField.setTime(playField.songPosition + 2000);
			case KeyCode.MINUS:
				playField.setTime(playField.songPosition - 2000);
			case KeyCode.F8:
				playField.flipHealthBar = !playField.flipHealthBar;
			default:
		}
	}

	var newDeltaTime:Float = 0;
	var timeStamp:Float = 0;
	var justStarted:Bool;
	override function update(deltaTime:Int):Void {
		var ts:Float = stamp();
		//syncFramerate(ts);

		newDeltaTime = (ts - timeStamp) * 1000;

		if (playField != null) {
			playField.songPosition += newDeltaTime;
			playField.update(newDeltaTime);
		}

		timeStamp = stamp();

		//Sys.println(newDeltaTime);
	}

	// This'll be deprecated once the main loop rework drops
	var cpuTime:Float;
	function syncFramerate(ts:Float) {
		var destination:Float = ts + ((1 / Application.current.window.frameRate) - cpuTime);

		if (justStarted) {
			// Do this so the frametime syncs
			var _:Float = stamp();
			while (true) {
				var current = stamp();
				var timeLeft = destination - current;
				if (timeLeft >= 0.001)
					Sys.sleep(0.001);
				else {
					Sys.sleep(0.000000000);
					if (current >= destination) break;
				}
			}
		} else justStarted = true;

		cpuTime = Sys.cpuTime();
	}

	inline function stamp() {
		// Choose any I guess?
		return untyped __global__.__time_stamp();
		//return Sys.time() * 0.000001;
	}
}