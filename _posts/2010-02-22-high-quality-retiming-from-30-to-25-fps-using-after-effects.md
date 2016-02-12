---
layout: post
title: High quality retiming from 30 to 25 fps using After Effects
created: 1266865555
categories:
- movies
- movies
- movies
- movies
- movies
- movies
- movies
- movies
- movies
- movies
---
<p>This is a follow-up post to this <a href="/retiming-methods-shootout">general explaination of retiming methods</a>.</p>

<p>This is my favourite way to retime footage from 30 fps to 25 fps in high quality with After Effects. This method does not use any 3rd party plugins like Twixtor. Off we go:</p>

<p>Import your final film. It should have been edited at 30 (or 29.97 if you converted to cineform and maybe in some other cases too) fps. Go to the footage in the project window and choose Interpret footage. Set the frame rate to your target frame rate (in my case 25 fps).</p>

<p><img height="685" width="515" alt="" class="inline" src="/files/interpret%20footage.jpg" /></p>

<p>Create a new comp based on this footage. It should be set to 25 fps as well. If you take a look then you will see that what is happening now is that we play the footage back with a lower speed. To correct this, apply the TimeWarp effect. You could use the speed parameter, but I prefer to use to keyframe the source frame parameter. Change your project settings to display frames instead of a timecode:</p>

<p><img height="189" width="347" alt="" src="/files/display%20frames.jpg" /><br />

Note the length of your footage in frames. Now calculate the new end point: &lt;number of source frames&gt; / &lt;original framerate&gt; * &lt;target framerate&gt;. Round up if this results in a fraction instead of an integer number. Go to the frame that you calculated (which should be exactly at 5/6th of the total length of your footage/timeline). Add a keyframe for the Source Frame parameter here and set it to the last frame (the number of source frames). Go to the beginning of your comp and keyframe to source frame 0. Set the method that Timewarp uses to Frame Mix (for frame blending) or Pixel Motion (for frame generation). If you scroll through it now (can be very slow with pixel motion) you will see the retimed footage.</p>

<p><a href=")/files/timeline%20simple%20retiming.jpg"><img height="133" width="600" src="/files/timeline%20simple%20retiming.jpg" class="triggerclass" alt="" /></a></p>

<p>If you don&rsquo;t have any hard cuts, you&rsquo;re done now and can render the result. If you have hard cuts, you will want to protect them.</p>

<p>You can go to all hard cuts, keyframe it to one exact frame just before the cut and keyframe it to exactly one frame later after the cut. But this is tedious, so here is a quicker way:</p>

<p>Find all hard cuts and place layer markers there (or let the very nice Magnum script do the work for you).&nbsp; Then add this expression to the source frame parameter:</p>

```javascript
n = 0;
t = 0;
if (marker.numKeys > 0)
{
    n = marker.nearestKey(time).index;
}
if (n > 0)
{
    t = (time +thisComp.frameDuration) - marker.key(n).time;

    if (Math.abs(t) <= thisComp.frameDuration)
		Math.round(effect("Timewarp")(4))
    else
        effect("Timewarp")(4)
}
else
	effect("Timewarp")(4)
```

<p>It will keep the animated value unless there is a layer marker present at the current or the next frame in which case it will round the time to make sure that no blending across the hard cut occurs.</p>

<p><a href=")/files/timeline%20hard%20cuts%20protected.jpg"><img height="235" width="600" alt="" src="/files/timeline%20hard%20cuts%20protected.jpg" class="triggerclass" /></a></p>

<p>In a future post I will show a way to do the same thing in twixtor which handles the hard cuts differently.</p>

<p>&nbsp;</p>

<p>If you get messed up frames in between you can either switch back to frame blending for the few frames that require it or <a href="/Optimizing-Timewarp-with-Brainstorm">use brainstorm</a> to optimize the optical flow analysis parameters of Timewarp.</p>
