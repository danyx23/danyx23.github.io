---
layout: post
title: Incremental backups made easy
created: 1323627102
categories: []
---
<p>In my <a href="/node/121">last post</a> I wrote in length about backups but I omitted one thing: how to make incremental backups that use so called hard links and that barely take more space than 1:1 backups (on both windows and osx). First though, let me explain what is so nice about this concept.</p>
<h3 id="backups-with-a-history">Backups with a history</h3>
<p>If space were no concern, it would be nice never to throw backups away. We would simply have folders that contain the date and time the backup was taken as part of the backup target folder name and keep all those backups. Then if one day we discover that we now need a file that was deleted two weeks ago we would simply access the backup from 16 days ago and restore it. If, like me, you have several TB of important data and can barely afford 2 additional sets of hard drives (one to keep as a daily backup, one that is stored at another location and that is swapped regularly) then this seems to be impossible.</p>
<h3 id="incremental-backups">Incremental backups</h3>
<p>If you look at your whole hard drive(s) then you will notice that between two backups only a fraction of the data actually changes. This is what incremental backups use to their advantage. They only store the new and changed files and thus save a lot of space. However now you have a full backup at one point in time and every time you run the backup again you get a new folder structure (or, if you choose a bad backup software, a proprietary single file) containing only the new and changed files. This is a bit cumbersome. Wouldn't it be great to have a full snapshot each time?</p>
<h3 id="hardlinks-to-the-rescue">Hardlinks to the rescue!</h3>
<p>This is where a feature called Hardlinks comes in handy. Hardlinks are a way for file systems to reference the same file several times, but only storing it once. Both NTFS (the main windows file system) and HFS+ (the main OSX files system) support hardlinks, but both operating systems hide this feature from the user interface.</p>
<h3 id="what-we-gain-from-this-approach">What we gain from this approach</h3>
<p>So taken together, these features enable incremental backups that look like full snapshots but only store the new and changed data. This way you only need a backup drive that is a bit bigger than your source (since you will want to have some additional space for the newly created and modified files) and you can keep a full history on it.</p>
<h3 id="rsync-and-two-guis-for-it">rsync and two GUIs for it</h3>
<p>rsync is an open source application that is used to copy data. Since version 3 or so it supports creating snapshot copies using hardlinks. On OSX the tool <a href="http://rdutoit.home.comcast.net/~rdutoit/pub/robsoft/pages/softw.html">backuplist+</a> allows you to easily create incremental backups by checking the &quot;Incremental backups&quot; check box and entering how many past snapshots to keep. On windows <a href="http://qtdtools.doering-thomas.de/">QtdSync</a> allows you to do the same thing if you change the backup type from &quot;synchronisation&quot; to &quot;incremental&quot;.</p>
