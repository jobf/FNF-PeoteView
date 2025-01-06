package structures;

import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
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

	var selectedByMouse:Bool = false;

	function new() {}

	function init(display:CustomDisplay, view:CustomDisplay) {

		this.display = display;
		this.view = view;

		view.scroll.x = 0;
		view.scroll.y = 0;
		view.fov = 1.0;

		if (optionBuf == null) {
			optionBuf = new Buffer<Actor>(optionAnims.length);
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

		for (i in 0...optionAnims.length) {
			var spr = new Actor(view, "mainMenu", 0, 0, 24, "", false);
			spr.playAnimation(optionAnims[i] + ' basic', true);
			spr.x = 20;
			spr.y = 20 + (spr.h * i);
			spr.c.aF = 0.0;
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
			window.onKeyDown.add(updateMenuOptions_keyboard);
			window.onMouseMove.add(updateMenuOptions_mouse);
			window.onMouseDown.add(enter);
		}, 200);

		updateMenuOptions();
	}

	static var optionYLerps:Vector<Float> = new Vector<Float>(5);
	static var alphaLerps:Vector<Float> = new Vector<Float>(6);

	function update(deltaTime:Float) {
		for (i in 0...optionBuf.length) {
			var option = optionBuf.getElement(i);

			var t = deltaTime * 0.0115;

			if (i != alphaLerps.length - 1) {
				optionYLerps[i] = Tools.lerp(optionYLerps[i], (45 + (125 * i)) - (6 * Math.min(optionSelected, optionAnims.length - 2)), t);
				option.y = optionYLerps[i];
				option.x = (Main.INITIAL_WIDTH - option.w) * 0.5;
			}

			alphaLerps[i] = Tools.lerp(alphaLerps[i], 1.0, t);
			option.c.aF = alphaLerps[i];
			optionBuf.updateElement(option);
		}
	}

	function updateMenuOptions() {
		for (i in 0...optionBuf.length) {
			var option = optionBuf.getElement(i);
			var anim = optionAnims[i];
			if (i == optionSelected) option.playAnimation(anim + ' white', true);
			else option.playAnimation(anim + ' basic', true);
			optionBuf.updateElement(option);
		}
	}

	function updateMenuOptions_keyboard(code:KeyCode, _:KeyModifier) {
		switch (code) {
			case KeyCode.DOWN:
				optionSelected++;
				if (optionSelected >= optionBuf.length - 1) {
					optionSelected = 0;
				}
			case KeyCode.UP:
				optionSelected--;
				if (optionSelected < 0) {
					optionSelected = optionBuf.length - 2;
				}
			case KeyCode.LEFT:
			if (optionSelected == optionBuf.length - 1) optionSelected = optionBuf.length - 2;
				else optionSelected = optionBuf.length - 1;
			case KeyCode.RIGHT:
				optionSelected = optionBuf.length - 2;
			case KeyCode.RETURN:
				enter(0.0, 0.0, LEFT);
			default:
				return;
		}

		updateMenuOptions();
	}

	function updateMenuOptions_mouse(x:Float, y:Float) {
		for (i in 0...optionBuf.length) {
			var option = optionBuf.getElement(i);
			if (x >= option.x && y >= option.y &&
				x <= option.x + option.w &&
				y <= option.y + option.h && optionSelected != i) {
				optionSelected = i;
				selectedByMouse = true;
				updateMenuOptions();
			}
		}
	}

	function isSelectingOption(x:Float, y:Float) {
		for (i in 0...optionBuf.length) {
			var option = optionBuf.getElement(i);
			if (x >= option.x && y >= option.y &&
				x <= option.x + option.w &&
				y <= option.y + option.h && optionSelected == i) {
				return true;
			}
		}

		return false;
	}

	function enter(x:Float = 0.0, y:Float = 0.0, button:MouseButton) {
		if (selectedByMouse && (button != LEFT || !isSelectingOption(x, y))) return;

		switch (optionSelected) {
			case 0: // STORY MODE
				Main.switchState(GAMEPLAY);
			case 1: // FREEPLAY
				// TODO
			case 2: // AWARDS
				// TODO
			case 3: // CREDITS
				// TODO
			case 4: // OPTIONS
				// TODO
			case 5:
				Sys.exit(0);
		}

		selectedByMouse = false;
	}

	function dispose() {
		var window = lime.app.Application.current.window;
		window.onKeyDown.remove(updateMenuOptions_keyboard);
		window.onMouseMove.remove(updateMenuOptions_mouse);
		window.onMouseDown.remove(enter);

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