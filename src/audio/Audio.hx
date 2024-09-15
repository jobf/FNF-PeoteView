package audio;

import audio.ma.MiniAudio.MAResMan;
import audio.ma.MiniAudio.MAGroup;
import audio.ma.MiniAudio.MAEngine;
import audio.ma.MiniAudio.MASound;
import lime.media.vorbis.VorbisFile;
import cpp.RawPointer;

/**
 * The audio.
 */
@:publicFields
class Audio
{
	private var sound:RawPointer<MASound>;

	var volume(get, set):Float;
	var time(get, set):Float;
	var speed(get, set):Float;
	var looping(get, set):Bool;
	var playing(get, never):Bool;
	var finished(get, never):Bool;
	var length(get, never):Float;

	private var _length:Float = -1;
	private var _volume:Float = 1;

	private static var engine:RawPointer<MAEngine>;
	private static var group:RawPointer<MAGroup>;
	private static var resourceManager:RawPointer<MAResMan>;

	private static var addedSounds:Array<Audio> = [];

	function new(filePath:String, grouped:Bool = false)
	{
		if (resourceManager == null)
			resourceManager = MiniAudio.init_resource();

		if (engine == null)
			engine = MiniAudio.init(resourceManager);

		if (grouped && group == null)
			createGroup();

		sound = MiniAudio.loadSound(engine, filePath, grouped ? group : null);
		if (sound == null)
		{
			trace("CAN'T LOAD SOUND " + filePath);
			return;
		}

		if (StringTools.endsWith(filePath, ".ogg"))
		{
			var vorb = VorbisFile.fromFile(filePath);
			_length = vorb.timeTotal() * 1000;
			vorb.clear();
			vorb = null;
			trace("THIS IS OGG");
		}
		else
		{
			_length = MiniAudio.getLength(sound) * 1000;
			trace("THIS IS OTHER");
		}
		MiniAudio.setTime(sound, 0);

		addedSounds.push(this);
	}

	function dispose()
	{
		if (sound != null)
		{
			MiniAudio.stopSound(sound);
			MiniAudio.disposeSound(sound);
		}
		sound = null;
		addedSounds.remove(this);
	}

	static function disposeEngine()
	{
		if (resourceManager != null)
			MiniAudio.uninit_resource(resourceManager);
		resourceManager = null;
		if (engine != null)
			MiniAudio.uninit(engine);
		engine = null;
		if (group != null)
			disposeGroup();
		group = null;
	}

	static function disposeEverything()
	{
		if (addedSounds != null)
		{
			while (addedSounds.length > 0)
			{
				addedSounds[0].stop();
				addedSounds[0].dispose();
			}
		}
		addedSounds = null;
		disposeEngine();
	}

	function play()
	{
		if (MiniAudio.startSound(sound) != 0)
			trace("CAN'T PLAY SOUND");
	}

	function pause()
	{
		MiniAudio.pauseSound(sound);
	}

	function stop()
	{
		MiniAudio.stopSound(sound);
	}

	static function createGroup()
	{
		if (group != null)
			disposeGroup();
		group = MiniAudio.makeGroup(engine);
	}

	static function disposeGroup()
	{
		if (group != null)
			MiniAudio.killGroup(group);
		else
			trace("NO GROUP TO dispose");
		group = null;
	}

	static function playGroup()
	{
		if (group != null)
			MiniAudio.startGroup(group);
		else
			trace("NO GROUP TO PLAY");
	}

	static function pauseGroup()
	{
		if (group != null)
			MiniAudio.haltGroup(group);
		else
			trace("NO GROUP TO PAUSE");
	}

	inline function get_playing():Bool
	{
		return MiniAudio.isPlaying(sound);
	}

	inline function get_finished():Bool
	{
		return MiniAudio.finished(sound);
	}

	inline function get_length():Float
	{
		return _length;
	}

	inline function get_volume():Float
	{
		return _volume;
	}

	inline function set_volume(newVol:Float):Float
	{
		_volume = newVol;
		MiniAudio.setVolume(sound, _volume);
		return newVol;
	}

	inline function get_time():Float
	{
		return MiniAudio.getTime(sound) * 1000;
	}

	inline function set_time(newTime:Float):Float
	{
		MiniAudio.setTime(sound, newTime * 0.001);
		return newTime;
	}

	inline function get_speed():Float
	{
		return MiniAudio.getPitch(sound);
	}

	inline function set_speed(newSpeed:Float):Float
	{
		MiniAudio.setPitch(sound, newSpeed);
		return newSpeed;
	}

	inline function get_looping():Bool
	{
		return MiniAudio.getLooping(sound);
	}

	inline function set_looping(shouldLoop:Bool):Bool
	{
		MiniAudio.setLooping(sound, shouldLoop);
		return shouldLoop;
	}
}
