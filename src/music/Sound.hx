package music;

import Miniaudio.MaEngine;
import Miniaudio.MaSound;
import Miniaudio.MaDataSource;
import Miniaudio.MaResult;

import music.Conductor;

/**
    Sound class using miniaudio.
**/
@:publicFields
class Sound {
    private var sound:MaSound;
    static private var engine:MaEngine;
    var conductor:Conductor;

    // START OF PLAYBACK TRACKING SYSTEM //

    var playbackTrackingMethod:PlaybackTrackingMethod = HYBRID;

    private var programPos:cpp.Float64;
    private var driverPos:cpp.Float32;
    private var _length:cpp.Float32;
    private var _time:cpp.Float64;
    private var _sampleRate:cpp.UInt32;
    private var _dataSource:cpp.Star<MaDataSource>;

    private var _playhead(default, null):Playhead = [];

    var time(get, set):Float;

    inline function get_time() {
        return _time;
    }

    inline function set_time(value:Float) {
        return setTime(value * 0.001);
    }

    /// END OF PLAYBACK TRACKING SYSTEM ///

    var sampleRate(get, never):Int;

    inline function get_sampleRate() {
        return _sampleRate;
    }

    var length(get, never):Float;

    inline function get_length() {
        return _length;
    }

    var volume(get, set):Float;

    inline function get_volume() {
        return Miniaudio.ma_sound_get_volume(sound);
    }

    inline function set_volume(value:Float) {
        Miniaudio.ma_sound_set_volume(sound, value);
        return value;
    }

    var playing(get, never):Bool;

    inline function get_playing() {
        return Miniaudio.ma_sound_is_playing(sound) != 0;
    }

    var finished(get, never):Bool;

    inline function get_finished() {
        return Miniaudio.ma_sound_at_end(sound) != 0;
    }

    static function init() {
        var result = Miniaudio.ma_engine_init(null, engine);

        if (result != MaResult.MA_SUCCESS) {
            trace("Failed to initialize engine");
            return;
        }
    }

    inline function new() {
        sound = MaSound.create();

        /////////////////////////////// BUGFIX ///////////////////////////////
        // Explanation:
        // GC frees that shit like it thinks it's a zombie so do this.
        // This is because certain externs can be buggy and somewhat unstable.
                               cpp.vm.Gc.doNotKill(this);
        //////////////////////////////////////////////////////////////////////
    }

    function fromFile(path:String) {
        var result = Miniaudio.ma_sound_init_from_file(engine, path,
            //MA_SOUND_FLAG_STREAM | MA_SOUND_FLAG_WAIT_INIT | MA_SOUND_FLAG_ASYNC | MA_SOUND_FLAG_NO_SPATIALIZATION
            0x00000001 | 0x00000002 | 0x00000004 | 0x00002000 | 0x00004000,
        null, null, sound);

        Miniaudio.ma_sound_get_length_in_seconds(sound, cpp.Pointer.addressOf(_length).ptr);

        _dataSource = Miniaudio.ma_sound_get_data_source(sound);
        Miniaudio.ma_data_source_get_data_format(_dataSource, null, null, cpp.Pointer.addressOf(_sampleRate).ptr, null, 0);

        if (result != MaResult.MA_SUCCESS) {
            Sys.println("[Sound system] Failed to initialize sound");
            return;
        }
    }

    function play() {
        programPos = -Timestamp.get() + _playhead.program;

        var result = Miniaudio.ma_sound_start(sound);

        if (result != MaResult.MA_SUCCESS) {
            Sys.println("[Sound system] Failed to play sound");
            return;
        }
    }

    function stop() {
        var result = Miniaudio.ma_sound_stop(sound);

        if (result != MaResult.MA_SUCCESS) {
            Sys.println("[Sound system] Failed to stop sound");
            return;
        }
    }

    private function setTime(timeInSec:cpp.Float64) {
        Miniaudio.ma_sound_seek_to_pcm_frame(sound, untyped (sampleRate * timeInSec));

        programPos = -Timestamp.get() + timeInSec;

        return timeInSec;
    }

    inline function update() {
        var result:Float = 0;

        if (playing) {
            var stamp = Timestamp.get();
            _playhead.program = programPos + stamp;

            Miniaudio.ma_sound_get_cursor_in_seconds(sound, cpp.Pointer.addressOf(driverPos).ptr);
            _playhead.driver = Math.floor(driverPos * 1000) * 0.001;

            switch (playbackTrackingMethod) {
                case DRIVER:
                    result = _playhead.driver;
                case PROGRAM:
                    result = _playhead.program;
                default:
                    _playhead.program -= (_playhead.program - _playhead.driver) * 0.02;
                    result = _playhead.program;
            }

            if (result < 0) {
                result = 0;
            }

            if (result > length) {
                result = length;
            }
        } else {
            result = length;
        }

        _time = result * 1000.0;

        if (conductor != null) {
            conductor.time = _time;
        }
    }

    function dispose() {
        stop();
        Miniaudio.ma_sound_uninit(sound);
    }

    static function uninit() {
        Miniaudio.ma_engine_uninit(engine);
    }
}

/**
    Playback tracking method.
**/
private enum abstract PlaybackTrackingMethod(cpp.UInt8) {
    /**
        Playback position is retrieved from the current audio driver.
    **/
    var DRIVER = 0x40;

    /**
        Playback position is retrieved from the program.
        We don't recommend using this one.
    **/
    var PROGRAM = 0x01;

    /**
        Playback position is estimated.
    **/
    var HYBRID = 0x80;
}

/**
    Playback tracker.
**/
@:publicFields
private abstract Playhead(Array<Float>) from Array<Float> {
    var driver(get, set):Float;

    inline function get_driver():Float {
        return this[0];
    }

    inline function set_driver(value:Float):Float {
        return this[0] = value;
    }

    var program(get, set):Float;

    inline function get_program():Float {
        return this[1];
    }

    inline function set_program(value:Float):Float {
        return this[1] = value;
    }
}