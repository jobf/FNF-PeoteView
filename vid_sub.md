# Introduction

Hooray, I guess. If you've seen my last couple videos, I'm basically uploading a batch of my old content (whenever it's plotagon or not) onto my youtube channel.

Also, do you remember THIS video? I have another one of those made on the exact same month and year.
However, that's not what I'm gonna talk about today. What I'm talking about, is friday night funkin' zenith.

It's officially stopping in development indefinitely in favor of a new fnf engine, made in a different game framework, which is a thin layer flixel's engine's engine's rendering engine. OpenGL.

Yeah, fuck you, my igpu actually uses it, and when I played with peote-view for the first time ever, I immediately noticed that.

I was thinking of writing a whole ass fnf engine that relies entirely on peote-view, and barely anyone in haxe actually cares about it cause the rest of the people said "fuck you" to due to its code structure and how it works.

So, I'm going to be writing friday night funkin' in peote-view.

# Segment

Peote-view in general has extreme advantages compared to flixel, and some disadvantages.

For example, peote-view is super optimized and uses only a thin layer of OpenGL, and flixel runs adsurd due to its shader fills, draw triangles implementation, and its flxbackdrop implementation.

You can actually make your own by setting the graphic variable for whenever you're on a class extending it or not, its shader, bitmap, and wrap, to repeat.

However, it's not a good idea, cause flixel's rendering architecture RELIES entirely on shaders, so you have multiple sprites with the same graphic, and the same wrap is applied for all the sprites using it.

So I decided to say "screw flixel, let's go to peote-view instead".

Peote-view relies ONLY on textures. You get free access to all low level shit you can finally do for the first time, like for example.

Clipping logic, like how the first ever sparrow atlas implementation in peote-view was made.

And there's a sample dedicated to it on jf's fork of peote-view-samples.

Next off, we have the options variable, allowing you to repeat x and or y, and allow blending.

The options variable comes from the element interface, which is rendered on by buffers.

Buffers are held on by a display, which programs get held on by.

After some time, I finally understood the codebase of peote-view. I was originally gonna make a wrapper of peote-view that allows you to code in flixel-esque code, but fuck you, no, I'm not doing that.

In the basic state, I got some sprites ready with multitexture, otherwise known as texture units due to the implementation, working too.

AND, I actually used miniaudio for the first time. But, all I did was port over the existing implementation that uses externs, from an fnf mod that barely anyone gave a shit to browse its source, to fnf on peote-view.

The FNF mod is actually "Thursday Night Throwdown". I could only play the 32 bit build, but I guess it was due to me not having OpenGL 4.3 (if I recall) or above. OpenGL is old as hell and vulkan is starting to take over.

By the way, I'm still talking about fnf on peote-view. I actually have a public source open on my github as I got started.

I mean, major updates were pushed to the code, including the chart note that abstracts over Int64, for fnf on peote-view's chart system.

I'm not even gonna bother implementing "chart streaming" (if you even know what that is) anymore, so I said "screw it", and made it so you load the whole file to memory.

Binary chart formats are already a lot smaller by leagues than a plain, simple json file. The file format for that is currently .bin.

This was already done on fnf zenith, but I'm planning to do a lot more.

I'm literally going to make custom functionality over native file's "get contents bytes" function, that allows you to basically allocate a 64 bit integer array only by calling the custom version of the function.

That's a giant difference over allocating an 8 bit integer array, or basically haxe's bytes implementation, but I'm extending the maximum possible note count in a binary chart by 8 times more.

Can you imageine if someone was able to actually create a chart with over 100 million notes? No, fuck you. I'm not even gonna start.

By the way, back to peote-view. The disadvantage of peote-view is that since it's low level and you have all that access to tiling a sustain note efficiently, you have to get involved in more.

I've made my own mistakes when implementing a state system.

And that's the part where you're like "fuck this, I'm not making a game project on this. Even though it's ultra fast, it's so complex." Like, it's low level. Of course it will be complex, but the codebase is flexible.

(Yes, peote-view's codebase is secretly flexible. Trust me.()

Another advantage of peote-view is that you can basically dodge the cpu load from using the openfl graphics api, and use raw opengl.

Peote-view is made to simplify opengl logic, and I mean it.

It's plain fun and not overwhelming when you want to make that micro-optimization tomfoolery, when in reality, for example, trying to optimize the rendering architecture of flixel won't be worth it.

I've dealt with the muliple draw calls thing, and I wanted to implement a flxatlas wrapper, but flxatlas actually isn't really all memory optimized. Don't ever use it. I'd recommend switching to starling or peote-view.

I chose to use peote-view because the codebase is more flexible as opposed to starling's.

The last advantage of peote-view is that it can be easily maintained and finished, whenever it's using displays as flxcameras but actually efficient. (Ahh~ in flixel, they're rendered in a cocked-up openfl sprite.)

That's all for peote-view. Enjoy using peote-view. Love peote-view. Get other people to use peote-view for their game projects. Peote-view is like performance crack holding on perfectly.

Let's now get to the current development stage of fnf on peote-view, or otherwise known as...

Funkin' View. I have never made a logo for that yet, but I've only made one logo for fnf zenith, made in paint 3d.

FNF Zenith had good progress, having an almost-complete title screen, an unfinished title substate, known as the selection screen, and the barebones main menu. I never worked on the options for that.

And that's when I went back to doing gameplay optimizations. I reworked its note system thrice.

I've made tons of videos of fnf zenith's development stage, and even implemented hscript, which I used for extra keys which had over 200 views for that video, etc.

2 months go by, and I don't feel like doing it anymore, and I basically want to switch to peote-view. Oh, and by the way, you can still fork the project that will never be finished officially.

You can get creative and start working on fnf zenith, but it's codebase is ass, and good luck dealing with it. You can name it your own take of fnf zenith.

Now, let's go to Funkin' View.

I actually implemented audio for it, and even ported over the conductor from fnf zenith, to Funkin' View. However, everything except the time signature changing math is done.

If you're wondering what miniaudio is, it's a single c file. I wonder how people go through all that code. Those people are insane.

And the actual audio time has a granularity of 10 milliseconds, so I'm looking forward to implementing a sample-accurate version of getting the audio time. That's a todo with medium priority.

The project right now contains 3 sprites, with one of them on the back camera, with a multitexture.

While at the same time, the audio, conductor, and chart note is in it.

Yes, the chart note implementation was the hardest. Chris had to help me fix the whole thing and rewrite it with a very odd bit combining route.

I decided to actually use it for the basic state if you didn't know. Also, adding onto that, the first ever sparrow atlas implementation in peote-view is being worked on by jf, or otherwise known as halfwat.

If you don't know who semmi is, he's wild sometimes. And, he's an actual programmer. Hooray! He made a buncha shit like littleBigInt, formula, format, input2action, and of course peote libs.

I use peote-view because I'm writing an fnf engine entirely in pure lime. Not pure openfl, not starling, just lime.

Do I sound insane saying this? Kinda.

My future plans for Funkin' View are, to handle displays like flxcameras, write a note system, and implement an actual pause menu.

The pause menu will be the extra display on top of every other.

I tried implementing a pause menu on fnf zenith though. I didn't.

Funkin' View is aiming to become the new standard of fnf modding, Funkin' View will have a univeral chart converter, since the binary chart format has an insanely precise position, for an integer.

I was working on the chart converter for fnf zenith, but I ended up scrapping it, but this time, the universal chart converter will be capable of every single common fnf chart format available.

However, it's medium priority, and it's stuff I'll do after I finish the chart system.

Funkin' View is aiming to run at over a thousand frames per second for fancy ass dedicated gpu's, and lastly, Funkin' View is ultra memory efficient.

# Conclusion

So, that's it for this video. I'll see ya in a moment.