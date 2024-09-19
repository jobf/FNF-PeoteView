package system.internal;

import sys.io.File;

/**
	The texture system.
**/
#if !debug
@:noDebug
#end
@:publicFields
class TextureSystem {
	/**
		The texture pool.
	**/
	static var pool:Map<String, Texture> = [];

	/**
		Get a pre-existing texture from pool.
		@param name 
	**/
	inline static function getTexture(name:String) {
		return pool[name];
	}

	/**
		Set the program's texture to the texture and key.
		@param prgm The program to set its texture to.
		@param name The texture's key.
		@param tex The texture's new name.
	**/

	inline static function setTexture(prgm:Program, name:String, tex:String) {
		prgm.setTexture(getTexture(name), tex, true);
	}

	/**
		Create a texture and put it in the texture pool.
		@param name The texture's name.
		@param path The texture path.
		@param slot The texture's slot.
	**/
	static function createTexture(name:String, path:String, slot:Int = 0) {
		if (pool.exists(name)) {
			return;
		}

		var textureBytes = File.getBytes(path);
		var textureData = TextureData.fromFormatPNG(textureBytes);

		var texture = new Texture(textureData.width, textureData.height, 1, {format: textureData.format});
		texture.setData(textureData, slot);

		pool[name] = texture;
	}

	/**
		Create a multitexture and put it in the texture pool.
		You should despise this function's code as it's just flat out intruiging to deal with.
		@param name The multitexture's name.
		@param paths The texture paths.
	**/
	static function createMultiTexture(name:String, paths:Array<String>) {
		if (pool.exists(name)) {
			return;
		}

		var texturesToPush:Array<TextureData> = [];

		var totalTextureWidth:Int = 0;
		var totalTextureHeight:Int = 0;

		for (i in 0...paths.length) {
			var textureBytes = File.getBytes(paths[i]);
			var textureData = TextureData.RGBAfrom(TextureData.fromFormatPNG(textureBytes));

			texturesToPush.push(textureData);

			if (totalTextureWidth < textureData.width) {
				totalTextureWidth = textureData.width;
			}

			if (totalTextureHeight < textureData.height) {
				totalTextureHeight = textureData.height;
			}
		}

		var texture = new Texture(totalTextureWidth, totalTextureHeight, null, {
			slotsX: 1,
			slotsY: texturesToPush.length,
			powerOfTwo: false,
			smoothShrink: true
		});

		for (i in 0...texturesToPush.length) {
			texture.setData(texturesToPush[i], i);
		}

		pool[name] = texture;
	}
}