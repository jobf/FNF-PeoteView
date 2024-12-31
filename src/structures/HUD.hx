package structures;

import lime.ui.KeyCode;
import lime.ui.KeyModifier;

/**
	The playfield's HUD.
	This is an internal structure and should only be used inside of the playfield NOT to be touched with.
**/
@:publicFields
@:access(structures.PlayField)
class HUD {
	static var uiBuf(default, null):Buffer<UISprite>;
	static var uiProg(default, null):Program;

	var scoreTxt:Text;
	var watermarkTxt:Text;

	var ratingPopup:UISprite;
	var comboNumbers:Array<UISprite> = [];

	var healthBarParts:Array<UISprite> = [];
	var healthBarBG:UISprite;

	var healthIcons:Array<UISprite> = [];
	var healthIconIDs:Array<Array<Int>> = [[0, 1], [2, 3]];
	var healthIconColors:Array<Array<Color>> = [
		[Color.WHITE, Color.BLUE, Color.YELLOW, Color.RED3, Color.GREY2, Color.CYAN],
		[Color.LIME, Color.LIME, Color.LIME, Color.LIME, Color.LIME, Color.LIME]
	];

	var healthBarWS:Float;
	var healthBarHS:Float;
	var healthBarXA:Float;
	var healthBarYA:Float;

	var display:CustomDisplay;
	var parent:PlayField;

	/**
		Create the playfield UI.
	**/
	function new(display:CustomDisplay, parent:PlayField) {
		this.display = display;
		this.parent = parent;

		healthBarWS = UISprite.healthBarProperties[2];
		healthBarHS = UISprite.healthBarProperties[3];

		healthBarXA = UISprite.healthBarProperties[4];
		healthBarYA = UISprite.healthBarProperties[5];

		// HEALTH BAR SETUP
		healthBarBG = new UISprite();
		healthBarBG.type = HEALTH_BAR;
		healthBarBG.changeID(0);
		healthBarBG.x = 275;
		healthBarBG.y = parent.downScroll ? 90 : Main.INITIAL_HEIGHT - 90;

		var actors_sparrow = parent.field.actors_sparrow;

		// HEALTH BAR PART SETUP
		for (i in 0...2) {
			var part = healthBarParts[i] = new UISprite();
			part.h = healthBarBG.h - healthBarHS;
			part.y = healthBarBG.y + healthBarYA;
			part.gradientMode = 1.0;

			part.setAllColors(actors_sparrow[i].data.colors);

			uiBuf.addElement(part);
		}

		uiBuf.addElement(healthBarBG);

		updateHealthBar();

		// HEALTH ICONS SETUP

		var x = healthBarBG.x + (healthBarBG.w * 0.5);

		for (i in 0...2) {
			var healthIconIndexes = actors_sparrow[i].data.healthIconIndexes;
			healthIconIDs[i] = [healthIconIndexes[0], healthIconIndexes[1]];
		}

		var oppIcon = healthIcons[0] = new UISprite();
		oppIcon.type = HEALTH_ICON;
		oppIcon.changeID(healthIconIDs[0][0]);

		var plrIcon = healthIcons[1] = new UISprite();
		plrIcon.type = HEALTH_ICON;
		plrIcon.changeID(healthIconIDs[1][0]);

		oppIcon.y = plrIcon.y = healthBarBG.y - 75;
		plrIcon.flip = true;

		uiBuf.addElement(oppIcon);
		uiBuf.addElement(plrIcon);

		updateHealthIcons();

		// TEXT SETUP

		scoreTxt = new Text(0, 0, display);

		watermarkTxt = new Text(0, 0, display, 'FV TEST BUILD' #if FV_DEBUG + ' | -/= to change time, F8 to flip bar, [/] to adjust latency by 10ms, B to toggle botplay, and M to toggle downscroll (0ms)' #end);
		watermarkTxt.x = 2;
		watermarkTxt.scale = 0.7;
		watermarkTxt.y = parent.display.height - (watermarkTxt.height + 2);

		// RATING AND COMBO NUMBER POPUP SETUP
		if (SaveData.state.ratingPopup) {
			ratingPopup = new UISprite();
			ratingPopup.type = RATING_POPUP;
			ratingPopup.changeID(0);
			ratingPopup.x = 500;
			ratingPopup.y = 360;
			ratingPopup.c.aF = 0.0;
			uiBuf.addElement(ratingPopup);

			for (i in 0...3) addComboNumber();
		}
	}

	/**
		Initializes the HUD with a static buffer and program.
	**/
	static function init(display:CustomDisplay) {
		if (uiBuf == null) {
			uiBuf = new Buffer<UISprite>(16, 16, false);
			uiProg = new Program(uiBuf);
			uiProg.blendEnabled = true;

			var tex = TextureSystem.getTexture("uiTex");
			UISprite.init(uiProg, "uiTex", tex);

			display.addProgram(uiProg);
		}
	}

	/**
		Updates the HUD.
	**/
	function update(deltaTime:Float) {
		if (SaveData.state.ratingPopup) {
			updateRatingPopup(deltaTime);
			updateComboNumbers();
		}
		updateHealthBar();
		updateHealthIcons();
		updateScoreText(deltaTime);
	}

	/**
		Updates the rating popup.
	**/
	function updateRatingPopup(deltaTime:Float) {
		if (parent.disposed) return;

		if (ratingPopup == null) return;

		if (ratingPopup.c.aF != 0) {
			ratingPopup.c.aF -= ratingPopup.c.aF * (deltaTime * 0.005);
		}

		if (ratingPopup.y != 320) {
			ratingPopup.y -= (ratingPopup.y - 320) * (deltaTime * 0.0125);
			uiBuf.updateElement(ratingPopup);
		}
	}

	/**
		Updates the combo numbers.
	**/
	function updateComboNumbers() {
		if (parent.disposed) return;

		var numStr = Int128.toStr(parent.combo);

		var comboNumberStrLen = numStr.length;

		if (comboNumberStrLen <= 3) comboNumberStrLen = 3;

		while (comboNumbers.length < comboNumberStrLen) addComboNumber();

		while (comboNumbers.length > comboNumberStrLen) {
			var comboNumber = comboNumbers.pop();
			uiBuf.removeElement(comboNumber);
		}

		for (i in 0...comboNumbers.length) {
			var comboNumber = comboNumbers[i];

			if (comboNumber == null) continue;

			var digit = numStr.charCodeAt(i <= numStr.length ? (numStr.length - 1) - i : numStr.length - 1) - 48;

			comboNumber.y = ratingPopup.y + (ratingPopup.h + 5);
			comboNumber.c.aF = ratingPopup.c.aF;

			if (i > 2) {

				if (i >= numStr.length) {
					comboNumber.c.aF = 0.0;
				}
			}

			if (comboNumber.curID != digit) comboNumber.changeID(i >= numStr.length ? 0 : digit);

			uiBuf.updateElement(comboNumber);
		}
	}

	/**
		Adds a new combo number onto the ui buffer.
	**/
	function addComboNumber() {
		if (SaveData.state.ratingPopup) {
			// COMBO NUMBERS SETUP
			var comboNumber = new UISprite();
			comboNumber.type = COMBO_NUMBER;
			comboNumber.changeID(0);
			comboNumber.x = ratingPopup.x + 208 - ((comboNumber.w + 2) * comboNumbers.length);
			comboNumber.y = ratingPopup.y + (ratingPopup.h + 5);
			comboNumber.c.aF = 0.0;
			comboNumbers.push(comboNumber);
			uiBuf.addElement(comboNumber);
		}
	}

	/**
		Updates the health bar.
	**/
	function updateHealthBar() {
		if (parent.disposed) return;

		healthBarBG.y = parent.downScroll ? 90 : Main.INITIAL_HEIGHT - 90;
		uiBuf.updateElement(healthBarBG);

		var health = parent.health;
		var actors_sparrow = parent.field.actors_sparrow;

		var part1 = healthBarParts[0];

		if (part1 == null) return;

		var healthIconColor = actors_sparrow[parent.flipHealthBar ? 1 : 0].data.colors;

		part1.setAllColors(healthIconColor);

		part1.w = (healthBarBG.w - Math.floor(healthBarBG.w * (parent.flipHealthBar ? 1 - health : health))) - (healthBarWS * 2.0);
		part1.x = healthBarBG.x + healthBarXA;
		part1.y = healthBarBG.y + healthBarYA;

		if (part1.w < 0) part1.w = 0;

		uiBuf.updateElement(part1);

		var part2 = healthBarParts[1];

		if (part2 == null) return;

		var healthIconColor = actors_sparrow[parent.flipHealthBar ? 0 : 1].data.colors;

		part2.setAllColors(healthIconColor);

		part2.w = (healthBarBG.w - part1.w) - (healthBarWS * 2.0);
		part2.x = (healthBarBG.x + part1.w) + healthBarXA;
		part2.y = healthBarBG.y + healthBarYA;

		if (part2.w < 0) part2.w = 0;

		uiBuf.updateElement(part2);
	}

	/**
		Updates the health icons.
	**/
	function updateHealthIcons() {
		if (parent.disposed) return;

		var part1 = healthBarParts[1];

		if (part1 == null) return;

		var health = parent.health;
		var icons = healthIcons;
		var ids = healthIconIDs;

		var oppIcon = icons[0];
		var plrIcon = icons[1];

		var oppIcon = healthIcons[0];
		oppIcon.x = part1.x - 118;

		var plrIcon = healthIcons[1];
		plrIcon.x = part1.x - 18;

		oppIcon.y = plrIcon.y = healthBarBG.y - 75;

		var oppIco = parent.flipHealthBar ? plrIcon : oppIcon;
		var plrIco = parent.flipHealthBar ? oppIcon : plrIcon;

		if (health > 0.75) oppIco.changeID(ids[0][1]);
		else oppIco.changeID(ids[0][0]);

		if (health < 0.25) plrIco.changeID(ids[1][1]);
		else plrIco.changeID(ids[1][0]);

		uiBuf.updateElement(oppIcon);
		uiBuf.updateElement(plrIcon);
	}

	/**
		Updates the score text.
	**/
	function updateScoreText(deltaTime:Float) {
		var acc2 = parent.accuracy[1];
		if (acc2 == 0) acc2 = 1;
		var acc:Int64 = Int64.toInt(((parent.accuracy[0] * 10000) / acc2).low);
		var accDecimal:Int64 = acc % 100;

		scoreTxt.text = 'Score: ${parent.score}, Misses: ${parent.misses}, Accuracy: ${(acc / 100) + (accDecimal != 0 ? ("." + (accDecimal < 10 ? "0" : "") + accDecimal) : "")}%';
		scoreTxt.scale = (Tools.lerp(scoreTxt.scale, 1.0, deltaTime * 0.02):Single);
		scoreTxt.x = Math.floor(healthBarBG.x) + ((healthBarBG.w - scoreTxt.width) * 0.5);
		scoreTxt.y = Math.floor(healthBarBG.y) + (healthBarBG.h + 6);
		/*scoreTxt.color = 0xFFDC8CFF;
		scoreTxt.setMarkerPair('Score: ', Color.WHITE);
		scoreTxt.setMarkerPair(', Misses: ', Color.WHITE);
		scoreTxt.setMarkerPair(', Accuracy: ', Color.WHITE);*/
	}

	/**
		Hides the rating popup.
	**/
	inline function hideRatingPopup() {
		if (parent.disposed) return;

		ratingPopup.c.aF = 0.0;
		uiBuf.updateElement(ratingPopup);
	}

	/**
		Wakes up the rating popup.
	**/
	inline function respondWithRatingID(id:Int) {
		if (parent.disposed) return;

		ratingPopup.c.aF = 1.0;
		ratingPopup.y = 300;
		ratingPopup.changeID(id);
		uiBuf.updateElement(ratingPopup);
	}

	/**
		Dispose the hud.
	**/
	function dispose() {
		if (SaveData.state.ratingPopup) {
			uiBuf.removeElement(ratingPopup);
			ratingPopup = null;
	
			while (comboNumbers.length != 0) {
				var comboNumber = comboNumbers.pop();
				uiBuf.removeElement(comboNumber);
			}
			comboNumbers = null;
		}

		uiBuf.removeElement(healthBarBG);
		healthBarBG = null;

		while (healthBarParts.length != 0) {
			var healthBarPart = healthBarParts.pop();
			uiBuf.removeElement(healthBarPart);
		}
		healthBarParts = null;

		while (healthIcons.length != 0) {
			var healthIcon = healthIcons.pop();
			uiBuf.removeElement(healthIcon);
		}
		healthIcons = null;

		scoreTxt.dispose();
		watermarkTxt.dispose();
	}
}