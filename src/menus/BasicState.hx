package menus;

import lime.ui.KeyCode;

/**
 * The basic state.
 */
#if !debug
@:noDebug
#end
class BasicState extends State {
	var logo:Sprite;
	var logo2:Sprite;
	var logo3:Sprite;

	/**
	 * The gameplay camera.
	 */
	var dispGP:Display;
	var prgmGP:Program;
	var buffGP:Buffer<Sprite>;

	/**
	 * The interface camera.
	 */
	var dispUI:Display;
	var prgmUI:Program;
	var buffUI:Buffer<Sprite>;

	/**
	 * The sounds.
	 */
	var inst:Audio;

	/**
	 * The conductor.
	 */
	var conductor:Conductor;

	/**
	 * The bpm changes.
	 */
	var bpmChangePosition:Int = 0;
	var bpmChanges:Array<Array<Float>> = [
		//[9846.153846153846, 1560]
	];

	/**
	 * The chart.
	 */
	var chart:Chart;

	/**
	 * The chart note.
	 */
	var chartNote:ChartNote;

	override function new() {
		super();

		buffGP = new Buffer<Sprite>(100, 100, true);
		buffUI = new Buffer<Sprite>(100, 100, true);

		prgmGP = new Program(buffGP);
		prgmUI = new Program(buffUI);

		dispGP = new Display(0, 0, Screen.view.width, Screen.view.height, 0xFF000044);
		dispUI = new Display(0, 0, Screen.view.width, Screen.view.height, 0x0FF00F44);

		Screen.view.addDisplay(dispGP);
		Screen.view.addDisplay(dispUI);

		dispGP.addProgram(prgmGP);
		dispUI.addProgram(prgmUI);

		TextureSystem.createMultiTexture("tex0", ["assets/test0.png", "assets/test1.png", "assets/test2.png", "assets/test3.png", "assets/suzanneRGBA.png"]);
		TextureSystem.setTexture(prgmGP, "tex0", "custom");

		logo = new Sprite(50, 50);
		logo.w = 400;
		logo.h = 300;
		buffGP.addElement(logo);

		logo2 = new Sprite(200, 50);
		logo2.c = 0x0000ffff;
		buffUI.addElement(logo2);

		logo3 = new Sprite(400, 150);
		logo3.c = 0x00ff00ff;
		logo3.w = 150;
		logo3.h = 160;
		buffUI.addElement(logo3);

		inst = new Audio("assets/silver-doom.opus");

		conductor = new Conductor(172);
		/*conductor.onStep.add(function(step) {
			Sys.println('Step $step');
		});*/
		conductor.onBeat.add(function(beat) {
			//Sys.println('Beat $beat');
			if (beat % 4 != 0) {
				Audio.playSound("assets/conductor/beat.wav");
			}
		});
		conductor.onMeasure.add(function(measure) {
			//Sys.println('Measure $measure');
			Audio.playSound("assets/conductor/measure.wav");
		});

		chart = new Chart("assets/songs/test");

		chartNote = new ChartNote(haxe.Int64.parseString("2199023255551"), 2681, 15, 14, 3);
		trace('Position: ' + chartNote.position);
		trace('Duration: ' + chartNote.duration);
		trace('Index: ' + chartNote.index);
		trace('Type: ' + chartNote.type);
		trace('Lane: ' + chartNote.lane);
	}

	var time:Float = 0;
	override function updateState(deltaTime:Int) {
		inst.update(deltaTime);
		//Sys.println(inst.time);

		logo.r += deltaTime * 0.075;
		time += deltaTime / 500;
		logo3.x = Math.sin(time) * 300 + 300;

		logo2.x = (inst.time * 1.5) % (1280 - logo2.w);

		buffGP.update();
		buffUI.update();

		conductor.time = inst.time;

		/**
		 * This bpm change logic does not preserve position to go back to the previous bpm.
		 */
		if (bpmChangePosition < bpmChanges.length) {
			var bpmChange = bpmChanges[bpmChangePosition];
			if (conductor.time > bpmChange[0]) {
				conductor.changeBpmAt(bpmChange[0], bpmChange[1]);
				++bpmChangePosition;
			}
		}
	}

	override function onKeyDown(keyCode, keyModifier) {
		//trace(keyCode);

		switch (keyCode) {
			case RETURN:
				inst.play();

			case SPACE:
				inst.pause();

			case M:
				inst.volume = inst.volume == 0.1 ? 1 : 0.1;

			case B:
				inst.time = 1000000;

			case A:
				inst.time -= 1000;

			case D:
				inst.time += 1000;

			case BACKSPACE:
				inst.stop();

			case NUMBER_1:
				logo.slot++;

			case NUMBER_2:
				logo2.slot++;

			case NUMBER_3:
				logo3.slot++;

			default:
		}
	}
}