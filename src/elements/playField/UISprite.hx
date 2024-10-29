// Note to self: I did a stress test on that sprites by rendering 4000 and it turns out the bigger the texture dimensions are the slower it runs

package elements.playField;

@:publicFields
class UISprite implements Element {
	// position in pixel (relative to upper left corner of Display)
	@posX var x:Int = 0;
	@posY var y:Int = 0;

	// size in pixel
	@sizeX var w:Int = 200;
	@sizeY var h:Int = 200;

	// extra tex attributes for clipping
	@texX var clipX:Int = 0;
	@texY var clipY:Int = 0;
	@texW var clipWidth:Int = 200;
	@texH var clipHeight:Int = 200;

	// extra tex attributes to adjust texture within the clip
	@texPosX  var clipPosX:Int = 0;
	@texPosY  var clipPosY:Int = 0;
	@texSizeX var clipSizeX:Int = 200;
	@texSizeY var clipSizeY:Int = 200;

    var isRatingPopup:Bool;

	var OPTIONS = { texRepeatX: false, texRepeatY: false, blend: true };

	function new() {}

    inline function changePopupIDTo(id:Int) {
        if (isRatingPopup) {
            if ((w != 300 && clipWidth != 300 && clipSizeX != 300) && (h != 150 && clipHeight != 150 && clipHeight != 150)) {
                w = clipWidth = clipSizeX = 300;
                h = clipHeight = clipSizeY = 150;
            }
    
            clipX = (id & 3) * clipWidth;
            clipY = (id >> 2) * clipHeight;
        }
    }
}