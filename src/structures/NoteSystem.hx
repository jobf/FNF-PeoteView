package structures;

/**
	The note system.
	This is an internal structure and should only be used inside of the playfield NOT to be touched with.
**/
@:publicFields
@:access(structures.PlayField)
class NoteSystem {
	static var sustainProg(default, null):Program;
	static var sustainsBuf(default, null):Buffer<Sustain>;

	static var notesProg(default, null):Program;
	static var notesBuf(default, null):Buffer<Note>;

	var notesToHit(default, null):Array<Note> = [];
	var sustainsToHold(default, null):Array<Sustain> = [];
	var botHitsToCheck(default, null):Array<Bool> = [];
	var playerHitsToCheck(default, null):Array<Bool> = []; // For preventing a key press check from continuing if you hit a note

	var spawnPosBottom(default, null):Int;
	var spawnPosTop(default, null):Int;

	var spawnDist(default, null):Int = 160000;
	var despawnDist(default, null):Int = 30000;

	inline function setScrollSpeed(value:Float) {
		spawnDist = Math.floor(160000 / value);
		despawnDist = Math.floor(40000 / Math.min(value, 1.0));
		parent.hitbox = 200 * value;
		return value;
	}

	var curTopNote(default, null):Note;
	var curBottomNote(default, null):Note;

	var parent(default, null):PlayField;

	function new(numOfReceptors:Int, parent:PlayField) {
		this.parent = parent;

		notesToHit.resize(numOfReceptors);
		sustainsToHold.resize(numOfReceptors);

		if (notesBuf == null) {
			notesBuf = new Buffer<Note>(128, 128, false);
		}

		if (notesProg == null) {
			notesProg = new Program(notesBuf);
			notesProg.blendEnabled = true;
	
			TextureSystem.setTexture(notesProg, "noteTex", "noteTex");
		}

		if (sustainsBuf == null) {
			sustainsBuf = new Buffer<Sustain>(128, 128, false);
		}

		var sustainDimensions:Array<Int> = [];

		var tex2 = TextureSystem.getTexture("sustainTex");
		sustainDimensions.push(tex2.width);
		sustainDimensions.push(tex2.height);

		if (sustainProg == null) {
			sustainProg = new Program(sustainsBuf);
			sustainProg.blendEnabled = true;

			Sustain.init(sustainProg, "sustainTex", tex2);
		}

		var display = parent.display;

		display.addProgram(sustainProg);
		display.addProgram(notesProg);

		var input = parent.inputSystem;
		var strumlineMap = input.strumline;

		for (j in 0...strumlineMap.length) {
			var map = strumlineMap[j];
			for (i in 0...map.length) {
				var strum = map[i];
				var rec = new Note(0, parent.downScroll ? Main.INITIAL_HEIGHT - 150 : 50, 0, 0);
				rec.r = strum[0];
				rec.x = Math.floor(strum[1]);
				rec.scale = strum[2];
				rec.playable = input.strumlinePlayable[j];
				notesBuf.addElement(rec);
			}
		}

		var dimensions = sustainDimensions;

		var sW = dimensions[0];
		var sH = dimensions[1];

		var notes:File = parent.chart.file;
		var i:Int64 = 0;
		var len:Int64 = notes.length;
		while (i < len)
		{
			var note = notes.getNote(i);
			var strum = parent.inputSystem.strumline[note.lane][note.index];

			var noteSpr = new Note(999999999, 0, 0, 0);
			noteSpr.data = note;
			noteSpr.toNote();
			noteSpr.r = strum[0];
			noteSpr.scale = strum[2];
			addNote(noteSpr);

			if (note.duration > 5) {
				var susSpr = new Sustain(999999999, 0, sW, sH);
				susSpr.length = ((note.duration << 2) + note.duration) - 25;
				susSpr.w = susSpr.length;
				susSpr.r = parent.downScroll ? -90 : 90;
				susSpr.scale = noteSpr.scale;
				susSpr.c.aF = Sustain.defaultAlpha;
				addSustain(susSpr);

				susSpr.parent = noteSpr;
				noteSpr.child = susSpr;
			}

			i++;
		}
	}

	function update(pos:Int64) {
		cullTop(pos);
		cullBottom(pos);
		updateNotes(pos);
	}

	function hitDetectNote(noteToHit:Note, rec:Note, index:Int) {
		if (noteToHit != null && !noteToHit.missed && noteToHit.c.aF != 0) {
			if (!rec.confirmed()) {
				rec.confirm();
				notesBuf.updateElement(rec);
			}
			noteToHit.c.aF = 0;
			sustainsToHold[index] = noteToHit.child;

			var data = noteToHit.data;
			var posWithLatency = Tools.betterInt64FromFloat((parent.songPosition + parent.latencyCompensation) * 100);
			parent.onNoteHit.dispatch(data, Int64.toInt(Int64.div(data.position - posWithLatency, 100)));
			notesToHit[index] = null;
		} else {
			if (!rec.pressed()) {
				rec.press();
				notesBuf.updateElement(rec);
			}
		}
	}

	function releaseDetectSustain(sustainToRelease:Sustain, rec:Note, index:Int) {
		if (sustainToRelease != null && (sustainToRelease.c.aF != 0 && sustainToRelease.w > 100)) {
			sustainToRelease.c.aF = Sustain.defaultMissAlpha;
			sustainToRelease.held = true;
			parent.onSustainRelease.dispatch(sustainToRelease.parent.data);
			sustainsToHold[index] = null;
			parent.hud.hideRatingPopup();
		}

		if (!rec.idle()) {
			rec.reset();
			notesBuf.updateElement(rec);
		}
	}

	inline function addNote(note:Note) {
		notesBuf.addElement(note);
	}

	inline function addSustain(sustain:Sustain) {
		sustainsBuf.addElement(sustain);
	}

	inline function getNote(id:Int) {
		return notesBuf.getElement(id + parent.numOfReceptors);
	}

	inline function getReceptor(id:Int) {
		return notesBuf.getElement(id % parent.numOfReceptors);
	}

	function resetNotes() {
		if (parent.disposed) return;

		resetReceptors();

		resetInputs();

		for (i in spawnPosBottom...spawnPosTop) {
			var note = getNote(i);
			note.x = 999999999;

			var sustain = note.child;
			if (sustain != null) {
				sustain.c.aF = 0;
				sustain.x = 999999999;
				sustain.w = sustain.length;
				sustain.held = false;
				sustainsBuf.updateElement(sustain);
			}

			note.missed = false;
			note.c.aF = 0;
			notesBuf.updateElement(note);
		}

		var file = parent.chart.file;
		var len = file.length;

		// This is the mess part and shit in which I've optimized

		var incrementAmount = 10;

		if (len > 100) {
			incrementAmount = 20;
		} else if (len > 1000) {
			incrementAmount = 200;
		} else if (len > 10000) {
			incrementAmount = 2000;
		} else if (len > 100000) {
			incrementAmount = 20000;
		} else if (len > 1000000) {
			incrementAmount = 200000;
		} else if (len > 10000000) {
			incrementAmount = 2000000;
		} else if (len > 100000000) {
			incrementAmount = 20000000;
		} else if (len > 1000000000) {
			incrementAmount = 200000000;
		}

		var decrementAmount = 2;

		if (len > 100) {
			decrementAmount = 5;
		} else if (len > 1000) {
			decrementAmount = 50;
		} else if (len > 10000) {
			decrementAmount = 500;
		} else if (len > 100000) {
			decrementAmount = 5000;
		} else if (len > 1000000) {
			decrementAmount = 50000;
		} else if (len > 10000000) {
			decrementAmount = 500000;
		} else if (len > 100000000) {
			decrementAmount = 5000000;
		} else if (len > 1000000000) {
			decrementAmount = 50000000;
		}

		if (spawnPosTop > incrementAmount) {
			while (file.getNote(Math.floor(Math.min(spawnPosTop += incrementAmount, Int64.toInt(len - 1)))).position < Tools.betterInt64FromFloat(parent.songPosition * 100) - spawnDist) {}
			while (file.getNote(Math.floor(Math.min(spawnPosTop--, Int64.toInt(len - 1)))).position > Tools.betterInt64FromFloat(parent.songPosition * 100) - spawnDist) {}
		}

		spawnPosBottom = spawnPosTop;

		if (spawnPosBottom > decrementAmount) {
			while (file.getNote(Math.floor(Math.min(spawnPosBottom -= decrementAmount, Int64.toInt(len - 1)))).position > Tools.betterInt64FromFloat(parent.songPosition * 100)) {}
			while (file.getNote(Math.floor(Math.min(spawnPosBottom++, Int64.toInt(len - 1)))).position < Tools.betterInt64FromFloat(parent.songPosition * 100)) {}
		}

		// The end (thank god)
	}

	function resetInputs() {
		notesToHit.resize(0);
		sustainsToHold.resize(0);
		playerHitsToCheck.resize(0);
		notesToHit.resize(parent.numOfReceptors);
		sustainsToHold.resize(parent.numOfReceptors);
		playerHitsToCheck.resize(parent.numOfReceptors);
	}

	function resetReceptors(resetAnims:Bool = true) {
		for (i in 0...parent.numOfReceptors) {
			var rec = getReceptor(i);
			if (!rec.idle() && resetAnims) rec.reset();
			rec.y = parent.downScroll ? Main.INITIAL_HEIGHT - 150 : 50;
			notesBuf.updateElement(rec);
		}
	}

	function cullTop(pos:Int64) {
		if (parent.disposed) return;

		curTopNote = getNote(spawnPosTop);

		while (spawnPosTop != parent.numOfNotes && (curTopNote.data.position - pos).low < spawnDist) {
			spawnPosTop++;
			curTopNote.x = 999999999;

			var sustain = curTopNote.child;

			if (sustain != null) {
				sustain.c.aF = Sustain.defaultAlpha;
				sustain.w = sustain.length;
				sustain.x = 999999999;
				sustainsBuf.updateElement(sustain);
				sustain.held = false;
			}

			curTopNote.missed = false;
			curTopNote.c.aF = 1;
			notesBuf.updateElement(curTopNote);

			curTopNote = getNote(spawnPosTop);
		}
	}

	function cullBottom(pos:Int64) {
		if (parent.disposed) return;

		curBottomNote = getNote(spawnPosBottom);

		while (spawnPosBottom != parent.numOfNotes &&
			((pos -
			(
				((curBottomNote.data.duration << 2) + curBottomNote.data.duration) * 100
			)) -
			curBottomNote.data.position).low > despawnDist) {
			spawnPosBottom++;

			curBottomNote.x = 999999999;

			var sustain = curBottomNote.child;
			var sustainExists = sustain != null;

			if (sustainExists) {
				sustain.x = 999999999;
				sustain.c.aF = Sustain.defaultAlpha;
				sustainsBuf.updateElement(sustain);
				sustain.held = false;
			}

			curBottomNote.missed = false;
			curBottomNote.c.aF = 1;
			notesBuf.updateElement(curBottomNote);

			curBottomNote = getNote(spawnPosBottom);
		}
	}

	function updateNotes(pos:Int64) {
		if (parent.disposed) return;

		for (i in spawnPosBottom...spawnPosTop) {
			updateNote(pos, getNote(i));
		}
	}

	// Do not fuck with this EVER
	function updateNote(pos:Int64, note:Note) {
		var data = note.data;
		var index = data.index;
		var lane = data.lane;
		var fullIndex = index + parent.inputSystem.strumlineIndexes[lane];
		var position = data.position;

		var rec = notesBuf.getElement(fullIndex);

		var diff = (Int64.toInt(position - pos) * 0.01) * parent.scrollSpeed;
		var leftover = Math.floor(Int64.toInt(pos - position) * 0.01);
		var isHit = note.c.aF == 0;

		note.x = rec.x;
		note.y = rec.y + (Math.floor(diff) * (parent.downScroll ? -1 : 1));

		var sustain = note.child;
		var sustainExists = sustain != null;
		var playable = rec.playable && !(parent.botplay || RenderingMode.enabled);

		if (playable) {
			if (!isHit) {
				var noteToHit = notesToHit[fullIndex];
				var noteToHitExists = noteToHit != null;
				var hitPos = noteToHitExists ? noteToHit.data.position : 0;

				if ((!note.missed && diff < parent.hitbox && !noteToHitExists) ||
					(noteToHitExists && pos - hitPos > (position - hitPos) >> 1)) {
					notesToHit[fullIndex] = note;
				}

				if (diff < -parent.hitbox && !note.missed) {
					note.c.aF = 0.5;
					note.missed = true;

					parent.onNoteMiss.dispatch(data);

					if (sustainExists && !sustain.held) {
						sustain.c.aF = Sustain.defaultMissAlpha;
						sustain.held = true;
						parent.onSustainRelease.dispatch(data);
					}

					notesToHit[fullIndex] = null;

					parent.hud.hideRatingPopup();
				}
			}
		} else {
			if (botHitsToCheck[fullIndex]) {
				if (!rec.idle()) {
					rec.reset();
					notesBuf.updateElement(rec);
					botHitsToCheck[fullIndex] = false;
				}
			}

			if (!isHit && diff < 0) {
				note.c.aF = 0;
				sustainsToHold[fullIndex] = sustain;

				if (!rec.confirmed()) {
					rec.confirm();
					notesBuf.updateElement(rec);
				}

				if (sustainExists) {
					sustain.followNote(rec);
					sustain.w = sustain.length - leftover;
					if (sustain.w < 0) sustain.w = 0;
				}

				parent.onNoteHit.dispatch(data, 0);
				botHitsToCheck[fullIndex] = !sustainExists;
			}
		}

		if (sustainExists) {
			sustain.r = parent.downScroll ? -90 : 90;
			sustain.speed = parent.scrollSpeed;

			if (!isHit) {
				sustain.followNote(note);
			} else if (sustain.c.aF != 0) {
				if (sustain.w > 0) {
					sustain.followNote(rec);
					sustain.w = sustain.length - leftover;
					if (sustain.w < 0) sustain.w = 0;
				}

				if (pos > position + (sustain.length * 100) - 75 && !sustain.held && !note.missed) {
					sustain.held = true;
					if (rec.confirmed()) {
						if (playable) rec.press();
						else rec.reset();
					}
					notesBuf.updateElement(rec);
					parent.onSustainComplete.dispatch(data);
				}
			}

			sustainsBuf.updateElement(sustain);
		}

		notesBuf.updateElement(note);
	}

	function dispose() {
		parent.display.removeProgram(notesProg);
		parent.display.removeProgram(sustainProg);

		notesBuf.clear();
		sustainsBuf.clear();
	}
}