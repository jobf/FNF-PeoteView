package elements.text;

/**
    The text buffer class.
**/
@:publicFields
class Text {
    var texture:Texture;
    var buffer:Buffer<Sprite>;
    var text:String;
    var x:Int;
    var y:Int;

    function new(x:Int, y:Int, text:String = "") {
        this.x = x;
        this.y = y;
        this.text = text;

        buffer = new Buffer<Sprite>(2048, 2048, false);

        var spr = new Sprite();
        spr.w = spr.clipWidth = spr.clipSizeX = 18;
        spr.h = spr.clipHeight = spr.clipSizeY = 24;
        buffer.addElement(spr);
    }
}