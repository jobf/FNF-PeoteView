package music.internal;

#if !doc_gen
@:buildXml('<include name="../../../src/music/internal/ma/MiniAudioBuild.xml" />')
@:include("miniaudio.h")
@:unreflective
@:structAccess
@:keep
@:native("ma_resource_manager")
extern class MAResMan {}
#end