---
layout: post
title: EDL Splitter - a script to ease our colour correction workflow
created: 1194385171
categories:
- movies
- movies
---
<p>As some of the people who read this blog may know, I study directing at the filmschool <a title="filmarche filmschool" href="http://www.filmarche.de">filmArche</a> in Berlin. Over the last year I have been asked to colour correct a number of movies since this is one of my favourite steps in filmmaking and I think I have become quite decent at it by now. I love to see my fellow filmmakers faces when I show them how much a shot can be enhanced / altered with subtle changes to the colour of the film.</p>

<p>But the workflow for high quality colour correction is in many cases pretty poor, especially at our school were almost everyone edits on a different system &amp; editing software - some use avid, some final cut pro, and then there is the odd vegas or premiere user in between. I recently described our various setups and the solutions that are available today for solving this in a post to the rebel cafe: <a title="my post" href="http://rebelsguide.com/forum/viewtopic.php?p=5151#5151">my post </a>(the rebel cafe is a forum website for readers of Stu Maschwitz' DV Rebels Guide, a book about very low budget action filmmaking).</p>

<p>I usually had two choices: do the colour correction in the editing software that was used to edit the film, or import the final movie into after effects and do it there.</p>

<p>Working in After Effects is the better option quality wise. It can work in 32bit per channel (not 32bit per pixel!) floating point which means that no matter how many colour operations you stack ontop of each other, you will never loose any detail in your image. You can also make complex selections, use a number of very nice plugins etc. It's not realtime, but if you want the highest possible quality, it's the way to go.</p>

<p>Working in the editing software has some other advantages: one of the biggest is that each cut is still there and you can start grading right away. If you work in after effects, usually the first thing you have to do is split your layer at all edit points so that brightening up at one point in the film because that shot is too dark does not brighten up the whole film, only that shot. In the editing software you have all those edit points and so there is no additional work there. What's also nice is that it is (mostly) realtime. But, as I said, the quality is not the best you can get.</p>

<p>Usually this meant that if there was little time and/or only slight corrections required, I would do the grading in the editing software, and only if I had the time to re-set all the edit points would I go for the whole thing and do it in After Effects.</p>

<p>But, *drumroll* with this new script I just wrote, you can export your movie from your edit software of choice, then export an EDL (Edit Decision List) as well, import the movie into AE and then run my new script to split your layer at all edit points given in the EDL. Nice. If you want to give it a try, <a title="Edl Splitter script" href=")/files/EDLSplitter.zip">download the script here</a> and let me know how it worked for you.&nbsp;</p>
