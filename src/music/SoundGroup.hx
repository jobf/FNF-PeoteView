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
		cpp.vm.Gc.doNotKill(this);

		grp = MaSoundGroup.create();

		var result = Miniaudio.ma_sound_group_init(Sound.engine, #if FV_STREAM 1 | #end 4 | 0x00002000 | 0x00004000, null, grp);

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