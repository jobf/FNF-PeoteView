package structures;

/**
	The first state of the game.
**/
@:publicFields
class MainMenu {
	var display:CustomDisplay;
	var view:CustomDisplay;

	var optionBuf:Buffer<UISprite>;
	var optionProg:Program;

	var backgroundBuf:Buffer<Sprite>;
	var backgroundProg:Program;

	var optionSelected:Int = 0;

	var disposed:Bool = false;

	function new(display:CustomDisplay, view:CustomDisplay) {
		this.display = display;
		this.view = view;

		optionBuf = new Buffer<UISprite>(5);
		optionProg = new Program(optionBuf);
		optionProg.blendEnabled = true;

		backgroundBuf = new Buffer<Sprite>(1);
		backgroundProg = new Program(backgroundBuf);
		backgroundProg.blendEnabled = true;

		TextureSystem.setTexture(optionProg, "uiTex", "uiTex");
		TextureSystem.setTexture(backgroundProg, "mainMenuBGTex", "mainMenuBGTex");

		display.addProgram(optionProg);
		view.addProgram(backgroundProg);

		for (i in 0...4) {
			var spr = new UISprite();
			spr.type = MAIN_MENU_PART;
			spr.changeID(i << 1);
			spr.x = 20;
			spr.y = 20 + (spr.h * i);
			optionBuf.addElement(spr);
		}

		var bg = new Sprite();
		backgroundBuf.addElement(bg);

		optionBuf.update();
		backgroundBuf.updateElement(bg);
	}

	function update(deltaTime:Float) {

	}

	function dispose() {
		display.removeProgram(optionProg);
		view = null;
		optionProg = null;
		optionBuf.clear();
		optionBuf = null;

		view.removeProgram(backgroundProg);
		view = null;
		backgroundProg = null;
		backgroundBuf.clear();
		backgroundBuf = null;

		disposed = true;
	}
}