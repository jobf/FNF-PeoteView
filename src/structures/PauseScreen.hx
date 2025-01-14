package structures;

import lime.ui.KeyCode;
import lime.ui.KeyModifier;

/**
	The playfield's pause menu.
**/
@:publicFields
class PauseScreen {
	var parent:HUD;

	var pauseBG(default, null):UISprite;
	var pauseOptions(default, null):Array<UISprite> = [];
	var pauseOptionSelected(default, null):Int = 0;

	function new(parent:HUD) {
		this.parent = parent;

		pauseBG = new UISprite();

		pauseBG.type = HEALTH_BAR_PART;
		pauseBG.changeID(0);
		pauseBG.w = Main.INITIAL_WIDTH;
		pauseBG.h = Main.INITIAL_HEIGHT;
		pauseBG.c.aF = 0.5;

		var currentY = 160;
		for (i in 0...3) {
			var option = new UISprite();
			option.type = PAUSE_OPTION;
			option.changeID(i);
			option.y = currentY;
			currentY += option.h + 2;
			pauseOptions.push(option);
		}
	}

	function update(code:KeyCode, mod:KeyModifier) {
		switch (code) {
			case -1: // This is here so the pause screen can update the first time when opening it
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
						parent.parent.resume();
						return;
					case 1:
					case 2:
						Sys.exit(-1);
				}
			default:
				return;
		}

		for (i in 0...pauseOptions.length) {
			var pauseOption = pauseOptions[i];
			if (i == pauseOptionSelected) pauseOption.c = 0xFFFF00FF;
			else pauseOption.c = 0xFFFFFFFF;
			parent.uiBuf.updateElement(pauseOption);
		}
	}

	function open() {
		parent.uiBuf.addElement(pauseBG);

		for (i in 0...pauseOptions.length) {
			parent.uiBuf.addElement(pauseOptions[i]);
		}

		update(-1, -1);

		haxe.Timer.delay(() -> {
			var window = lime.app.Application.current.window;
			window.onKeyDown.add(update);
		}, 200);
	}

	function close() {
		parent.uiBuf.removeElement(pauseBG);

		for (i in 0...pauseOptions.length) {
			parent.uiBuf.removeElement(pauseOptions[i]);
		}

		var window = lime.app.Application.current.window;
		window.onKeyDown.remove(update);
	}

	function dispose() {
		try {
			parent.uiBuf.removeElement(pauseBG);
		} catch (e) {}
		pauseBG = null;

		while (pauseOptions.length != 0) {
			var pauseOption = pauseOptions.pop();
			try {
				parent.uiBuf.removeElement(pauseOption);
			} catch (e) {}
			pauseOption = null;
		}
	}
}