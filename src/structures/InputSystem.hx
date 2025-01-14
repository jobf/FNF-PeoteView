package structures;

import lime.ui.KeyCode;
import lime.ui.KeyModifier;

/**
	The input for the playfield.
**/
@:publicFields
class InputSystem {
	var keybindMaps:Array<Map<KeyCode, Array<Int>>> = [
		// 1 KEY
		[KeyCode.SPACE => [0, 1]],
		// 2 KEY
		[KeyCode.A => [0, 1], KeyCode.D => [1, 1],
		KeyCode.LEFT => [0, 1], KeyCode.RIGHT => [1, 1]],
		// 3 KEY
		[KeyCode.A => [0, 1], KeyCode.SPACE => [1, 1], KeyCode.D => [2, 1],
		KeyCode.LEFT => [0, 1], KeyCode.RIGHT => [2, 1]],
		// 4 KEY
		[KeyCode.A => [0, 1], KeyCode.S => [1, 1], KeyCode.W => [2, 1], KeyCode.D => [3, 1],
		KeyCode.LEFT => [0, 1], KeyCode.DOWN => [1, 1], KeyCode.UP => [2, 1], KeyCode.RIGHT => [3, 1]],
		// 5 KEY
		[KeyCode.A => [0, 1], KeyCode.S => [1, 1], KeyCode.SPACE => [2, 1], KeyCode.W => [3, 1], KeyCode.D => [4, 1],
		KeyCode.LEFT => [0, 1], KeyCode.DOWN => [1, 1], KeyCode.UP => [3, 1], KeyCode.RIGHT => [4, 1]],
		// 6 KEY
		[KeyCode.S => [0, 1], KeyCode.D => [1, 1], KeyCode.F => [2, 1],
		KeyCode.J => [3, 1], KeyCode.K => [4, 1], KeyCode.L => [5, 1]],
		// 7 KEY
		[KeyCode.S => [0, 1], KeyCode.D => [1, 1], KeyCode.F => [2, 1], KeyCode.SPACE => [3, 1],
		KeyCode.J => [4, 1], KeyCode.K => [5, 1], KeyCode.L => [6, 1]],
		// 8 KEY
		[KeyCode.A => [0, 1], KeyCode.S => [1, 1], KeyCode.D => [2, 1], KeyCode.F => [3, 1],
		KeyCode.H => [4, 1], KeyCode.J => [5, 1], KeyCode.K => [6, 1], KeyCode.L => [7, 1]],
		// 9 KEY
		[KeyCode.A => [0, 1], KeyCode.S => [1, 1], KeyCode.D => [2, 1], KeyCode.F => [3, 1], KeyCode.SPACE => [4, 1],
		KeyCode.H => [5, 1], KeyCode.J => [6, 1], KeyCode.K => [7, 1], KeyCode.L => [8, 1]]
	];

	var map:Map<KeyCode, Array<Int>>;
	var strumlineRotation:Array<Int>;
	var strumline:Array<Array<Array<Float>>>;
	var strumlinePlayable:Array<Bool>;
	var strumlineIndexes:Array<Int> = [];

	var parent:PlayField;

	function new(mania:Int, parent:PlayField) {
		this.parent = parent;

		map = keybindMaps[mania > 9 ? 8 : mania <= 1 ? 0 : mania - 1];

		// This shit is fucking unbearable as FUCK
		// It's why it's in its own class
		switch (mania) {
			case 1:
				strumlineRotation = [90];

				strumline = [[[90, 50, 1.05]], [[90, 678, 1.05]]];

			case 2:
				strumlineRotation = [0, 180];

				strumline = [
					[for (i in 0...2) [strumlineRotation[i], 50 + (111 * i), 1.0]],
					[for (i in 0...2) [strumlineRotation[i], 678 + (111 * i), 1.0]]
				];

			case 3:
				strumlineRotation = [0, 90, 180];

				strumline = [
					[for (i in 0...3) [strumlineRotation[i], 50 + (104 * i), 0.95]],
					[for (i in 0...3) [strumlineRotation[i], 678 + (104 * i), 0.95]]
				];

			case 5:
				strumlineRotation = [0, -90, 90, 90, 180];

				strumline = [
					[for (i in 0...5) [strumlineRotation[i], 50 + (97 * i), 0.9]],
					[for (i in 0...5) [strumlineRotation[i], 678 + (97 * i), 0.9]]
				];

			case 6:
				strumlineRotation = [0, -90, 180, 0, 90, 180];

				strumline = [
					[for (i in 0...6) [strumlineRotation[i], 50 + (83 * i), 0.83]],
					[for (i in 0...6) [strumlineRotation[i], 676 + (83 * i), 0.83]]
				];

			case 7:
				strumlineRotation = [0, -90, 180, 90, 0, 90, 180];

				strumline = [
					[for (i in 0...7) [strumlineRotation[i], 50 + (75 * i), 0.77]],
					[for (i in 0...7) [strumlineRotation[i], 668 + (75 * i), 0.77]]
				];

			case 8:
				strumlineRotation = [0, -90, 90, 180, 0, -90, 90, 180];

				strumline = [
					[for (i in 0...8) [strumlineRotation[i], 50 + (70 * i), 0.68]],
					[for (i in 0...8) [strumlineRotation[i], 663 + (70 * i), 0.68]]
				];

			case 9:
				strumlineRotation = [0, -90, 90, 180, 90, 0, -90, 90, 180];

				strumline = [
					[for (i in 0...9) [strumlineRotation[i], 50 + (56 * i), 0.64]],
					[for (i in 0...9) [strumlineRotation[i], 655 + (56 * i), 0.64]]
				];

			case 10:
				strumlineRotation = [0, -90, 90, 180, -90, 90, 0, -90, 90, 180];

				strumline = [
					[for (i in 0...10) [strumlineRotation[i], 47 + (53 * i), 0.59]],
					[for (i in 0...10) [strumlineRotation[i], 645 + (53 * i), 0.59]]
				];

			case 11:
				strumlineRotation = [0, -90, 90, 180, 0, 90, 180, 0, -90, 90, 180];

				strumline = [
					[for (i in 0...11) [strumlineRotation[i], 44 + (50 * i), 0.57]],
					[for (i in 0...11) [strumlineRotation[i], 639 + (50 * i), 0.57]]
				];

			case 12:
				strumlineRotation = [0, -90, 90, 180, 0, -90, 90, 180, 0, -90, 90, 180];

				strumline = [
					[for (i in 0...12) [strumlineRotation[i], 40 + (47 * i), 0.4777]],
					[for (i in 0...12) [strumlineRotation[i], 631 + (47 * i), 0.4777]]
				];

			case 13:
				strumlineRotation = [0, -90, 90, 180, 0, -90, 90, 90, 180, 0, -90, 90, 180];

				strumline = [
					[for (i in 0...13) [strumlineRotation[i], 38 + (42 * i), 0.432]],
					[for (i in 0...13) [strumlineRotation[i], 628 + (42 * i), 0.432]]
				];

			case 14:
				strumlineRotation = [0, -90, 90, 180, 0, -90, 180, 0, 90, 180, 0, -90, 90, 180];

				strumline = [
					[for (i in 0...14) [strumlineRotation[i], 36 + (41 * i), 0.42]],
					[for (i in 0...14) [strumlineRotation[i], 627 + (41 * i), 0.42]]
				];

			case 15:
				strumlineRotation = [0, -90, 90, 180, 0, -90, 180, 90, 0, 90, 180, 0, -90, 90, 180];

				strumline = [
					[for (i in 0...15) [strumlineRotation[i], 34 + (39 * i), 0.405]],
					[for (i in 0...15) [strumlineRotation[i], 626 + (39 * i), 0.405]]
				];

			case 16:
				strumlineRotation = [0, -90, 90, 180, 0, -90, 180, -90, 90, 0, 90, 180, 0, -90, 90, 180];

				strumline = [
					[for (i in 0...16) [strumlineRotation[i], 30 + (37 * i), 0.375]],
					[for (i in 0...16) [strumlineRotation[i], 626 + (37 * i), 0.375]]
				];

			default:
				strumlineRotation = [0, -90, 90, 180];

				strumline = [
					[for (i in 0...4) [strumlineRotation[i], 50 + (112 * i), 1]],
					[for (i in 0...4) [strumlineRotation[i], 680 + (112 * i), 1]]
				];

		}

		if (strumline.length > 4) strumline.resize(4);

		strumlinePlayable = [false, true];

		for (i in 0...strumline.length) {
			parent.numOfReceptors += strumline[i].length;
			if (i != 0) strumlineIndexes.push(strumline[i-1].length);
			else strumlineIndexes.push(0);
		}

		var window = lime.app.Application.current.window;
		window.onKeyDown.add(press);
		window.onKeyUp.add(release);
	}

	inline function exists(keyCode:Int) {
		return untyped map.exists(keyCode);
	}

	inline function get(keyCode:Int) {
		return untyped map.get(keyCode);
	}

	function press(code:KeyCode, mod:KeyModifier) {
		if (code == KeyCode.RETURN && !parent.paused) parent.pause();

		if (parent.disposed || parent.botplay || RenderingMode.enabled || parent.paused) return;

		if (!exists(code)) {
			return;
		}

		var map = get(code);
		var lane = map[1];
		var index = map[0] + strumlineIndexes[lane];

		var noteSystem = parent.noteSystem;

		if (noteSystem.playerHitsToCheck[index]) {
			return;
		}

		var rec = noteSystem.getReceptor(index);

		if (!rec.playable) {
			return;
		}

		noteSystem.playerHitsToCheck[index] = true;

		var noteToHit = noteSystem.notesToHit[index];
		noteSystem.hitDetectNote(noteToHit, rec, index);

		parent.onKeyPress.dispatch(code);
	}

	function release(code:KeyCode, mod:KeyModifier) {
		if (parent.disposed || parent.botplay || RenderingMode.enabled || parent.paused) return;

		if (!exists(code)) {
			return;
		}

		var map = get(code);
		var lane = map[1];
		var index = map[0] + strumlineIndexes[lane];

		var noteSystem = parent.noteSystem;

		noteSystem.playerHitsToCheck[index] = false;

		var rec = noteSystem.getReceptor(index);

		if (!rec.playable) {
			return;
		}

		var sustainToRelease = noteSystem.sustainsToHold[index];
		noteSystem.releaseDetectSustain(sustainToRelease, rec, index);

		parent.onKeyRelease.dispatch(code);
	}

	function dispose() {
		var window = lime.app.Application.current.window;
		window.onKeyDown.remove(press);
		window.onKeyUp.remove(release);
	}
}