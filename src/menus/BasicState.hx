#if !doc_gen
package menus;

import lime.ui.KeyCode;

/**
	The basic state.
**/
#if !debug
@:noDebug
#end
class BasicState extends State {
	var logo:Sprite;
	var logo2:Sprite;
	var logo3:Sprite;

	// The gameplay camera.
	var dispGP:Display;
	var prgmGP:Program;
	var buffGP:Buffer<Sprite>;

	// The interface camera.
	var dispUI:Display;
	var prgmUI:Program;
	var buffUI:Buffer<Sprite>;

	// The sound.
	var inst:Audio;

	// The conductor.
	var conductor:Conductor;

	// The bpm change stuff.
	var bpmChangePosition:Int = 0;
	var bpmChanges:Array<Array<Float>> = [
		[11162.79069767442, 344]
	];

	// The countdown event stuff.
	var countdownEventPosition:Int = 0;
	var countdownEvents:Array<Array<Float>> = [
		[4534.883720930233, 0],
		[4883.720930232559, 1],
		[5232.558139534884, 2],
		[5581.39534883721, 3],
		[11162.79069767442, 3]
	];

	// The chart.
	var chart:Chart;

	// The countdown display.
	var countdownDisp:CountdownDisplay;

	override function new() {
		super();

		buffGP = new Buffer<Sprite>(100, 100, true);
		buffUI = new Buffer<Sprite>(100, 100, true);

		prgmGP = new Program(buffGP);
		prgmUI = new Program(buffUI);

		dispGP = new Display(0, 0, Screen.view.width, Screen.view.height, 0xFF00FF7F);
		dispUI = new Display(0, 0, Screen.view.width, Screen.view.height, 0x00000000);

		Screen.view.addDisplay(dispGP);
		Screen.view.addDisplay(dispUI);

		dispGP.addProgram(prgmGP);
		dispUI.addProgram(prgmUI);

		TextureSystem.createMultiTexture("tex0", ["assets/test0.png", "assets/test1.png", "assets/test2.png", "assets/test3.png", "assets/suzanneRGBA.png"]);
		TextureSystem.setTexture(prgmGP, "tex0", "custom");
		TextureSystem.setTexture(prgmUI, "tex0", "custom");

		logo = new Sprite(50, 50);
		logo.setSizeToTexture(TextureSystem.getTexture("tex0"));
		logo.w = Math.floor(logo.w / 5);
		buffGP.addElement(logo);

		logo2 = new Sprite(200, 50);
		logo2.setSizeToTexture(TextureSystem.getTexture("tex0"));
		logo2.w = Math.floor(logo2.w / 5);
		logo2.c = 0x0000ffff;
		buffUI.addElement(logo2);

		logo3 = new Sprite(400, 150);
		logo3.c = 0x00ff00ff;
		logo3.setSizeToTexture(TextureSystem.getTexture("tex0"));
		logo3.w = Math.floor(logo3.w / 5);
		buffUI.addElement(logo3);

		chart = new Chart("assets/songs/test");

		conductor = new Conductor(chart.header.bpm);
		/*conductor.onStep.add(function(step) {
			Sys.println('Step $step');
		});*/

		conductor.onBeat.add(function(beat) {
			//Sys.println('Beat $beat');
			if (beat % 4 != 0) {
				Audio.playSound("assets/conductor/beat.wav");
			}

			if (beat < 0) {
				countdownDisp.countdownTick(Math.floor(4 + beat));
			}

			if (beat == 0) {
				inst = new Audio("assets/silver-doom.opus");
				inst.play();
			}
		});

		conductor.onMeasure.add(function(measure) {
			//Sys.println('Measure $measure');
			Audio.playSound("assets/conductor/measure.wav");
		});

		conductor.active = false;
		conductor.time = -conductor.crochet * 5;
		conductor.active = true;

		countdownDisp = new CountdownDisplay(chart, dispUI);
	}

	var time:Float = 0;
	override function update(deltaTime:Int) {
		countdownDisp.update(deltaTime);

		if (countdownEventPosition < countdownEvents.length) {
			var countdownEvent = countdownEvents[countdownEventPosition];
			if (conductor.time > countdownEvent[0]) {
				countdownDisp.countdownTick(Math.floor(countdownEvent[1]));
				++countdownEventPosition;
			}
		}

		if (bpmChangePosition < bpmChanges.length) {
			var bpmChange = bpmChanges[bpmChangePosition];
			if (conductor.time > bpmChange[0]) {
				conductor.changeBpmAt(bpmChange[0], bpmChange[1]);
				++bpmChangePosition;
			}
		}

		var musicTime:Float = 0;

		if (inst != null) {
			inst.update(deltaTime);
			musicTime = inst.time;
			conductor.time = musicTime;
		} else {
			musicTime = conductor.time += deltaTime;
		}

		countdownDisp.update(deltaTime);

		logo.r += deltaTime * 0.075;
		time += deltaTime / 500;
		logo3.x = Math.sin(time) * 300 + 300;

		logo2.x = (Math.abs(musicTime) * 1.5) % (Screen.view.width - (logo2.w / 5));

		buffGP.update();
		buffUI.update();
	}

	override function onKeyDown(keyCode, keyModifier) {
		//trace(keyCode);

		if (inst == null) {
			return;
		}

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
#end