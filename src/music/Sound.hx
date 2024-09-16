package music;

/**
 * The sound.
 * This is used for short sounds, and this abstracts over the internal audio class.
 */
@:publicFields
class Sound {
    /**
     * The sound's audio source.
     */
    private var audio(default, null):Audio;

    /**
     * Constructs a sound.
     * @param path 
     */
    inline function new(path:String) {
        audio = new Audio(path);
    }

    /**
     * Play the sound.
     */
    function play() {
        if (audio.time != 0) {
            audio.time = 0;
        }

        audio.play();
    }

    /**
     * Dispose the sound.
     */
    function dispose() {
        if (audio != null) {
            audio.dispose();
            audio = null;
        }
    }
}