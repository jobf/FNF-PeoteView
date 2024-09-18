package music.internal;

import cpp.ConstCharStar;
import cpp.RawPointer;

#if !doc_gen
@:buildXml('<include name="../../../src/music/internal/ma/MiniAudioBuild.xml" />')
@:include("miniaudio.h")
@:unreflective
@:structAccess
@:keep
@:native("ma_engine")
extern class MAEngine {}

@:buildXml('<include name="../../../src/music/internal/ma/MiniAudioBuild.xml" />')
@:include("miniaudio.h")
@:unreflective
@:structAccess
@:keep
@:native("ma_sound")
extern class MASound {}

@:buildXml('<include name="../../../src/music/internal/ma/MiniAudioBuild.xml" />')
@:include("miniaudio.h")
@:unreflective
@:structAccess
@:keep
@:native("ma_sound_group")
extern class MAGroup {}

@:buildXml('<include name="../../../src/music/internal/ma/MiniAudioBuild.xml" />')
@:include("miniaudio.h")
@:unreflective
@:structAccess
@:keep
@:native("ma_resource_manager")
extern class MAResMan {}
#end

/**
	The miniaudio implementation.
**/
@:buildXml('<include name="../../../src/music/internal/ma/MiniAudioBuild.xml" />')
@:include("audiostuff.cpp")
@:unreflective
@:keep
extern class MiniAudio
{
	/**
		Initialize the miniaudio engine.
		@param resourceManager 
		@return RawPointer<MAEngine>
	**/
	@:native("init") public static function init(resourceManager:RawPointer<MAResMan>):RawPointer<MAEngine>;

	/**
		Uninitializes the miniaudio engine.
		@param engine 
	**/
	@:native("uninit") public static function uninit(engine:RawPointer<MAEngine>):Void;

	/**
		Initializes the miniaudio resource manager.
		@return RawPointer<MAResMan>
	**/
	@:native("init_resource") public static function init_resource():RawPointer<MAResMan>;

	/**
		Uninitializes the miniaudio resource manager.
		@param resourceManager 
	**/
	@:native("uninit_resource") public static function uninit_resource(resourceManager:RawPointer<MAResMan>):Void;

	/**
		Load a sound on a miniaudio engine, in a miniaudio group.
		@return RawPointer<MASound>
	**/
	@:native("loadSound") public static function loadSound(engine:RawPointer<MAEngine>, path:ConstCharStar, group:RawPointer<MAGroup> = null):RawPointer<MASound>;

	/**
		Starts a sound.
		@return Int
	**/
	@:native("startSound") public static function startSound(sound:RawPointer<MASound>):Int;

	/**
		Stops a sound.
		@return Int
	**/
	@:native("stopSound") public static function stopSound(sound:RawPointer<MASound>):Int;

	/**
		Pauses a sound.
		@return Int
	**/
	@:native("pauseSound") public static function pauseSound(sound:RawPointer<MASound>):Int;

	/**
		Destroys a sound.
	**/
	@:native("destroySound") public static function destroySound(sound:RawPointer<MASound>):Void;

	/**
		Set a sound's volume.
	**/
	@:native("setVolume") public static function setVolume(sound:RawPointer<MASound>, vol:Float):Void;

	/**
		Get a sound's volume.
		@return Float
	**/
	@:native("getVolume") public static function getVolume(sound:RawPointer<MASound>):Float;

	/**
		Whenever a sound is playing.
		@return Bool
	**/
	@:native("isPlaying") public static function isPlaying(sound:RawPointer<MASound>):Bool;

	/**
		Whenever a sound is done.
		@param sound 
		@return Bool
	**/
	@:native("isDone") public static function isDone(sound:RawPointer<MASound>):Bool;

	/**
		Gets a sound's time in seconds.
		@param sound 
		@return Float
	**/
	@:native("getTimeInSeconds") public static function getTimeInSeconds(sound:RawPointer<MASound>):Float;

	/**
		Gets a sound's time in milliseconds.
		@param sound 
		@return Float
	**/
	@:native("getTimeInMS") public static function getTimeInMS(sound:RawPointer<MASound>):Float;

	/**
		Get the length of a sound.
		@param sound 
		@return Float
	**/
	@:native("getLength") public static function getLength(sound:RawPointer<MASound>):Float;

	/**
		Set a sound's time in seconds.
		@param sound 
		@param timeInSec 
	**/
	@:native("setTime") public static function setTime(sound:RawPointer<MASound>, timeInSec:Float):Void;

	/**
		Toggle loop on a sound.
		@param sound 
		@param shouldLoop 
	**/
	@:native("setLooping") public static function setLooping(sound:RawPointer<MASound>, shouldLoop:Bool):Void;

	/**
		Whenever a sound is looping.
		@param sound 
		@return Bool
	**/
	@:native("getLooping") public static function getLooping(sound:RawPointer<MASound>):Bool;

	/**
		Make a miniaudio group.
		@param engine 
		@return RawPointer<MAGroup>
	**/
	@:native("makeGroup") public static function makeGroup(engine:RawPointer<MAEngine>):RawPointer<MAGroup>;

	/**
		Starts a miniaudio group.
		@param group 
		@return Int
	**/
	@:native("startGroup") public static function startGroup(group:RawPointer<MAGroup>):Int;

	/**
		Halts a miniaudio group.
		@param group 
		@return Int
	**/
	@:native("haltGroup") public static function haltGroup(group:RawPointer<MAGroup>):Int;

	/**
		Kills a miniaudio group.
		@param group 
	**/
	@:native("killGroup") public static function killGroup(group:RawPointer<MAGroup>):Void;
}