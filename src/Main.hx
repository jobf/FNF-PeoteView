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
		Sound.init();

		peoteView = new PeoteView(window);

		haxe.Timer.delay(200, function() {
			var stamp = haxe.Timer.stamp();
			trace("Preloading textures...");
			TextureSystem.createTexture("noteTex", "assets/notes/noteSheet.png");
			TextureSystem.createTexture("sustainTex", "assets/notes/sustain.png");
			TextureSystem.createTexture("uiTex", "assets/ui/uiSheet.png");
			TextureSystem.createTexture("vcrTex", "assets/fonts/vcrAtlas.png");
			trace('Done! Took ${(haxe.Timer.stamp() - stamp) * 1000}ms');
	
			bottomDisplay = new Display(0, 0, window.width, window.height, 0x00000000);
			bottomDisplay.hide();
	
			// Coming soon...
	
			middleDisplay = new Display(0, 0, window.width, window.height, 0x333333FF);
	
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
		});
	}

	function changeTime(code:KeyCode, mod) {
		switch (code) {
			case KeyCode.EQUALS:
				playField.setTime(playField.songPosition + 2000);
			case KeyCode.MINUS:
				playField.setTime(playField.songPosition - 2000);
			case KeyCode.F8:
				playField.flipHealthBar = !playField.flipHealthBar;
			case KeyCode.LEFT_BRACKET:
				playField.latencyCompensation -= 10;
			case KeyCode.RIGHT_BRACKET:
				playField.latencyCompensation += 10;
			case KeyCode.RETURN:
				if (playField.paused) {
					playField.resume();
				} else {
					playField.pause();
				}
			default:
		}
	}

	var newDeltaTime:Float = 0;
	var timeStamp:Float = 0;

	override function update(deltaTime:Int):Void {
		Tools.profileFrame();

		var ts:Float = stamp();

		newDeltaTime = (ts - timeStamp) * 1000;

		if (!playField.disposed && !playField.paused) {
			if ((!playField.songStarted || playField.songEnded)) {
				playField.songPosition += newDeltaTime;
			} else {
				var firstInst = playField.instrumentals[0];
				firstInst.update();
				playField.songPosition = firstInst.time;
			}
			playField.update(newDeltaTime);
		}

		timeStamp = stamp();

		Tools.profileFrame();
	}

	inline function stamp() {
		return Timestamp.get();
	}
}