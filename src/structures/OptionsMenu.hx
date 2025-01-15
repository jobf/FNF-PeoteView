package structures;

import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;

/**
	The playfield's options menu.
**/
@:publicFields
@:access(structures.PauseScreen)
class OptionsMenu {
	private static var display(default, null):CustomDisplay;
	static var optionsBuf(default, null):Buffer<OptionsSprite>;
	static var optionsProg(default, null):Program;

	var categorySelected(default, null):Int;
	var optionSelected(default, null):Int;

	var categorySprites(default, null):Array<OptionsSprite> = [];

	var onMainMenu:Bool = false;

	var opened(default, null):Bool;

	static var optionsDisplay(default, null):OptionsDisplay;

	static function init(disp:CustomDisplay) {
		display = disp;

		if (optionsBuf == null) {
			optionsBuf = new Buffer<OptionsSprite>(15);
			optionsProg = new Program(optionsBuf);
			optionsProg.blendEnabled = true;

			var tex = TextureSystem.getTexture("optionsMenuSheet");
			OptionsSprite.init(optionsProg, "optionsMenuSheet", tex);
		}
	}

	function new() {
		for (i in 0...3) {
			var option = new OptionsSprite();
			option.type = CATEGORY_TEXT;
			option.changeID(i);
			option.y = option.h * i;
			categorySprites.push(option);
		}

		if (optionsDisplay == null) {
			optionsDisplay = new OptionsDisplay(this);
		}
		optionsDisplay.reload(cast optionSelected);
	}

	var alphaLerp:Float = 0.0;

	function update(deltaTime:Float) {
		if (!opened && display.color.aF == 0) {
			shutDown();
			return;
		}

		alphaLerp = Tools.lerp(alphaLerp, opened ? 1.0 : 0.0, Math.min(deltaTime * 0.015, 1.0));

		if (onMainMenu) {
			display.color.aF = alphaLerp * 0.5;
			display.color = display.color;
		}

		for (i in 0...categorySprites.length) {
			var categorySprite = categorySprites[i];
			var originalC = categorySprite.c;
			if (i == categorySelected) categorySprite.c = Color.WHITE;
			else categorySprite.c = Color.GREY2;
			categorySprite.c.aF = alphaLerp;
			if (originalC != categorySprite.c) optionsBuf.updateElement(categorySprite);
		}

		optionsDisplay.update(deltaTime);
	}

	function open() {
		opened = true;

		try {
			for (i in 0...categorySprites.length) {
				var categorySprite = categorySprites[i];
				if (i == categorySelected) categorySprite.c = Color.WHITE;
				else categorySprite.c = Color.GREY2;
				categorySprite.c.aF = 0.0;
				optionsBuf.addElement(categorySprite);
			}

			alphaLerp = 0.0;
		} catch (e) {}

		haxe.Timer.delay(() -> {
			var window = lime.app.Application.current.window;
			window.onKeyDown.add(keyPress);
			window.onMouseDown.add(close_mouse);
		}, 200);

		if (!optionsProg.isIn(display)) {
			display.addProgram(optionsProg);
		}
	}

	function close() {
		var pf = Main.current.playField;

		if (onMainMenu) {
			MainMenu.selectedAlpha = 1.0;
			Main.current.mainMenu.addEvents();
		} else if (pf != null) {
			var pauseScreen = pf.pauseScreen;
			pauseScreen.atOptionsMenu = false;
			pauseScreen.addEvent();
		}

		var window = lime.app.Application.current.window;
		window.onKeyDown.remove(keyPress);
		window.onMouseDown.remove(close_mouse);

		opened = false;
	}

	function close_mouse(x:Float = 0.0, y:Float = 0.0, button:MouseButton) {
		if (button != RIGHT) return;
		close();
	}

	function keyPress(code:KeyCode, mod:KeyModifier) {
		switch (code) {
			case KeyCode.BACKSPACE:
				close();
			case KeyCode.DOWN:
				optionSelected++;
				if (optionSelected >= optionsDisplay.options.length) {
					optionSelected = 0;
				}
			case KeyCode.UP:
				optionSelected--;
				if (optionSelected < 0) {
					optionSelected = optionsDisplay.options.length - 1;
				}
			case KeyCode.RIGHT:
				categorySelected++;
				if (categorySelected >= categorySprites.length) {
					categorySelected = 0;
				}
				optionsDisplay.reload(cast categorySelected);
			case KeyCode.LEFT:
				categorySelected--;
				if (categorySelected < 0) {
					categorySelected = categorySprites.length - 1;
				}
				optionsDisplay.reload(cast categorySelected);
			default:
				return;
		}
	}

	function shutDown() {
		if (!optionsProg.isIn(display)) return;

		for (i in 0...categorySprites.length) {
			var categorySprites = categorySprites[i];
			categorySprites.c.aF = 0.0;
			optionsBuf.removeElement(categorySprites);
		}

		display.color = 0x00000000;
		display.removeProgram(optionsProg);
	}

	function dispose() {
		close();
		shutDown();

		if (opened) {
			while (categorySprites.length != 0) {
				var categorySprite = categorySprites.pop();
				optionsBuf.removeElement(categorySprite);
				categorySprite = null;
			}
		}
	}
}