package elements.text;

/**
    The text buffer class.
**/
@:publicFields
class Text {
    var buffer:Buffer<Sprite>;
    var text(default, set):String;

    function set_text(str:String) {
        if (str == text) {
            return text;
        }

        buffer.clear();

        var advanceX:Int = 0;
        for (i in 0...str.length) {
            var code = str.charCodeAt(i) - 32;

            if (code > 95) {
                code = 0;
            }

            var data = parsedTextAtlasData[code];
            var padding = data.padding;

            var spr = new Sprite();
            spr.clipX = data.position.x + padding;
            spr.clipY = data.position.y + padding;
            spr.w = spr.clipWidth = spr.clipSizeX = data.sourceSize.width;
            spr.h = spr.clipHeight = spr.clipSizeY = data.sourceSize.height;
            spr.x = x + data.char.offset.x + advanceX;
            spr.y = y + data.char.offset.y;
            advanceX += data.char.advanceX;

            buffer.addElement(spr);
        }

        width = advanceX;

        return text = str;
    }

    var x(default, set):Int;

    function set_x(value:Int) {
        if (value == x) {
            return x;
        }

        for (i in 0...text.length) {
            var elem = buffer.getElement(i);
            elem.x += value - x;
            buffer.updateElement(elem);
        }

        return x = value;
    }

    var y(default, set):Int;

    function set_y(value:Int) {
        if (value == y) {
            return y;
        }

        for (i in 0...text.length) {
            var elem = buffer.getElement(i);
            elem.y += value - y;
            buffer.updateElement(elem);
        }

        return y = value;
    }

    var width(default, null):Int;

    static var parsedTextAtlasData:Array<FontAtlasSprite>;

    function new(x:Int, y:Int, text:String = "Score: 1000000000000") {
        parsedTextAtlasData = haxe.Json.parse(sys.io.File.getContent("assets/fonts/vcrAtlas.json")).sprites;
        buffer = new Buffer<Sprite>(2048, 2048, false);

        this.text = text;
        this.x = x;
        this.y = y;
    }
}

private typedef FontAtlasSprite = {
    position:{
        x:Int,
        y:Int
    },
    sourceSize:{
        width:Int,
        height:Int
    },
    padding:Int,
    char:{
        advanceX:Int,
        offset:{x:Int, y:Int}
    }
}