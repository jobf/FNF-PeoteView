package tests;

import lime.ui.KeyCode;

/**
	Control how steps and sustains move to the receptor in an unordered manner.
**/
#if !debug
@:noDebug
#end
@:publicFields
class ReceptorAndSteps extends Receptor {
    var steps(default, null):Buffer<Step>;
    var prog(default, null):Program;

	/**
		Constructs the receptor.
		@param x The sprite's x.
		@param y The sprite's y.
		@param binds The keybind list that the receptor is allowed to press.
		@param skin What the receptor should look like.
		@param z The sprite's z index.
	**/
	override function new(x:Float = 0, y:Float = 0, binds:Array<KeyCode> = null, skin:String = "normal", z:Int = 0) {
        super(x, y, binds, skin, z);

        steps = new Buffer<Step>(1024, 512, true);
        prog = new Program(steps);
    }

    function finishInit() {
        cam.addProgram(prog);
    }

    function addStep(step:Step) {
        steps.addElement(step);
    }

    function updateSteps(pos:Float) {
        cam.update(this);

        var stepElems = @:privateAccess steps._elements;
        for (i in 0...stepElems.length) {
            var step:Step = stepElems.get(i);
            step.x = this.x;
            step.y = this.y + pos;
            cam.update(step);
        }
    }
}