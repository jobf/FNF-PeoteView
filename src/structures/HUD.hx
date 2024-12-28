package structures;

import lime.ui.KeyCode;
import lime.ui.KeyModifier;

/**
	The playfield's HUD.
**/
@:publicFields
@:access(structures.PlayField)
class HUD {
	var countdownDisp:CountdownDisplay;
	var pauseScreen:PauseScreen;

	var uiBuf(default, null):Buffer<UISprite>;
	var uiProg(default, null):Program;
	var scoreTxtProg(default, null):Program;
	var watermarkTxtProg(default, null):Program;

	var scoreTxt:Text;
	var watermarkTxt:Text;

	var ratingPopup:UISprite;
	var comboNumbers:Array<UISprite> = [];

	var healthBarParts:Array<UISprite> = [];
	var healthBarBG:UISprite;

	var healthIcons:Array<UISprite> = [];
	var healthIconIDs:Array<Array<Int>> = [[0, 1], [2, 3]];
	var healthIconColors:Array<Array<Color>> = [
		[Color.RED1, Color.BLUE, Color.YELLOW, Color.RED3, Color.GREY2, Color.CYAN],
		[Color.LIME, Color.LIME, Color.LIME, Color.LIME, Color.LIME, Color.LIME]
	];

	var healthBarWS:Int;
	var healthBarHS:Int;

	var parent:PlayField;

	/**
		Create the playfield UI.
	**/
	function new(display:Display, parent:PlayField) {
		this.parent = parent;

		healthBarWS = UISprite.healthBarDimensions[2];
		healthBarHS = UISprite.healthBarDimensions[3];

		uiBuf = new Buffer<UISprite>(2048, 2048, false);
		uiProg = new Program(uiBuf);
		uiProg.blendEnabled = true;

		var tex = TextureSystem.getTexture("uiTex");

		UISprite.init(uiProg, "uiTex", tex);

		// RATING POPUP SETUP
		ratingPopup = new UISprite();
		ratingPopup.type = RATING_POPUP;
		ratingPopup.changeID(0);
		ratingPopup.x = 500;
		ratingPopup.y = 360;
		ratingPopup.c.aF = 0.0;
		uiBuf.addElement(ratingPopup);

		// COMBO NUMBERS SETUP
		for (i in 0...39) {
			var comboNumber = new UISprite();
			comboNumber.type = COMBO_NUMBER;
			comboNumber.changeID(0);
			comboNumber.x = ratingPopup.x + 208 - ((comboNumber.w + 2) * i);
			comboNumber.y = ratingPopup.y + (ratingPopup.h + 5);
			comboNumber.c.aF = 0.0;
			comboNumbers.push(comboNumber);
			uiBuf.addElement(comboNumber);
		}

		// HEALTH BAR SETUP
		healthBarBG = new UISprite();
		healthBarBG.type = HEALTH_BAR;
		healthBarBG.changeID(0);
		healthBarBG.x = 275;
		healthBarBG.y = parent.downScroll ? 90 : Main.INITIAL_HEIGHT - 90;

		// HEALTH BAR PART SETUP
		for (i in 0...2) {
			var part = healthBarParts[i] = new UISprite();
			part.type = HEALTH_BAR_PART;
			part.changeID(i);
			part.h = healthBarBG.h - (healthBarHS << 1);
			part.y = healthBarBG.y + healthBarHS;
			part.gradientMode = 1.0;

			var healthIconColor = healthIconColors[i];
			part.setAllColors(healthIconColor);

			uiBuf.addElement(part);
		}

		uiBuf.addElement(healthBarBG);

		updateHealthBar();

		// HEALTH ICONS SETUP

		var x = healthBarBG.x + (healthBarBG.w >> 1);

		var oppIcon = healthIcons[0] = new UISprite();
		oppIcon.type = HEALTH_ICON;
		oppIcon.changeID(healthIconIDs[0][0]);

		var plrIcon = healthIcons[1] = new UISprite();
		plrIcon.type = HEALTH_ICON;
		plrIcon.changeID(healthIconIDs[1][0]);

		oppIcon.y = plrIcon.y = healthBarBG.y - 75;
		plrIcon.flip = 1;

		uiBuf.addElement(oppIcon);
		uiBuf.addElement(plrIcon);

		updateHealthIcons();

		// TEXT SETUP

		scoreTxt = new Text(0, 0);

		watermarkTxt = new Text(0, 0, 'FV TEST BUILD' #if FV_DEBUG + ' | -/= to change time, F8 to flip bar, [/] to adjust latency by 10ms, B to toggle botplay, and M to toggle downscroll (0ms)' #end);
		watermarkTxt.x = 2;
		watermarkTxt.scale = 0.7;
		watermarkTxt.y = parent.display.height - (watermarkTxt.height + 2);

		scoreTxtProg = new Program(scoreTxt.buffer);
		scoreTxtProg.blendEnabled = true;
		scoreTxtProg.setFragmentFloatPrecision("medium", true);
		watermarkTxtProg = new Program(watermarkTxt.buffer);
		watermarkTxtProg.blendEnabled = true;
		watermarkTxtProg.setFragmentFloatPrecision("medium", true);

		TextureSystem.setTexture(scoreTxtProg, 'vcrTex', 'vcrTex');
		display.addProgram(scoreTxtProg);
		TextureSystem.setTexture(watermarkTxtProg, 'vcrTex', 'vcrTex');
		display.addProgram(watermarkTxtProg);

		display.addProgram(uiProg);

		countdownDisp = new CountdownDisplay(uiBuf);
		pauseScreen = new PauseScreen(this);
	}

	function update(deltaTime:Float) {
		updateRatingPopup(deltaTime);
		updateComboNumbers();
		updateHealthBar();
		updateHealthIcons();
		updateScoreText(deltaTime);
		countdownDisp.update(deltaTime);
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
		Updates the health bar.
	**/
	function updateHealthBar() {
		if (parent.disposed) return;

		healthBarBG.y = parent.downScroll ? 90 : Main.INITIAL_HEIGHT - 90;
		uiBuf.updateElement(healthBarBG);

		var health = parent.health;

		var part1 = healthBarParts[0];

		if (part1 == null) return;

		var healthIconColor = healthIconColors[parent.flipHealthBar ? 1 : 0];

		part1.setAllColors(healthIconColor);

		part1.w = (healthBarBG.w - Math.floor(healthBarBG.w * (parent.flipHealthBar ? 1 - health : health))) - (healthBarWS << 1);
		part1.x = healthBarBG.x + healthBarWS;
		part1.y = healthBarBG.y + healthBarHS;

		if (part1.w < 0) part1.w = 0;

		uiBuf.updateElement(part1);

		var part2 = healthBarParts[1];

		if (part2 == null) return;

		var healthIconColor = healthIconColors[parent.flipHealthBar ? 0 : 1];

		part2.setAllColors(healthIconColor);

		part2.w = (healthBarBG.w - part1.w) - (healthBarWS << 1);
		part2.x = (healthBarBG.x + part1.w) + healthBarWS;
		part2.y = healthBarBG.y + healthBarHS;

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
		inline function lerp(a:Float, b:Float, ratio:Float):Float
			return a + ratio * (b - a);

		scoreTxt.text = 'Score: ${parent.score}, Misses: ${parent.misses}';
		scoreTxt.scale = lerp(scoreTxt.scale, 1.0, deltaTime * 0.02);
		scoreTxt.x = Math.floor(healthBarBG.x) + ((healthBarBG.w - scoreTxt.width) * 0.5);
		scoreTxt.y = Math.floor(healthBarBG.y) + (healthBarBG.h + 6);
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
		countdownDisp.dispose();
		countdownDisp = null;

		pauseScreen.dispose();
		pauseScreen = null;

		uiBuf.removeElement(ratingPopup);
		ratingPopup = null;

		for (i in 0...comboNumbers.length) {
			uiBuf.removeElement(comboNumbers[i]);
			comboNumbers[i] = null;
		}
		comboNumbers = null;

		uiBuf.removeElement(healthBarBG);
		healthBarBG = null;

		for (i in 0...healthIcons.length) {
			uiBuf.removeElement(healthIcons[i]);
			healthIcons[i] = null;
		}
		healthIcons = null;

		var display = parent.display;

		display.removeProgram(uiProg);
		display.removeProgram(scoreTxtProg);
		display.removeProgram(watermarkTxtProg);

		uiProg = null;
		scoreTxtProg = null;
		watermarkTxtProg = null;
	}
}