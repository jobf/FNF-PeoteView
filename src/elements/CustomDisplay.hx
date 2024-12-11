package  elements;

import lime.app.Application;

@:publicFields
class CustomDisplay extends Display {
	var __fbBuffer:Buffer<Sprite>;
	var __fbProgram:Program;
	var __fbDisplay:Display;
	var __fbScreen:Sprite;

	var __fbTexture:Texture;

	function init(pv:PeoteView) {
		hide();

		__fbTexture = new Texture(pv.width, pv.height);

		__fbDisplay = new Display(x, y, width, height, color);

		pv.addDisplay(this);
		pv.addDisplay(__fbDisplay);

		__fbBuffer = new Buffer<Sprite>(1);
		__fbProgram = new Program(__fbBuffer);

		__fbProgram.blendEnabled = true;
		__fbProgram.setTexture(__fbTexture, "SCREEN", true);

		__fbDisplay.addProgram(__fbProgram);

		__fbScreen = new Sprite();
		__fbScreen.w = pv.width;
		__fbScreen.h = pv.height;
		__fbScreen.r = 2;
		__fbBuffer.addElement(__fbScreen);
	}

	function updateFrameBuffer() {
		__fbBuffer.update();
	}
}