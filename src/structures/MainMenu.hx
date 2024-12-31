package structures;

import lime.ui.KeyCode;
import lime.ui.KeyModifier;

/**
	The first state of the game.
**/
@:publicFields
class MainMenu implements State {
	var display:CustomDisplay;
	var view:CustomDisplay;

	static var optionBuf:Buffer<UISprite>;
	static var optionProg:Program;

	static var backgroundBuf:Buffer<Sprite>;
	static var backgroundProg:Program;

	var optionSelected:Int = 0;

	var disposed:Bool = false;

	function new() {}

	function init(display:CustomDisplay, view:CustomDisplay) {
		this.display = display;
		this.view = view;

		if (optionBuf == null) {
			optionBuf = new Buffer<UISprite>(4);
		}

		if (optionProg == null) {
			optionProg = new Program(optionBuf);
			optionProg.blendEnabled = true;

			var tex = TextureSystem.getTexture("uiTex");
			UISprite.init(optionProg, "uiTex", tex);
		}

		if (backgroundBuf == null) {
			backgroundBuf = new Buffer<Sprite>(1);
		}

		if (backgroundProg == null) {
			backgroundProg = new Program(backgroundBuf);
			backgroundProg.blendEnabled = true;

			TextureSystem.setTexture(backgroundProg, "mainMenuBGTex", "mainMenuBGTex");
		}

		display.addProgram(optionProg);
		view.addProgram(backgroundProg);

		for (i in 0...4) {
			var spr = new UISprite();
			//spr.type = MAIN_MENU_PART;
			//spr.changeID(i << 1);
			spr.x = 20;
			spr.y = 20 + (spr.h * i);
			optionBuf.addElement(spr);
		}

		var bg = new Sprite();
		bg.clipWidth = bg.clipSizeX = bg.w = Main.INITIAL_WIDTH;
		bg.clipHeight = bg.clipSizeY = bg.h = Main.INITIAL_HEIGHT;
		//bg.c = 0xFFEEBBFF;
		bg.c = 0xEEFFDDFF;
		backgroundBuf.addElement(bg);

		optionBuf.update();
		backgroundBuf.updateElement(bg);

		haxe.Timer.delay(() -> {
			var window = lime.app.Application.current.window;
			window.onKeyDown.add(updateMenuOptions);
		}, 200);

		updateMenuOptions(-1, -1);
	}

	function update(deltaTime:Float) {
		
	}

	function updateMenuOptions(code:KeyCode, _:KeyModifier) {
		switch (code) {
			case -1: // This is here so the pause screen can update the first time when opening it
			case KeyCode.DOWN:
				optionSelected++;
				if (optionSelected >= optionBuf.length) {
					optionSelected = 0;
				}
			case KeyCode.UP:
				optionSelected--;
				if (optionSelected < 0) {
					optionSelected = optionBuf.length - 1;
				}
			case KeyCode.RETURN:
				switch (optionSelected) {
					case 0:
						Main.switchState(GAMEPLAY);
						return;
					case 1:
						// TODO
						return;
					case 2:
						// TODO
						return;
				}
			default:
				return;
		}

		for (i in 0...optionBuf.length) {
			var option = optionBuf.getElement(i);
			//if (i == optionSelected) option.changeID(i << 1);
			//else option.changeID((i << 1) + 1);
			optionBuf.updateElement(option);
		}
	}

	function dispose() {
		var window = lime.app.Application.current.window;
		window.onKeyDown.remove(updateMenuOptions);

		display.removeProgram(optionProg);
		display = null;
		optionBuf.clear();

		view.removeProgram(backgroundProg);
		view = null;
		backgroundBuf.clear();

		disposed = true;
	}
}