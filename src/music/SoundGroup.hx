package music;

import sys.thread.FixedThreadPool;
import sys.thread.Mutex;
import Miniaudio.MaSoundGroup;
import Miniaudio.MaResult;

/**
	Sound group class made with multiple sound instances. (Originally named AudioSystem in the test project where this class first appeared)
**/
@:publicFields
class SoundGroup {
	// CURRENT CODE

	var sounds:Array<Sound>;
	var grp:MaSoundGroup;

	var time(get, set):Float;

	inline function get_time():Float {
		var result:Float = 0;
		if (sounds != null && sounds[0] != null) result = sounds[0].time;
		return result;
	}

	inline function set_time(value:Float):Float {
		return setTime(value);
	}

	function new() {
		sounds = [];
		grp = MaSoundGroup.create();

		var res = Miniaudio.ma_sound_group_init(Sound.engine, 0, null, grp);

		if (res != MaResult.MA_SUCCESS) {
			Sys.println(res);
			return;
		}
	}

	function play() {
		var res = Miniaudio.ma_sound_group_start(grp);

		if (res != MaResult.MA_SUCCESS) {
			Sys.println(res);
			return;
		}

		for (sound in sounds)
			sound.play();
	}

	function setTime(time:Float) {
		for (sound in sounds) {
			sound.time = time;
		}

		return time;
	}

	function stop() {
		var res = Miniaudio.ma_sound_group_stop(grp);

		if (res != MaResult.MA_SUCCESS) {
			Sys.println(res);
			return;
		}

		for (sound in sounds)
			sound.stop();
	}

	function dispose() {
		Miniaudio.ma_sound_group_uninit(grp);
	}

	// ORIGINAL CODE

	/*var sounds:Array<Sound>;
	var threadPool:FixedThreadPool;
	var mutex:Mutex;

	var time(get, set):Float;

	inline function get_time() {
		return sounds[0].time;
	}

	inline function set_time(value:Float) {
		return setTime(value);
	}

	function new() {
		sounds = [];
		threadPool = new FixedThreadPool(20);
		mutex = new Mutex();
	}

	function fromFiles(paths:Array<String>) {
		for (path in paths) {
			var snd = new Sound();
			snd.fromFile(path);
			sounds.push(snd);
		}
	}

	function play() {
		var jobsDone:Int = 0;

		if (sounds[0].time > sounds[sounds.length-1].time) {
			sounds.reverse();
		}

		for (sound in sounds) {
			threadPool.run(sound.play);

			jobsDone++;

			if (jobsDone == sounds.length) {
				mutex.release();
			}
		}

		mutex.acquire();
	}

	function update() {
		var jobsDone:Int = 0;

		if (sounds[0].time > sounds[sounds.length-1].time) {
			sounds.reverse();
		}

		for (sound in sounds) {
			threadPool.run(sound.update);

			jobsDone++;

			if (jobsDone == sounds.length) {
				mutex.release();
			}
		}

		mutex.acquire();
	}

	function setTime(time:Float) {
		var jobsDone:Int = 0;

		if (sounds[0].time > sounds[sounds.length-1].time) {
			sounds.reverse();
		}

		for (sound in sounds) {
			threadPool.run(() -> sound.time = time);

			jobsDone++;

			if (jobsDone == sounds.length) {
				mutex.release();
			}
		}

		mutex.acquire();

		return time;
	}

	function stop() {
		var jobsDone:Int = 0;

		if (sounds[0].time > sounds[sounds.length-1].time) {
			sounds.reverse();
		}

		for (sound in sounds) {
			threadPool.run(sound.stop);

			jobsDone++;

			if (jobsDone == sounds.length) {
				mutex.release();
			}
		}

		mutex.acquire();
	}

	function dispose() {
		var jobsDone:Int = 0;

		while (sounds.length != 0) {
			threadPool.run(sounds.pop().dispose);

			jobsDone++;

			if (jobsDone == sounds.length) {
				mutex.release();
			}
		}

		mutex.acquire();
	}*/
}