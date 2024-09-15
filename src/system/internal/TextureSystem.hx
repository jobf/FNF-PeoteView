package system.internal;

import sys.io.File;

/**
 * The texture system.
 */
@:publicFields
class TextureSystem {
    static var pool:Map<String, Texture> = [];

    inline static function getTexture(name:String) {
        return pool.get(name);
    }

    inline static function setTexture(prgm:Program, name:String, tex:String) {
        prgm.setTexture(getTexture(name), tex, true);
    }

    static function createTexture(name:String, path:String = "") {
        if (pool.exists(name)) {
            return;
        }

        var textureBytes = File.getBytes(path);
        var textureData = TextureData.fromFormatPNG(textureBytes);
        var texture = new Texture(textureData.width, textureData.height, 1, {format: textureData.format});
        texture.setData(textureData);
        pool.set(name, texture);
    }
}