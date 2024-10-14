package music;

import lime.media.vorbis.VorbisFile;
import cpp.RawPointer;
import lime.app.Application;

/**
	The audio.
**/
#if !debug
@:noDebug
#end
@:publicFields
class Audio
{
	/**
		Whenever audio interpolation should be enabled or not.
	**/
	static var enableInterpolation:Bool = true;

	/**
		The audio's volume.
	**/
	var volume(get, set):Float;

	/**
		Whenever the audio is playing.
	**/
	var playing(get, never):Bool;

	/**
		Whenever the audio has finished.
	**/
	var finished(get, never):Bool;

	/**
		Whenever the audio has stopped.
	**/
	var stopped:Bool = true;

	/**
		Whenever the audio should be looping.
	**/
	var looping(get, set):Bool;

	/**
		The audio's time.
	**/
	var time(get, set):Float;

	/**
		The audio's length.
	**/
	var length(get, never):Float;

	/**
		The internal audio volume.
	**/
	private var _volume:Float = 1;

	/**
		The internal audio time.
		This is used for interpolation with audio time for smoother audio playback time.
	**/
	private var _time:Float = 0;

	/**
		The internal audio length.
	**/
	private var _length:Float = -1;

	/**
		The raw miniaudio sound pointer.
	**/
	@:noPrivateAccess private var sound(default, null):RawPointer<MASound>;

	/**
		The raw miniaudio engine pointer.
	**/
	@:noPrivateAccess private static var engine(default, null):RawPointer<MAEngine>;

	/**
		The raw miniaudio group pointer.
	**/
	@:noPrivateAccess private static var group(default, null):RawPointer<MAGroup>;

	/**
		The raw miniaudio resource manager pointer.
	**/
	@:noPrivateAccess private static var resourceManager(default, null):RawPointer<MAResMan>;

	/**
		The added audio tracks.
	**/
	static var addedSounds(default, null):Array<Audio> = [];

	/**
		Construct an audio track.
		@param filePath The audio's file path.
		@param grouped Whenever your audio should be grouped.
	**/
	function new(filePath:String, grouped:Bool = false)
	{
		if (resourceManager == null)
			resourceManager = MiniAudio.init_resource();

		if (engine == null)
			engine = MiniAudio.init(resourceManager);

		if (grouped && group == null)
			createGroup();

		sound = MiniAudio.loadSound(engine, filePath, (grouped ? group : null));
		if (sound == null)
		{
			trace("CAN'T LOAD SOUND " + filePath);
			return;
		}

		if (StringTools.endsWith(filePath, ".ogg"))
		{
			var vorb = VorbisFile.fromFile(filePath);
			_length = vorb.timeTotal() *1000.0;
			vorb.clear();
			vorb = null;
		}
		else
		{
			_length = MiniAudio.getLength(sound) * 1000.0;
		}
		MiniAudio.setTime(sound, 0);

		addedSounds.push(this);
	}

	/**
		Update the audio.
		This makes the interpolation work.
		@param deltaTime The time since the last frame.
	**/
	var lastTime(default, null):Float = 0;
	function update(deltaTime:Float) {
		if (playing) {
			var audioTime:Float = MiniAudio.getTimeInMS(sound);
			var diff:Float = Math.abs(_time - audioTime);

			if (enableInterpolation) {
				_time += deltaTime;
				_time -= (_time - audioTime) * (deltaTime * 0.002);
				lastTime = _time;

				Sys.println('Real audio time: $audioTime, Interpolated: $_time');
			} else
				_time = audioTime;
		}
	}

	/**
		Dispose the audio.
	**/
	function dispose()
	{
		if (sound != null)
		{
			MiniAudio.stopSound(sound);
			MiniAudio.destroySound(sound);
		}
		sound = null;
		addedSounds.remove(this);
	}

	/**
		Play a sound and add it to the sound track.
		@param path The sound's path.
	**/
	inline static function playSound(path:String):Audio {
		var newSnd:Audio = new Audio(path);
		Audio.addedSounds.remove(newSnd);
		newSnd.play();

		return newSnd;
	}

	/**
		Dispose the audio's engine.
	**/
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

	/**
		Dispose everything that is involved in the miniaudio engine.
	**/
	static function disposeEverything()
	{
		if (addedSounds != null)
		{
			while (addedSounds.length > 0)
			{
				var sound:Audio = Audio.addedSounds.pop();
				sound.stop();
				sound.dispose();
			}
		}
		addedSounds = null;
		disposeEngine();
	}

	/**
		Play the audio.
	**/
	function play()
	{
		if (MiniAudio.startSound(sound) != 0)
			trace("CAN'T PLAY SOUND");
	}

	/**
		Pause the audio.
	**/
	function pause()
	{
		MiniAudio.pauseSound(sound);
	}

	/**
		Stop the audio.
	**/
	function stop()
	{
		MiniAudio.stopSound(sound);
		time = 0;
	}

	/**
		Create the audio group.
	**/
	static function createGroup()
	{
		if (group != null)
			disposeGroup();
		group = MiniAudio.makeGroup(engine);
	}

	/**
		Dispose the audio group.
	**/
	static function disposeGroup()
	{
		if (group != null)
			MiniAudio.killGroup(group);
		else
			trace("NO GROUP TO DISPOSE");
		group = null;
	}

	/**
		Play the audio group.
	**/
	static function playGroup()
	{
		if (group != null)
			MiniAudio.startGroup(group);
		else
			trace("NO GROUP TO PLAY");
	}

	/**
		Pause the audio group.
	**/
	static function pauseGroup()
	{
		if (group != null)
			MiniAudio.haltGroup(group);
		else
			trace("NO GROUP TO PAUSE");
	}

	/**
		The getter for whenever the audio is playing.
		@return Bool
	**/
	function get_playing():Bool
	{
		return MiniAudio.isPlaying(sound);
	}

	/**
		The getter for whenever the audio is finished.
		@return Bool
	**/
	function get_finished():Bool
	{
		return MiniAudio.isDone(sound);
	}

	/**
		The getter for the audio's length.
		@return Float
	**/
	inline function get_length():Float
	{
		return _length;
	}

	/**
		The getter for the audio's volume.
		@return Float
	**/
	inline function get_volume():Float
	{
		return _volume;
	}

	/**
		The setter for the audio's volume.
		@param newVol The audio's new volume.
		@return Float
	**/
	function set_volume(newVol:Float):Float
	{
		_volume = newVol;
		MiniAudio.setVolume(sound, _volume);
		return newVol;
	}

	/**
		The getter for the audio's time.
		@return Float
	**/
	inline function get_time():Float
	{
		return _time;
	}

	/**
		The setter for the audio's time.
		@param newTime The audio's new time.
		@return Float
	**/
	function set_time(newTime:Float):Float
	{
		if (newTime < 0.0 || newTime > length) // Prevent weird bugs with audio playback
		{
			newTime = 0.0;
		}

		_time = newTime;

		MiniAudio.setTime(sound, newTime * 0.001);
		return newTime;
	}

	/**
		The getter for whenever the audio is looping.
		@return Bool
	**/
	function get_looping():Bool
	{
		return MiniAudio.getLooping(sound);
	}

	/**
		Toggle looping for the audio.
		@param shouldLoop Whenever the audio should loop or not.
		@return Bool
	**/
	function set_looping(shouldLoop:Bool):Bool
	{
		MiniAudio.setLooping(sound, shouldLoop);
		return shouldLoop;
	}
}