package tests;

import lime.ui.KeyCode;

/**
	The playfield made specifically for the gameplay state.
**/
#if !debug
@:noDebug
#end
@:publicFields
class Playfield {
    var receptors:Array<ReceptorAndSteps>;
    var binds:Array<Array<KeyCode>>;
    var angles:Array<Float>;
    private var camToControl:Camera;
    var step:Step;

    function new(cam:Camera) {
        camToControl = cam;

        receptors = [];
        binds = [[A, LEFT], [S, DOWN], [W, UP], [D, RIGHT]];
        angles = [0, -90, 90, 180];

        for (i in 0...4) {
            var receptor = new ReceptorAndSteps(112 * i, 50, binds[i]);
            receptor.w = receptor.h = 110;
            receptor.r = angles[i];
            receptor.z = 1;
            receptor.cam = camToControl;
            receptors.push(receptor);
            camToControl.add(receptor);
        }

        step = new Step();
        receptors[0].addStep(step);
    }

    var time:Float = 0;
    function update(deltaTime:Int) {
        time += deltaTime * 0.002;

        for (i in 0...receptors.length) {
            var receptor = receptors[i];
            receptor.x = (112 * i) + (Math.sin(time) * 200 + 400);
            receptor.updateSteps(time / 0.002);
        }
    }
}