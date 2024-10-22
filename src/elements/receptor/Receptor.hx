package elements.receptor;

import lime.ui.KeyCode;
import lime.ui.KeyModifier;

class Receptor extends Note
{
	@color public var c:Color = 0xFFFFFFFF;

	// --------------------------------------------------------------------------
	
	static public var buffer:Buffer<Note>;
	static public var program:Program;
	static public var keybindMap:Map<KeyCode, Int>;
	
	static public function init(display:Display, name:String, texture:Texture)
	{
		keybindMap = new Map<KeyCode, Int>();

		buffer = new Buffer<Note>(1, 1024, true);
		program = new Program(buffer);
		program.blendEnabled = true;
		
		// creates a texture-layer named "name"
		program.setTexture(texture, name, true );
				
		display.addProgram(program);
	}
	
	public function new(x:Int, y:Int, w:Int, h:Int) {
		super();

		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;

		buffer.addElement(this);
	}

	public static inline function keyPress(keyCode:KeyCode, keyMod:KeyModifier) {
		var id = keybindMap[keyCode];

		if (id != null) {
			var receptor = buffer.getElement(id);
			receptor.frame = 2;
			buffer.updateElement(receptor);
		}
	}

	public static inline function keyRelease(keyCode:KeyCode, keyMod:KeyModifier) {
		var id = keybindMap[keyCode];

		if (id != null) {
			var receptor = buffer.getElement(id);
			receptor.frame = 0;
			buffer.updateElement(receptor);
		}
	}
}