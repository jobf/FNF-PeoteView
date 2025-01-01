package structures;

import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import haxe.ds.Vector;

/**
	The first state of the game.
**/
@:publicFields
class MainMenu implements State {
	static var optionAnims:Vector<String> = Vector.fromData(['story mode', 'freeplay', 'awards', 'credits', 'options', 'backspace to exit']);

	var display:CustomDisplay;
	var view:CustomDisplay;

	static var optionBuf:Buffer<Actor>;
	static var optionProg:Program;

	static var backgroundBuf:Buffer<Sprite>;
	static var backgroundProg:Program;

	var watermarkTxt:Text;

	var optionSelected:Int = 0;

	var disposed:Bool = false;

	function new() {}

	function init(display:CustomDisplay, view:CustomDisplay) {
		this.display = display;
		this.view = view;

		if (optionBuf == null) {
			optionBuf = new Buffer<Actor>(6);
		}

		if (optionProg == null) {
			optionProg = new Program(optionBuf);
			optionProg.blendEnabled = true;

			TextureSystem.setTexture(optionProg, "mainMenuSheet", "mainMenuSheet");
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

		watermarkTxt = new Text("mainMenuWatermarkTxt", 0, 0, view, "FV TEST BUILD");
		watermarkTxt.y = Main.INITIAL_HEIGHT - watermarkTxt.height;

		for (i in 0...4) {
			var spr = new Actor("mainMenu", 0, 0, 24, "");
			spr.playAnimation(optionAnims[i] + ' basic', true);
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

	var optionLerps:Vector<Float> = new Vector<Float>(5);

	function update(deltaTime:Float) {
		for (i in 0...optionBuf.length) {
			optionLerps[i] = Tools.lerp(optionLerps[i], 300 - (125 * optionSelected) + (125 * i), deltaTime * 0.015);
			var option = optionBuf.getElement(i);
			option.x = (Main.INITIAL_WIDTH - option.w) * 0.5;
			option.y = optionLerps[i];
			optionBuf.updateElement(option);
		}
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
			var anim = optionAnims[i];
			if (i == optionSelected) option.playAnimation(anim + ' white', true);
			else option.playAnimation(anim + ' basic', true);
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

		watermarkTxt.dispose();

		disposed = true;
	}
}