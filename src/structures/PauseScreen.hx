package structures;

import lime.ui.KeyCode;
import lime.ui.KeyModifier;

/**
	The playfield's pause menu.
	This is an internal structure and should only be used inside of the playfield NOT to be touched with.
**/
@:publicFields
class PauseScreen {
	private static var display(default, null):CustomDisplay;
	static var pauseBuf(default, null):Buffer<PauseSprite>;
	static var pauseProg(default, null):Program;

	var pauseOptions(default, null):Array<PauseSprite> = [];
	var diffText(default, null):PauseSprite;

	var pauseOptionSelected(default, null):Int = 0;
	var opened(default, null):Bool;
	var atOptionsMenu(default, null):Bool;

	var optionsMenu(default, null):OptionsMenu;

	static function init(disp:CustomDisplay) {
		display = disp;

		if (pauseBuf == null) {
			pauseBuf = new Buffer<PauseSprite>(5);
			pauseProg = new Program(pauseBuf);
			pauseProg.blendEnabled = true;

			var tex = TextureSystem.getTexture("pauseScreenSheet");
			PauseSprite.init(pauseProg, "pauseScreenSheet", tex);
		}
	}

	function new(difficulty:Difficulty) {
		var currentY = 200;
		for (i in 0...4) {
			var option = new PauseSprite();
			option.type = PAUSE_OPTION;
			option.changeID(i);
			option.x = 45;
			option.y = currentY;
			currentY += Math.floor(option.h) + 2;
			pauseOptions.push(option);
		}

		diffText = new PauseSprite();
		diffText.type = DIFF_TEXT;
		diffText.changeID(cast difficulty);
		diffText.x = Main.INITIAL_WIDTH - (diffText.w - 1);
		diffText.y = 1;

		OptionsMenu.init(display);
		optionsMenu = new OptionsMenu();
	}

	var alphaLerp:Float = 0.0;

	function update(deltaTime:Float) {
		if (!opened && display.color.aF == 0) {
			shutDown();
			return;
		}

		alphaLerp = Tools.lerp(alphaLerp, (opened || atOptionsMenu) ? 1.0 : 0.0, Math.min(deltaTime * 0.015, 1.0));

		display.color.aF = alphaLerp * 0.5;
		display.color = display.color;

		for (i in 0...pauseOptions.length) {
			var pauseOption = pauseOptions[i];
			var originalC = pauseOption.c;
			if (i == pauseOptionSelected) pauseOption.c = Color.YELLOW;
			else pauseOption.c = Color.WHITE;
			pauseOption.c.aF = alphaLerp;
			if (originalC != pauseOption.c) pauseBuf.updateElement(pauseOption);
		}

		diffText.c.aF = alphaLerp;
		pauseBuf.updateElement(diffText);

		if (atOptionsMenu) {
			optionsMenu.update(deltaTime);
		}
	}

	function selectOption(code:KeyCode, mod:KeyModifier) {
		switch (code) {
			case KeyCode.DOWN:
				pauseOptionSelected++;
				if (pauseOptionSelected >= pauseOptions.length) {
					pauseOptionSelected = 0;
				}
			case KeyCode.UP:
				pauseOptionSelected--;
				if (pauseOptionSelected < 0) {
					pauseOptionSelected = pauseOptions.length - 1;
				}
			case KeyCode.RETURN:
				switch (pauseOptionSelected) {
					case 0: // RESUME
						Main.current.playField.resume();
					case 1: // RESTART
						Main.switchState(GAMEPLAY);
					case 2: // OPTIONS
						optionsMenu.open();
						atOptionsMenu = true;
						removeEvent();
					case 3: // EXIT
						Main.switchState(MAIN_MENU);
				}
			default:
		}
	}

	function open() {
		opened = true;

		try {
			for (i in 0...pauseOptions.length) {
				var pauseOption = pauseOptions[i];
				if (i == pauseOptionSelected) pauseOption.c = Color.YELLOW;
				else pauseOption.c = Color.WHITE;
				pauseOption.c.aF = 0.0;
				pauseBuf.addElement(pauseOptions[i]);
			}

			alphaLerp = diffText.c.aF = 0.0;
			pauseBuf.addElement(diffText);
		} catch (e) {}

		haxe.Timer.delay(addEvent, 200);

		if (!pauseProg.isIn(display)) {
			display.addProgram(pauseProg);
		}
	}

	function addEvent() {
		var window = lime.app.Application.current.window;
		window.onKeyDown.add(selectOption);
	}

	function removeEvent() {
		var window = lime.app.Application.current.window;
		window.onKeyDown.remove(selectOption);
	}

	function close() {
		removeEvent();

		opened = false;
	}

	function shutDown() {
		if (!pauseProg.isIn(display)) return;

		for (i in 0...pauseOptions.length) {
			var pauseOption = pauseOptions[i];
			pauseOption.c.aF = 0.0;
			pauseBuf.removeElement(pauseOption);
		}

		pauseBuf.removeElement(diffText);

		display.color = 0x00000000;
		display.removeProgram(pauseProg);
	}

	function dispose() {
		close();
		shutDown();

		if (opened) {
			while (pauseOptions.length != 0) {
				var pauseOption = pauseOptions.pop();
				pauseBuf.removeElement(pauseOption);
				pauseOption = null;
			}
			pauseBuf.removeElement(diffText);
			diffText = null;
		}

		optionsMenu.dispose();
	}
}