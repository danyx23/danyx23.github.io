---
layout: post
title: A backup script that hibernates the computer
created: 1132600575
categories:
- coding
---
<p>I just completed a first version of a backup-script that shuts a few apps down that lock important files, starts a backup-process and waits 'till completion, then sends the computer into hibernate. I run this script now before I go to bed, this way everything gets backed up at a time when I know it doesn't bother me, yet as soon as it's done it goes into hibernate mode to save electicity.</p><p>The script is attached below. It is written using the nifty <a title="Autohotkey scripting utility" href="http://www.autohotkey.com/">AutoHotKey</a> software. It uses <a title="Peters Backup" href="http://pbackup.sourceforge.net/">peters backup</a> as a backup solution and <a title="Wizmo hibernate utility" href="http://grc.com/wizmo/wizmo.htm">Wizmo</a> to send the computer into hibernate mode. The script is a simple textfile so adjust anything according to your needs. I left all the paths I used in the script so that you have an idea of a real-world scenario. </p>
