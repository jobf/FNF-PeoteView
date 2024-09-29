package tests;

import lime.ui.KeyCode;

/**
	The receptor functionality test state.
**/
#if !debug
@:noDebug
#end
@:publicFields
class StepsAndHolds extends State {
    var cam:Camera;
    var pf:Playfield;

    override function new() {
        super();

        cam = new Camera(0, 0, Screen.view.width, Screen.view.height);
        pf = new Playfield(cam);
    }

    override function update(deltaTime:Int) {
        pf.update(deltaTime);
    }
}