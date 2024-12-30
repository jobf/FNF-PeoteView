package elements.actor;

@:structInit
@:publicFields
class ActorData {
	var flip:Bool;
	var colors:Array<Color>;
	var scale:Float;

	var healthIconIndexes:Array<Int>;

	var adjPos:Array<Float>;
	var camPos:Array<Float>;

	var data:Map<String, ActorAnimationData>;

	/**
	 * Converts a psych engine character data json to an `ActorData`.
	 * @param path 
	 */
	static function parse(path:String) {
		var content = sys.io.File.getContent(path);
		var json = haxe.Json.parse(content);

		var _data:Map<String, ActorAnimationData> = [];

		var animations:Array<Dynamic> = json.animations;

		for (i in 0...animations.length) {
			var animData = animations[i];
			_data.set(animData.anim, {
				name: animData.name,
				anim: animData.anim,
				offsets: animData.offsets,
				indices: animData.indices,
				fps: animData.fps,
				loop: animData.loop
			});
		}

		var healthIconIDs = json.healthicon_ids;
		if (healthIconIDs == null) healthIconIDs = [0, 1];

		var c:Array<Int> = json.healthbar_colors;
		var colors:Color = Color.RGB(c[0], c[1], c[2]);
		var result:ActorData = {
			flip: json.flip_x,
			colors: [for (i in 0...6) colors],
			scale: json.scale,
			healthIconIndexes: healthIconIDs,
			adjPos: json.position,
			camPos: json.camera_position,
			data: _data
		}

		return result;
	}
}