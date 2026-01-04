---
layout: post
title: "@ work: using files as locks with the .NET Framework"
created: 1132244659
categories:
- coding
---
I recently implemented a custom locking mechanism for files that works through creating a file with the same name and .lock appended. When the file exists, another user of my program has the file locked, when it does not exist the file is not locked. Inside the lock file I store only the name of the user who owns the lock, so that communication can take place between the users. 



For this, I wanted to open the .lock file with the option FileOptions.DeleteOnClose and FileShare.Read . This however, does not work, because DeleteOnClose does not allow FileSharing! Since this is not documented anywhere and apperently never came up in any newsgroup, I thought I'd post it here. The solution it seems is to take care of deleting the file when you close it.
