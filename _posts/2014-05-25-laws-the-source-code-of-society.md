---
layout: post
title: Laws - the source code of society
created: 1401046111
categories: []
---
Today the citizens of EU will elect a new parliament and this seemed a good opportunity to write down some of my thoughts on lawmaking. As the title suggests, I think that law texts are very similar to source code. Of course, source code is a lot stricter insofar as it defines exactly what the computer will do. Laws on the other hand describe general rules for behaviour as well as the punishment for violations of those - ultimately though, both are expressed as text. Yet where programmers have developed sophisticated tools to work with source code, laws are still developed in bizarre workflows that necessitate a huge support staff. In this post I want to describe one set of tools used by programmers to work on texts; how I think they could be useful for lawmaking; and what our society would gain if our lawmakers would adopt them.

When non-programmers write, they often realize that it would be beneficial to save old versions of their texts. This leads to document file names with numbers attached ("Important text 23.doc") and then the infamous "final", "final final", "really final" etcetera progression. Programmers instead rely on a set of tools that are known as Distributed Version Control Systems ([DVCS](http://en.wikipedia.org/wiki/Distributed_version_control_system)). The most famous of these is probably [Git](http://en.wikipedia.org/wiki/Git_%28software%29), which is used in many open source efforts. What these tools do is manage the history of the text documents registered with them, and allowing easy sharing and merging of changes.



In practice, after changing a couple of lines in one or more documents these changes are recorded as one "Changeset". These changesets can be displayed as a timeline and one can go back to the state of the documents at any point in its history.



![A sample of the timeline of several changes in a DVCS](/files/DVCS.png)



This in itself is alreday clearly useful, but what really makes DVCS magnificent tools is the ability to manage not just a simple linear progression of changes but different "Branches". This allows several people to make changes to the text, share their changesets and let the system automatically combine their changes into a new version.  



Because changes by many people creating many branches can become confusing, there are some great tools to visualize these changes, as well as complex workflows that allow others to review and authorize changes via their cryptographic signature.



So how would these tools be useful in creating law texts? The main benefit would be to clearly document which politician introduced which line into a law, and which edits they made. Others in the working group could create branches with their favoured wording, and these could then be combined into the final version that is voted on by parliament.



One very useful tool is the blame tool (sometimes also called praise or annotate), which displays a document in such a way that each line is tagged with the person who last changed it. I think that it could be quite revealing to see who changed what in our laws, a process that at present would be very time consuming. 



The website [Abgeordnetenwatch](http://www.abgeordnetenwatch.de/) already tracks the voting behaviour of the members of the German parliament, and it would be a great extension of this effort if the genesis of all law texts were plain to see for everyone as well. [Bundesgit](http://bundestag.github.io/gesetze/) already puts the final German law texts into a Git database - but because these are only the final texts and Git is only accessed by a single person instead of the real authors, the real power of a DVCS can't be used. For things like the blame tool to work, all the small changes during the draft stage in the parliament's working group would have to be made inside a DVCS by their respective authors.



I am sure that there are many more potential improvements to the process of lawmaking that would be possible if lawmakers used DVCS tools. But the main and immediate advantage would be an increase in transparency, which in the end is what democracy is all about. Laws are the source code of our societies. Let's make sure they are made with the best tools available.
