package music;

import Miniaudio.MaSoundGroup;
import Miniaudio.MaResult;

/**
	Sound group class made with multiple sound instances. (Originally named AudioSystem in the test project where this class first appeared)
**/
@:publicFields
class SoundGroup
{
	var sounds : Array<Sound>;
	var grp : MaSoundGroup;

	var time(get, set) : Float;

	inline function get_time() : Float
	{
		var result : Float = 0;
		if (sounds != null && sounds[0] != null) result = sounds[0].time;
		return result;
	}

	inline function set_time(value:Float) : Float
	{
		return setTime(value);
	}

	function new()
	{
		sounds = [];
		grp = MaSoundGroup.create();

		var res = Miniaudio.ma_sound_group_init(Sound.engine, 0, null, grp);

		if (res != MaResult.MA_SUCCESS)
		{
			Sys.println(res);
			return;
		}
	}

	function play()
	{
		for (sound in sounds)
			sound.play();

		var res = Miniaudio.ma_sound_group_start(grp);

		if (res != MaResult.MA_SUCCESS)
		{
			Sys.println(res);
			return;
		}
	}

	function setTime(time:Float)
	{
		var res = Miniaudio.ma_sound_group_stop(grp);

		if (res != MaResult.MA_SUCCESS)
		{
			Sys.println(res);
			return time;
		}

		for (sound in sounds)
		{
			sound.time = time;
		}

		var res = Miniaudio.ma_sound_group_start(grp);

		if (res != MaResult.MA_SUCCESS)
		{
			Sys.println(res);
			return time;
		}

		return time;
	}

	function stop()
	{
		for (sound in sounds)
			sound.stop();
	}

	function dispose()
	{
		Miniaudio.ma_sound_group_uninit(grp);
	}
}