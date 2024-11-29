package menus;

/**
	The pause screen.
    This submenu is meant to be layered on top of every other menu.
**/
@:publicFields
class PauseScreen {
    var display:Display;

    var optionsBuf:Buffer<Sprite>;
    var optionsProg:Program;

    function new(chart:Chart, display:Display) {
        display.color = 0x0000007F;
        this.display = display;

        optionsBuf = new Buffer<Sprite>(3, 0, false);
		optionsProg = new Program(optionsBuf);
		optionsProg.blendEnabled = true;

		TextureSystem.setTexture(optionsProg, "noteTex", "noteTex");

        var resume
    }

    function open() {
        display.show();
    }

    function close() {
        display.hide();
    }
}