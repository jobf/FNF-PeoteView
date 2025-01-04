package structures;

/**
	The auditory system for the playfield.
	This is an internal structure and should only be used inside of the playfield NOT to be touched with.
**/
@:publicFields
@:access(structures.PlayField)
class AudioSystem
{
	var inst : Sound;
	var voices : Array<Sound> = [];
	var grp : SoundGroup;

	function new(chart:Chart)
	{
		grp = new SoundGroup();

		inst = new Sound();
		inst.fromFile(chart.header.instDir, grp);

		for (voicesDir in chart.header.voicesDirs)
		{
			var voicesInstance = new Sound();
			voicesInstance.fromFile(voicesDir, grp);
			voices.push(voicesInstance);
		}
	}

	function play()
	{
		grp.play();
	}

	function stop()
	{
		grp.stop();
	}

	function update(playField:PlayField, deltaTime:Float)
	{
		if ((inst.finished || (RenderingMode.enabled && playField.songPosition > inst.length)) && !playField.songEnded) {
			playField.onStopSong.dispatch(playField.chart);
		}

		if (!playField.songStarted || playField.songEnded || RenderingMode.enabled)
		{
			playField.songPosition += deltaTime;
		}
		else
		{
			inst.update();
			playField.songPosition = inst.time;
		}
	}

	function setTime(time:Float)
	{
		grp.time = time;
	}

	function dispose()
	{
		grp.dispose();
		grp = null;

		inst.dispose();
		inst = null;

		while (voices.length != 0)
		{
			voices.pop().dispose();
		}
		voices = null;
	}
}