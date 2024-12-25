package structures;

/**
	The playfield's HUD.
**/
@:publicFields
@:access(structures.PlayField)
class HUD {
	var countdownDisp:CountdownDisplay;

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
		[Color.RED1, Color.RED1, Color.RED1, Color.RED1, Color.RED1, Color.RED1],
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

		// HEALTH BAR PART SETUP
		for (i in 0...2) {
			var part = healthBarParts[i] = new UISprite();
			part.type = HEALTH_BAR_PART;
			part.changeID(i);
			part.h = healthBarBG.h - (healthBarHS << 1);
			part.y = healthBarBG.y + healthBarHS;

			var healthIconColor = healthIconColors[i];
			//part.c = healthIconColor[0];

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

		watermarkTxt = new Text(0, 0, "-/= to change time, F8 to flip bar, [/] to adjust latency by 10ms, and B to toggle botplay");
		watermarkTxt.x = 2;
		watermarkTxt.y = parent.display.height - (watermarkTxt.height + 2);

		scoreTxtProg = new Program(scoreTxt.buffer);
		scoreTxtProg.blendEnabled = true;
		watermarkTxtProg = new Program(watermarkTxt.buffer);
		watermarkTxtProg.blendEnabled = true;

		TextureSystem.setTexture(scoreTxtProg, 'vcrTex', 'vcrTex');
		display.addProgram(scoreTxtProg);
		TextureSystem.setTexture(watermarkTxtProg, 'vcrTex', 'vcrTex');
		display.addProgram(watermarkTxtProg);

		display.addProgram(uiProg);

		countdownDisp = new CountdownDisplay(uiBuf);

		createPauseScreen();
	}

	function update(deltaTime:Float) {
		updateRatingPopup(deltaTime);
		updateComboNumbers();
		updateHealthBar();
		updateHealthIcons();
		countdownDisp.update(deltaTime);

		scoreTxt.text = 'Score: ${parent.score}, Misses: ${parent.misses}';
		scoreTxt.x = Math.floor(healthBarBG.x) + ((healthBarBG.w - scoreTxt.width) >> 1);
		scoreTxt.y = Math.floor(healthBarBG.y) + (healthBarBG.h + 6);
		watermarkTxt.text = 'FV TEST BUILD | - -/= to change time, F8 to flip bar, [/] to adjust latency by 10ms, and B to toggle botplay (${parent.latencyCompensation}ms)';
		watermarkTxt.scale = 0.7;
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

		//part1.c = healthIconColor[0];

		part1.w = (healthBarBG.w - Math.floor(healthBarBG.w * (parent.flipHealthBar ? 1 - health : health))) - (healthBarWS << 1);
		part1.x = healthBarBG.x + healthBarWS;

		if (part1.w < 0) part1.w = 0;

		uiBuf.updateElement(part1);

		var part2 = healthBarParts[1];

		if (part2 == null) return;

		var healthIconColor = healthIconColors[parent.flipHealthBar ? 0 : 1];

		//part2.c = healthIconColor[0];

		part2.w = (healthBarBG.w - part1.w) - (healthBarWS << 1);
		part2.x = (healthBarBG.x + part1.w) + healthBarWS;

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
		The pause screen.
	**/

	var pauseBG(default, null):UISprite;
	var pauseOptions(default, null):Array<UISprite> = [];

	function createPauseScreen() {
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

	function openPauseScreen() {
		uiBuf.addElement(pauseBG);

		for (i in 0...pauseOptions.length) {
			uiBuf.addElement(pauseOptions[i]);
		}
	}

	function closePauseScreen() {
		uiBuf.removeElement(pauseBG);

		for (i in 0...pauseOptions.length) {
			uiBuf.removeElement(pauseOptions[i]);
		}
	}

	function dispose() {
		countdownDisp.dispose();
		countdownDisp = null;

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