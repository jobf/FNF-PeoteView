package music;

import Miniaudio.MaResult;
import Miniaudio.MaSoundGroup;

/**
	Sound group class using miniaudio.
**/
@:publicFields
class SoundGroup {
	var grp:cpp.Star<MaSoundGroup>;

	function new() {
		grp = MaSoundGroup.create();

		cpp.vm.Gc.doNotKill(this);

		var result = Miniaudio.ma_sound_group_init(Sound.engine, 0, null, grp);

		if (result != MaResult.MA_SUCCESS) {
			Sys.println("[Sound system] Failed to initialize sound group");
			return;
		}
	}

	function play() {
		Miniaudio.ma_sound_group_start(grp);
	}

	function stop() {
		Miniaudio.ma_sound_group_stop(grp);
	}

	function dispose() {
		Miniaudio.ma_sound_group_uninit(grp);
	}
}