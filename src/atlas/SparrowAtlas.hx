package atlas;

@:publicFields
@:structInit
class SparrowAtlas {
	var imagePath:String;
	var subTextures:Array<SubTexture>;

	static function parse(text:String):SparrowAtlas {
		var xml = Xml.parse(text);
		var root = xml.firstElement();
		return {
			imagePath: root.get("imagePath"),
			subTextures: [for (element in root.elementsNamed("SubTexture")) {
				name: element.get("name"),
				x: Std.parseInt(element.get("x")),
				y: Std.parseInt(element.get("y")),
				width: Std.parseInt(element.get("width")),
				height: Std.parseInt(element.get("height")),
				frameX: Std.parseInt(element.get("frameX")),
				frameY: Std.parseInt(element.get("frameY")),
				frameWidth: Std.parseInt(element.get("frameWidth")),
				frameHeight: Std.parseInt(element.get("frameHeight")),
				flipX: element.exists("flipX") ? element.get("flipX") == "true" : null,
				flipY: element.exists("flipY") ? element.get("flipY") == "true" : null,
				rotated: element.exists("rotated") ? element.get("rotated") == "true" : null
			}]
		}
	}	
}

@:publicFields
@:structInit
class SubTexture {
	var name:String;
	var x:Int;
	var y:Int;
	var width:Int;
	var height:Int;
	var frameX:Null<Int>;
	var frameY:Null<Int>;
	var frameWidth:Null<Int>;
	var frameHeight:Null<Int>;
	var flipX:Null<Bool>;
	var flipY:Null<Bool>;
	var rotated:Null<Bool>;
}