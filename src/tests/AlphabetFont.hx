#if !doc_gen
package tests;

import lime.ui.KeyCode;

/**
	The alphabet font test state.
**/
#if !debug
@:noDebug
#end
class AlphabetFont extends State {
    var alphabetTxt:Alphabet;
    var alphabetCam:Camera;

    override function new() {
        super();

        alphabetCam = new Camera(0, 0, Screen.view.width, Screen.view.height, 0x0000FF00);
        alphabetTxt = new Alphabet("This is a test", 300, 300);
        alphabetCam.add(alphabetTxt);
    }

    override function update(deltaTime:Int) {
        alphabetCam.update(alphabetTxt);
    }
}
#end