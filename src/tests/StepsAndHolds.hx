package tests;

import lime.ui.KeyCode;

/**
	The receptor functionality test state.
**/
#if !debug
@:noDebug
#end
class StepsAndHolds extends State {
    var receptors:Array<Receptor>;
    var binds:Array<Array<KeyCode>>;
    var angles:Array<Float>;
    var recCam:Camera;

    override function new() {
        super();

        receptors = [];
        binds = [[A, LEFT], [S, DOWN], [W, UP], [D, RIGHT]];
        angles = [0, -90, 90, 180];

        recCam = new Camera(0, 0, Screen.view.width, Screen.view.height);

        for (i in 0...4) {
            var receptor = new Receptor(true, 112 * i, 50);
            receptor.w = receptor.h = 110;
            receptor.binds = binds[i];
            receptor.r = angles[i];
            receptor.z = 1;
            receptors.push(receptor);
            recCam.add(receptor);
        }
    }

    var time:Float = 0;
    override function update(deltaTime:Int) {
        time += deltaTime * 0.002;

        for (i in 0...receptors.length) {
            var receptor = receptors[i];
            receptor.x = (112 * i) + (Math.sin(time) * 200 + 400);
            recCam.update(receptor);
        }
    }
}