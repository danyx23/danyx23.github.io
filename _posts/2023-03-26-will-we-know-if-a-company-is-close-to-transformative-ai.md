---
layout: post
title: Will we know if a company is close to transformative artificial intelligence?
toc: true
---

Over the last few years it seemed like we were able to observe the cutting edge of AI research more or less in the open and more or less in real time. Some was in the form of public demos, some in academic papers, others directly in products. As the capabilities of these systems advance, however, I think we need to wonder if this will remain true, and consider the repercussions of what would happen if this changes.

When I talk about new capabilities I mean things that would be a substantial improvement over the status quo of GPT4 or similar systems. To give a few examples:

-   The ability to form memories cheaply and quickly and be able to access them when relevant. Currently, every ChatGPT session is a tabula rasa. For instance if you mentioned where you live in a previous session, ChatGPT won't remember it in the next. There are of course workarounds that are already used that basically duplicate part of the chat history into a new chat or allow some more sophisticated forms of relevant text recall via so called embeddings. But the former is limited by the text length the input to an LLM (Large Language Model) can have and the latter is limited by semantic similarity between the memory and the current context which is only a subset of how humans access memory. Both are pretty far from the kind of automatic, context sensitive memory formation (and forgetting!) that humans are capable of. 

-   Being able to learn to avoid specific outcomes based on single counterexamples. Current LLMs are trained for a given time but once the training is over and they are used in "Inference mode" ( i.e. to complete text) they cannot learn anything new. This is again very much unlike how humans behave. We might be able to find workarounds for dealing with this with modified prompts but a system that could continue to learn and to learn from single counter examples would be substantially more powerful than current systems.

-   Excelling at strategic long term goal planning and execution over long time horizons with fuzzy outcomes. This is maybe the most important of these. Today's LLMs can be coaxed into outlining some semblance of a plan for non-trivial tasks, but this is currently quite limited. Because LLMs don't learn anything new and have no sense of time passing, using them to execute actions over a long time span would need a lot of guidance that regularly invokes the LLM and encodes a timeline of what happened and what the overall plan was into text form (a bit like what the main character in the movie [Memento](https://www.imdb.com/title/tt0209144/) does). For many interesting, long run tasks, it would be desirable if AI systems would be more autonomous than that - if they would "exist continuously" in time, have a sense of time passing and be able to actively query the internet or the wider world and act on their own.


A system with such added capabilities would have a much wider set of applications than today‘s prompt answer systems like ChatGPT. Do you think the company that makes a breakthrough in one of those areas would immediately make it available to the public, either as a demo or paid product? Or might it keep the system secret and try to use it for its own benefit?

![Rene Magritte, La Clef des champs](/img/Rene Magritte - La Clef des champs.jpg)

Are we sure we are seeing what tech companies are up to? Rene Magritte, La Clef des champs

What could such benefits be? One obvious one is financial trading. To caricature this idea for added effect: There is a good chance that the first sentient digital being would be imprisoned by a tech company to trade stocks. Of course you don’t really need sentience - a system that is just really good at ingesting lots of information quickly and that can devise, modify and execute trading strategies efficiently might outperform both human traders and today's high frequency trading systems. What does it do to our society, if one company has a consistent edge on everyone else in financial trading?

Another possible benefit might be substantial advances in automated software development, including the development of better AIs. The systems of today like Github Copilot are pretty good at generating code at a very small scale but they are not very useful for making coordinated changes to complex systems. If a single company had a system that were able to make complex changes automatically, then that company might be able to create and improve software at a higher speed, at much lower cost, than others.

It is of course possible that keeping this information secret would be hard; that the details of the breakthrough would quickly become common knowledge which would then be an incentive to turn it into a product (e.g. as virtual co-workers that you interact with over slack or similar but that have memory and can interact with other employees on their own to execute complex tasks that span days or weeks). But it seems equally possible that a single player could hold on to the key element of improvement for long enough to give it a substantial edge.

Over the past 200 years, capitalism has relied on companies to drive a significant portion of societal development and innovation. This could give companies tremendous power so we developed anti-trust legislation and other mechanisms to avoid outright monopolies. We used tools like patents that grant state guaranteed exclusivity in return for sharing the blueprints of a technology. We relied on the fact that in the physical world, substantially scaling production is something that happens over the course of years. It also helped that knowledge disseminates over similar timelines. Together, these effects mostly assured that no single entity could accrue too high a share of the whole economy.

Will this still be the case with AI? Progress in AI could be very quick to deploy and scale up - GPTChat has been used by over 100 million users within 2 months of being made public.  If a single company achieves a breakthrough, there is a genuine risk of it quickly becoming a dominant force. I think you don‘t have to be a socialist to see that having a single economic entity having a large advantage in this technology could be a huge problem.

What are we to do? Stepping back from how we happen to organize society and our economy today, I think it is fair to say that if AI becomes a very powerful tool then we would want this to benefit mankind at large. Yet with the system we have in place today I think there is a very significant chance that it will instead make a few already very powerful tech companies even more powerful, very likely to an extremely unhealthy degree.

Much capital is currently invested into AI precisely because the returns could be very large. We will not be able to reconfigure how we develop AI - there is no way to make this happen in academia instead. 

So the best possible thing that I can think of is, at the very least, to put laws in place that allow public visibility into all AI developments at companies at more or less real time. Because the US is the most likely place for progress to happen, it seems to be the most important one to target for this. This would probably need a combination of an obligation to publicly document all AI research in a timely manner (e.g. quarterly); hefty fines for non-compliance; and whistleblower protection for employees who sound the alarm bell if the content of reports deviates from reality.

![Pablo Picasso, Las Meninas](/img/Pablo Picasso - Las Meninas.jpg)

Staring into an AI research project - Pablo Picasso, Las Meninas

Getting the details right of this will be far from trivial - what constitutes a "research project" that requires reporting? How can you get reports at a fine enough granularity that actually tell you something interesting? You wouldn't want all or the research activity a company does to be lumped together as one project of "progressing AI". Writing good laws is hard, let alone at a rapidly developing technological frontier like this. Maybe biohazard regulation could be a guiding light and maybe "artificial intelligence hazard" might be a good umbrella term for this kind of regulation.

Having such visibility legislation in place will by no means make sure that the race towards ever more powerful AI will lead to equitable outcomes - but it would at least help the public understand what is going on so that we can attempt to make changes to the rules of the game if things get hot.

OpenAI has [recently changed course on these matters](https://twitter.com/jjvincent/status/1636065237500588033) - in the past they argued that sharing information was important as part of „being a good citizen“ in the AI space. Recently they have started to argue that it would be dangerous to make details of their training data or of their models public as others might be able to use these for nefarious purposes. This of course coincides conveniently with a breakpoint in their ability to commercialize their technology via subscriptions or to license their technology to other companies. 

Whether companies should be incentivised to reveal technical details of their systems or their training data is a separate question - but I think it is crucial that we force them to reveal some meta information of all their R&D projects. This should include information on how much compute and data they are investing in those programs and what their purpose and aims are. I think a world in which all US tech companies were forced to reveal such information once a quarter would be one that stands a better chance of avoiding bad outcomes in AI. 

I'm curious to hear what others think. Let me know your thoughts via email or on [twitter](https://twitter.com/danyx23) and if you enjoy this substack please share it with others - thanks!

(Note: this post was published [also on my Substack](https://aihorizon.substack.com/p/will-we-know-if-a-company-is-close))