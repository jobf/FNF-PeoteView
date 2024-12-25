package system;

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
		@param key The texture to get from.
	**/
	inline static function getTexture(key:String) {
		return pool[key];
	}

	/**
		Set the program's texture to the texture and key.
		@param prgm The program to set its texture to.
		@param key The texture to get from.
		@param name The texture's new name.
	**/

	inline static function setTexture(prgm:Program, key:String, name:String) {
		prgm.setTexture(getTexture(key), name, true);
	}

	/**
		Set the program's texture to the texture and key.
		@param prgm The program to set its texture to.
		@param key The texture to get from.
		@param name The texture's new name.
	**/

	static function disposeTexture(key:String) {
		if (!pool.exists(key)) return;
		var tex = getTexture(key);
		tex.dispose();
		pool.remove(key);
		tex = null;
	}

	/**
		Create a texture and put it in the texture pool.
		This only accepts a single texture slot.
		@param key The texture's key.
		@param path The texture path.
	**/
	static function createTexture(key:String, path:String) {
		if (pool.exists(key)) {
			return;
		}

		var textureBytes = File.getBytes(path);
		var textureData = TextureData.fromFormatPNG(textureBytes);

		var texture = new Texture(textureData.width, textureData.height, null, {
			format: textureData.format,
			powerOfTwo: false,
			smoothExpand: true,
			smoothShrink: true
		});
		texture.setData(textureData);

		pool[key] = texture;
	}

	/**
		Create a tiled texture and put it in the texture pool.
		This accepts horizontal and/or vertical tiled textures.
		@param key The texture's key.
		@param path The texture path.
	**/
	static function createTiledTexture(key:String, path:String, tX:Int = 1, tY:Int = 1) {
		if (pool.exists(key)) {
			return;
		}

		var textureBytes = File.getBytes(path);
		var textureData = TextureData.fromFormatPNG(textureBytes);

		var texture = new Texture(textureData.width, textureData.height, null, {
			tilesX: tX,
			tilesY: tY,
			format: textureData.format,
			powerOfTwo: false,
			smoothExpand: true,
			smoothShrink: true
		});
		texture.setData(textureData);

		pool[key] = texture;
	}

	/**
		Create a multitexture and put it in the texture pool.
		You should despise this function's code as it's just flat out intruiging to deal with.
		@param key The multitexture's key.
		@param paths The texture paths.
	**/
	static function createMultiTexture(key:String, paths:Array<String>) {
		if (pool.exists(key)) {
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
			slotsX: texturesToPush.length,
			slotsY: 1,
			powerOfTwo: false,
			smoothExpand: true,
			smoothShrink: true
		});

		for (i in 0...texturesToPush.length) {
			texture.setData(texturesToPush[i], i);
		}

		pool[key] = texture;
	}
}