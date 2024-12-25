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

        inst = new Sound();
		inst.fromFile(chart.header.instDir, grp);

		for (voicesDir in chart.header.voicesDirs) {
			var voicesInstance = new Sound();
			voicesInstance.fromFile(voicesDir, grp);
            voices.push(voicesInstance);
		}
    }

    function play() {
        grp.play();
    }

    function stop() {
        grp.stop();
    }

    function update(playField:PlayField, deltaTime:Float) {
        if (playField.songPosition > inst.length && !playField.songEnded) {
			playField.onStopSong.dispatch(playField.chart);
		}

		if (!playField.songStarted || playField.songEnded || RenderingMode.enabled) {
			playField.songPosition += deltaTime;
		} else {
			inst.update();
			playField.songPosition = inst.time;
		}
    }

    function setTime(timeInSec:Float) {
        var time:cpp.Int64 = Tools.betterInt64FromFloat(timeInSec * 1000);
		Miniaudio.ma_sound_group_set_start_time_in_milliseconds(grp.grp, untyped time);
    }

    function dispose() {
        grp.dispose();
        inst = null;
        voices.resize(0);
        voices = null;
    }
}