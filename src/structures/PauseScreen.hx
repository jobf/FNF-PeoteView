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
	var pauseOptionSelected(default, null):Int = 0;
	var opened(default, null):Bool;

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

	function new() {
		var currentY = 200;
		for (i in 0...3) {
			var option = new PauseSprite();
			option.type = PAUSE_OPTION;
			option.changeID(i);
			option.x = 45;
			option.y = currentY;
			currentY += Math.floor(option.h) + 2;
			pauseOptions.push(option);
		}
	}

	function update(deltaTime:Float) {
		if (!opened && display.color.aF == 0) {
			if (pauseProg.isIn(display)) {
				for (i in 0...pauseOptions.length) {
					pauseBuf.removeElement(pauseOptions[i]);
				}

				display.removeProgram(pauseProg);
			}
			return;
		}

		display.color.aF = Tools.lerp(display.color.aF, opened ? 0.5 : 0.0, Math.min(deltaTime * 0.015, 1.0));
		display.color = display.color;

		for (i in 0...pauseOptions.length) {
			var pauseOption = pauseOptions[i];
			var originalC = pauseOption.c;
			if (i == pauseOptionSelected) pauseOption.c = Color.YELLOW;
			else pauseOption.c = Color.WHITE;
			pauseOption.c.aF = display.color.aF * 2.0;
			if (originalC != pauseOption.c) pauseBuf.updateElement(pauseOption);
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
					case 0:
						Main.current.playField.resume();
						return;
					case 1:
					case 2:
						Main.switchState(MAIN_MENU);
				}
			default:
				return;
		}
	}

	function open() {
		opened = true;

		try {
			for (i in 0...pauseOptions.length) {
				var pauseOption = pauseOptions[i];
				if (i == pauseOptionSelected) pauseOption.c = Color.YELLOW;
				else pauseOption.c = Color.WHITE;
				pauseBuf.addElement(pauseOptions[i]);
			}
		} catch (e) {}

		haxe.Timer.delay(() -> {
			var window = lime.app.Application.current.window;
			window.onKeyDown.add(selectOption);
		}, 200);

		if (!pauseProg.isIn(display)) {
			display.addProgram(pauseProg);
		}
	}

	function close() {
		var window = lime.app.Application.current.window;
		window.onKeyDown.remove(selectOption);

		opened = false;
	}

	function dispose() {
		close();

		while (pauseOptions.length != 0) {
			var pauseOption = pauseOptions.pop();
			if (opened) pauseBuf.removeElement(pauseOption);
			pauseOption = null;
		}
	}
}