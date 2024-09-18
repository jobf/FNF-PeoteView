package music;

import lime.app.Event;
import haxe.Int64;

/**
	The conductor.
	Steps, beats, and measures use floats because this class was carried over from fnf zenith's.
**/
@:publicFields
class Conductor
{
	/**
		The conductor's step event.
	**/
	var onStep:Event<Float->Void> = new Event<Float->Void>();

	/**
		The conductor's beat event.
	**/
	var onBeat:Event<Float->Void> = new Event<Float->Void>();

	/**
		The conductor's measure event.
	**/
	var onMeasure:Event<Float->Void> = new Event<Float->Void>();

	/**
		The conductor's crochet.
	**/
	var crochet(default, null):Float;

	/**
		The conductor's step crochet.
	**/
	var stepCrochet(default, null):Float;

	/**
		The conductor's last beats per minute.
	**/
	var lastBpm(default, null):Float = 100;

	/**
		The conductor's beats per minute.
	**/
	var bpm(default, set):Float = 100;

	/**
		Change the conductor's beats per minute.
	**/
	inline function changeBpmAt(position:Float, newBpm:Float):Void
	{
		offsetStep += (position - offsetTime) / stepCrochet;
		offsetTime = position;
		bpm = newBpm;
	}

	/**
		Set the conductor's beats per minute.
	**/
	inline function set_bpm(value:Float):Float
	{
		lastBpm = bpm;
		bpm = value;

		stepCrochet = 15000.0 / bpm;
		crochet = stepCrochet * steps;

		return value;
	}

	/**
		The conductor's time.
	**/
	var time(default, set):Float = 0;

	/**
		Set the conductor's time.
	**/
	function set_time(value:Float):Float
	{
		time = value;

		_stepTracker = Math.ffloor(_rawStep);
		_beatTracker = Math.ffloor(_stepTracker / steps);
		_measureTracker = Math.ffloor(_beatTracker / beats);

		if (_stepPos != _stepTracker)
		{
			var leftover:Float = _stepTracker - _stepPos;

			/**
				This is here just in case you miss a couple steps.
			**/
			if (leftover > 1) {
				var leftoverCounter:Float = 0;
				while (++leftoverCounter < leftover) {
					onStep.dispatch(_stepPos + leftoverCounter);
				}
			}

			_stepPos = _stepTracker;

			onStep.dispatch(_stepPos);
		}

		if (_beatPos != _beatTracker)
		{
			var leftover:Float = _beatTracker - _beatPos;

			/**
				This is here just in case you miss a couple beats.
			**/
			if (leftover > 1) {
				var leftoverCounter:Float = 0;
				while (++leftoverCounter < leftover) {
					onBeat.dispatch(_beatPos + leftoverCounter);
				}
			}

			_beatPos = _beatTracker;

			onBeat.dispatch(_beatPos);
		}

		if (_measurePos != _measureTracker)
		{
			var leftover:Float = _measureTracker - _measurePos;

			/**
				This is here just in case you miss a couple measures.
			**/
			if (leftover > 1) {
				var leftoverCounter:Float = 0;
				while (++leftoverCounter < leftover) {
					onMeasure.dispatch(_measurePos + leftoverCounter);
				}
			}

			_measurePos = _measureTracker;

			onMeasure.dispatch(_measurePos);
		}

		return value;
	}

	/**
		The raw step counter.
	**/
	private var _rawStep(get, default):Float = 0;

	/**
		Get the raw step counter.
		@return Float
	**/
	inline private function get__rawStep():Float
	{
		return ((time - offsetTime) / stepCrochet) + offsetStep;
	}

	/**
		The steps.
	**/
	private var _stepPos(default, null):Float = 0;

	/**
		The beats.
	**/
	private var _beatPos(default, null):Float = 0;

	/**
		The measures.
	**/
	private var _measurePos(default, null):Float = 0;

	/**
		The step tracker.
	**/
	private var _stepTracker(default, null):Float = 0;

	/**
		The beat tracker.
	**/
	private var _beatTracker(default, null):Float = 0;

	/**
		The measure tracker.
	**/
	private var _measureTracker(default, null):Float = 0;

	/**
		The time offset.
	**/
	private var offsetTime(default, null):Float = 0;

	/**
		The step offset.
	**/
	private var offsetStep(default, null):Float = 0;

	/**
		The time signature steps.
	**/
	var steps(default, set):Int = 4;

	/**
		Get the time signature steps.
		@return Int
	**/
	inline function set_steps(value:Int):Int
	{
		return steps = value;
	}

	/**
		The time signature beats.
	**/
	var beats(default, set):Int = 4;

	/**
		Get the time signature beats.
		@return Int
	**/
	inline function set_beats(value:Int):Int
	{
		return beats = value;
	}

	/**
		Change the conductor's time signature.
	**/
	inline function changeTimeSigAt(position:Float, newSteps:Int = 4, newBeats:Int = 4):Void
	{
		crochet = stepCrochet * newSteps;
		steps = newSteps;
		beats = newBeats;
	}

	/**
		Reset the conductor.
	**/
	inline function reset():Void
	{
		offsetStep = offsetTime = time = 0.0;
		changeTimeSigAt(0);

	}

	/**
		Constructs a conductor.
	**/
	function new(initialBpm:Float = 100):Void
	{
		bpm = initialBpm;
	}
}