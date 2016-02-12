---
layout: post
title: Self documenting data manipulation with R-Markdown
created: 1449943140
categories: []
---
<p>The company I worked for over the last few years provides a lot of data cleaning/data manipulation services, mostly with proprietary tools that I and another developer created over the last few years. One of the things I introduced before I left was a bridge between the proprietary datasets that are used inside that company and the <a href="https://www.r-project.org/" target="_blank">R project</a>. My main motivation for this was to enable self-documenting workflows via <a href="http://rmarkdown.rstudio.com/" target="_blank">R-Markdown</a> and in this blog post I want to talk about the advantages of this approach.</p>

<p>R Markdown is a syntax definition and a set of modules for R that make it very straightforward to write normal text documents that embed R code. When compiling the text files, the R code is executed and the result embedded into the compiled document. These results can just be the textual output of R functions (like summary() that describes a couple of important metadata of a data set) or even graphics.</p>

<p>As the name suggests, R Markdown uses the <a href="https://daringfireball.net/projects/markdown/" target="_blank">markdown syntax</a> for formatting text, so you would write something <strong>between stars</strong> to make it bold etc. Markdown is pretty neat in that it is both easy to read as plain text but also easily compiled to html to be viewed with actual formatting in a browser.</p>

It's probably easier to understand with an example, so here is a simplified version of what this looks like:

<pre>
This is a sample r-markdown script that plots Age vs Income as a 
Hexbin plot. This text here is the natural language part that can 
use markdown to format the text, e.b. to make things **bold**.

```{r Income vs Age - Hexbin}
# The backticks in the line above started an R code block. 
# This is a comment inside the R block. We now load the hexbin 
# library and plot the data2008 dataset (the code for loading 
# the dataset was ommited here)

library(hexbin)
bin <- hexbin(data2008[, 1], data2008[, 2], xbins = 50, xlab = "Alter", ylab = "Einkommen")
plot(bin)
```
</pre>

And this is what the compiled html looks like (embedded here as a screenshot)

<img src="/files/RMarkdownIncomeVsAge.png"/>

The great thing about inlining R code in a markdown document in this way is that you can create a new workflow that is much more maintainable because the focus shifts to documenting the intention. Instead of focusing on writing R code to get a job done and then documenting it a little with some comments or as text in a separate document, the analyst starts the work by describing, in plain text, what it is she wants to do. She then embeds the code to do the transformation, and can even generate graphs that show the data before and after.

This idea to document changes by embedding graphs was my original trigger for writing the bridge code. I had implemented the weighting code in our proprietary tool but the textual output describing the changes in the weights was a bit terse. It was clear that a graphical representation would be easier to understand quickly, but introducing a rich graph library into our proprietary DSL would have been a major undertaking. By making it fast and easy to get our data sets into R and back out again, we quickly got a way to create graphs plus it enabled the self-documenting workflow described above.

Another big plus is that since all transformations are described in natural language as well as in code, auditing data manipulations becomes a lot easier and quicker. I can thus wholeheartedly recommend this workflow to everyone who works with data for a living.
