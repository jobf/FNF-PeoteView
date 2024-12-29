package structures;

/**
	The auditory system for the playfield.
**/
@:publicFields
@:access(structures.PlayField)
class AudioSystem {
	var inst:Sound;
	var voices:Array<Sound> = [];
	var grp:SoundGroup;

	function new(chart:Chart) {
		grp = new SoundGroup();
		grp.play();

		inst = new Sound();
		inst.fromFile(chart.header.instDir, grp);

		for (voicesDir in chart.header.voicesDirs) {
			var voicesInstance = new Sound();
			voicesInstance.fromFile(voicesDir, grp);
			voices.push(voicesInstance);
		}
	}

	function play() {
		inst.play();

		for (voicesTrack in voices) {
			voicesTrack.play();
		}
	}

	function stop() {
		inst.stop();

		for (voicesTrack in voices) {
			voicesTrack.stop();
		}
	}

	function update(playField:PlayField, deltaTime:Float) {
		if ((inst.finished || (RenderingMode.enabled && playField.songPosition > inst.length)) && !playField.songEnded) {
			playField.onStopSong.dispatch(playField.chart);
		}

		if (!playField.songStarted || playField.songEnded || RenderingMode.enabled) {
			playField.songPosition += deltaTime;
		} else {
			inst.update();
			playField.songPosition = inst.time;
			trace(inst.time);
		}
	}

	function setTime(time:Float) {
		inst.time = time;

		for (voicesTrack in voices) {
			voicesTrack.time = time;
		}
	}

	function dispose() {
		grp.dispose();
		grp = null;
		inst.dispose();
		inst = null;
		for (voicesTrack in voices) {
			voicesTrack.dispose();
		}
		voices.resize(0);
		voices = null;
	}
}