package;

import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;
import lime.ui.KeyCode;
import sys.io.Process;
import sys.FileSystem;
import haxe.io.Bytes;
import lime.graphics.opengl.GL;

@:publicFields
class Main extends Application
{
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

	var peoteView:PeoteView;

	var bottomDisplay:CustomDisplay;
	var middleDisplay:CustomDisplay;
	var topDisplay:CustomDisplay;

	var playField:PlayField;
	static var conductor:Conductor;

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
			trace('Done! Took ${(haxe.Timer.stamp() - stamp) * 1000}ms');

			bottomDisplay = new CustomDisplay(0, 0, window.width, window.height, 0x00000000);
			bottomDisplay.hide();

			// Coming soon...

			middleDisplay = new CustomDisplay(0, 0, window.width, window.height, 0x333333FF);

			topDisplay = new CustomDisplay(0, 0, window.width, window.height, 0x00000000);
			topDisplay.hide();

			peoteView.start();

			peoteView.addDisplay(bottomDisplay);
			peoteView.addDisplay(middleDisplay);
			peoteView.addDisplay(topDisplay);

			conductor = new Conductor();

			playField = new PlayField(Sys.args()[0]);
			playField.init(middleDisplay, true);

			window.onKeyDown.add(playField.keyPress);
			window.onKeyDown.add(changeTime);
			window.onKeyUp.add(playField.keyRelease);

			GC.run(10);
			GC.enable(false);

			_started = true;

			window.onResize.add(resize);

			if (ffmpegMode) {
				initRender();
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

	override function update(deltaTime:Int) {
		Tools.profileFrame();

		if (_started) {
			var ts:Float = stamp();

			newDeltaTime = (ts - timeStamp) * 1000;

			if (ffmpegMode) {
				newDeltaTime = 1000 / Application.current.window.frameRate;
			}

			if (!playField.disposed && !playField.paused) {
				if (ffmpegMode) {
					pipeFrame();
				}

				playField.update(newDeltaTime);
			}

			timeStamp = stamp();
		}

		Tools.profileFrame();
	}

	function resize(w:Int, h:Int) {
		peoteView.resize(w, h);

		bottomDisplay.width = w;
		bottomDisplay.height = h;

		middleDisplay.width = w;
		middleDisplay.height = h;

		topDisplay.width = w;
		topDisplay.height = h;
	}

	inline function stamp() {
		return Timestamp.get();
	}

	var process:Process;

	var ffmpegExists:Bool;
	static var ffmpegMode:Bool = true;

	private function initRender()
	{
		if (!FileSystem.exists(#if linux 'ffmpeg' #else 'ffmpeg.exe' #end)) {
			Sys.println('Rendering Mode System - "ffmpeg${#if windows '.exe' #end}" not found! Is it located at the current working directory?');
			return;
		}

		if (!FileSystem.exists('assets/gameRenders/')) { // In case you delete the gameRenders folder
			trace('gameRenders folder not found! Re-creating it...');
            FileSystem.createDirectory('assets/gameRenders');
        }

		ffmpegExists = true;

		process = new Process('ffmpeg', [
			'-v', 'quiet',
			'-y',
			'-f', 'rawvideo',
			'-pix_fmt', 'rgba',
			'-s', peoteView.width + 'x' + peoteView.height,
			'-r', '60',
			'-display_hflip', '-display_rotation', '180', // This is here because 
			'-i', '-',
			'-vcodec', 'libx264',
			'-crf', '1',
			'-preset', 'ultrafast',
			'-c:a', 'copy',
			'assets/gameRenders/' + playField.chart.header.title + '.mp4']);
	}

	var bytes:haxe.io.UInt8Array;
	private function pipeFrame()
	{
		if (!ffmpegMode || !ffmpegExists || process == null)
			return;

		if (bytes == null) {
			bytes = new haxe.io.UInt8Array(peoteView.width * peoteView.height * 4);
		}

		peoteView.gl.readPixels(0, 0, peoteView.width, peoteView.height, GL.RGBA, GL.UNSIGNED_BYTE, bytes);
		process.stdin.write(bytes.getData().bytes);
	}

	public function stopRender()
	{
		if (!ffmpegMode)
			return;

		if (process != null) {
			if (process.stdin != null)
				process.stdin.close();

			process.close();
			process.kill();
		}
	}

	// ------------------------------------------------------------
	// -------------------- SAMPLE ENDS HERE ----------------------
	// ------------------------------------------------------------
}