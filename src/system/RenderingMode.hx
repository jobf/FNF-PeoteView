package system;

import sys.io.Process;
import sys.FileSystem;
import haxe.io.Bytes;
import lime.graphics.opengl.GL;

@:publicFields
class RenderingMode {
	static var process:Process;
	static var encoder:Process;
	private static var ffmpegExists(default, null):Bool;
	static var enabled:Bool = false;

	static var peoteView:PeoteView;
	static var playField:PlayField;

	static function initRender(entryPoint:Main)
	{
		if (!FileSystem.exists(#if linux 'ffmpeg' #else 'ffmpeg.exe' #end)) {
			Sys.println('Rendering Mode System - "ffmpeg${#if windows '.exe' #end}" not found! Is it located at the current working directory?');
			return;
		}

		if (!FileSystem.exists('assets/videos/rendered/')) { // In case you delete the videos/rendered folder
			Sys.println('Rendering Mode System - "assets/videos/rendered" folder not found! Recreating it...');
			FileSystem.createDirectory('assets/videos/rendered');
		}

		ffmpegExists = true;

		peoteView = entryPoint.peoteView;
		playField = entryPoint.playField;
		playField.botplay = true;

		process = new Process('ffmpeg', [
			'-v', 'quiet', '-y', // START
			'-f', 'rawvideo', // FILTER
			'-pix_fmt', 'rgba', // PIXEL FORMAT
			'-s', peoteView.width + 'x' + peoteView.height, // DIMENSIONS
			'-r', '60', // FRAMERATE
			'-display_hflip', '-display_rotation', '180', // This is here because the original output is mirrored and upside down
			'-i', '-', // INPUT INIT
			'-vcodec', 'libx264', // ENCODER
			'-crf', '0', // CRF
			'-preset', 'ultrafast', // PRESET
			'-c:a', 'copy', // COPY,
			'-colorspace', 'bt709', // CONVERT TO BT709 COLORSPACE
			'assets/videos/rendered/' + playField.chart.header.title + '_raw.mp4' // END (FILEPATH)
		]);
	}

	static var bytes:haxe.io.UInt8Array;
	static function pipeFrame()
	{
		if (!enabled || !ffmpegExists || process == null)
			return;

		if (bytes == null) {
			bytes = new haxe.io.UInt8Array(peoteView.width * peoteView.height * 4);
		}

		peoteView.gl.readPixels(0, 0, peoteView.width, peoteView.height, GL.RGBA, GL.UNSIGNED_BYTE, bytes);
		process.stdin.write(untyped bytes.bytes);
	}

	static function stopRender()
	{
		if (!enabled)
			return;

		if (process != null) {
			if (process.stdin != null)
				process.stdin.close();

			process.close();
			process.kill();

			Sys.println("Rendering Mode System - Encoding...");

			Sys.command('ffmpeg', [
				'-y', // START
				'-i', // INPUT INIT
				'assets/videos/rendered/' + playField.chart.header.title + '_raw.mp4',
				'-vcodec', 'libx264', // ENCODER
				'-crf', '18', // CRF
				'-preset', 'ultrafast', // PRESET
				'-movflags', '+faststart', // MOVFLAGS
				'-colorspace', 'bt709', // CONVERT TO BT709 COLORSPACE
				'assets/videos/rendered/' + playField.chart.header.title + '.mp4' // END (FILEPATH)
			]);
			Sys.println("Rendering Mode System - Encoding done!");
			FileSystem.deleteFile('assets/videos/rendered/' + playField.chart.header.title + '_raw.mp4');
		}
	}
}