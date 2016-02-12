---
layout: post
title: 920 Milligray website finished
created: 1310828255
categories: []
---
<p><a href="http://www.920milligray.com"><img width="780" height="134" src="/files/milligray-banner.jpg" alt="" /></a></p>

<p>I finally finished work on the website for the film I am currently working on, <a href="http://920milligray.com">920 Milligray</a>. The design was done by Marius Wawer and I built the html page and set up a <a href="http://www.drupal.org">drupal cms</a> for the future (it currently only serves the FAQ page).</p>

<p>920 Milligray is going to be a drama centred on Katja, a young girl who barely knew the world before the catastrophe, and her older brother Uwe. The film is set in a post apocalyptic Europe and is currently in development. BTW, we are actively looking for production companies to get on board so if you know someone who might be interested, please tell them about the project!</p>

<p>One short side note on the workflow I currently use to update my websites: a lot of people who work with websites still use ftp to push new html pages or themes for a CMS to their servers. I seriously recommend to do away with that concept and instead use a distributed version control system like <a href="http://mercurial.selenic.com/">Mercurial</a> or <a href="http://git-scm.com/">Git</a> for this purpose. This way you have full history locally as well as on the server(s), can maintain branches (Version 2.0 e.g.) and switch once everything is ready. Not to mention the advantage of easily being able to share work between people and merge changes from different people with ease.</p>

<p>Git is the system used for the Linux Kernel project among others and very powerful but a bit convoluted in daily use IMHO. I prefer Mercurial which is also powerful but quite a bit simpler to use.</p>

<p>The way I like to work is to have a local Mercurial Repository where I commit changes in small logical batches (command line: <span style="font-family: Courier New;">hg addremove</span> and <span style="font-family: Courier New;">hg commit</span>). Then I have a private repository at bitbucket.org where I have easy to use and secure https access (<span style="font-family: Courier New;">hg push</span> locally to push to the remote repository). Finally, on my webserver (with shell access) I have the repository that contains the content that is visible to the public (<span style="font-family: Courier New;">hg fetch</span> to get the up to date version from the bitbucket repository). This way whenever something goes wrong I can just go back in the history and fix things locally. I use a similar system for all software development I do as well and more and more with other stuff as well.</p>

<p>Our webserver is pretty heavily firewalled but at some point I want to implement https access to the webserver repository directly so I&nbsp;can push without the detour via bitbucket. With a simple post-push script it will then be possible to have an up-to-date version on the webserver with a simple local <span style="font-family: Courier New;">hg push</span>. Nice.</p>

<p>One last note: if you work on windows, <a href="http://tortoisehg.bitbucket.org/">tortoiseHG</a> is a very nice GUI for daily mercurial use.&nbsp;</p>
