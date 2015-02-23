Vim Increment
=============
Appends an increasing number to a pattern on a range of lines.

About
-----
Whenever I program or want to keep track of something, I'll often create a numbered list in vim. Nothing fancy, just something like this:

        1. Some stuff about task1
        2. Some stuff about task2
        3. Some stuff about task3
        4. Some stuff about task4
        5. Some stuff about task5

Now if I complete task 3 and delete it, then the list would look like this:

        1. Some stuff about task1
        2. Some stuff about task2
        4. Some stuff about task4
        5. Some stuff about task5

I'm not a huge fan of that. Is it a big deal? Of course not, but isn't it nicer when numbers are in order? So I wrote this bit of vimscript to automatically renumber things such as this. To solve the above issue, visually highlight the list and run the command:

```vim
:call Number()
```

The end result would look like this:

        1. Some stuff about task1
        2. Some stuff about task2
        3. Some stuff about task4
        4. Some stuff about task5

Examples
--------
The function Number() was designed for more than just lists beginning with numbers. The rough algorithm is this: In a selected region of text, Number() will find the most common pattern ending in 1 or more digits and replace the digits in those patterns with an increasing sequence of numbers. Here are a few examples of what it can do:

###Highlight Empty Lines and Call Number()
If you select a series of empty lines and call Number() then those empty lines will contain an increasing sequence of numbers.

###Number() is Fairly Smart
Say you have a list like this:

        1. This is the first thing on the list. In this item there are
           2 things I want to talk about...
        3. This is the third thing
        5. This is the fifth thing
        
Number() will not touch the '2' in the first list item. Neat!

###More Than Just Numbered Lists
This vimscript was originally inspired by some xml editing I had to do. There was a section of an xml file that looked something like this:

```xml
    <transitions>
        <transition1 atr="super cool attr">
        <transition2 atr="okay attr">
        <!-- <transition2 atr="old"> this is old -->
        <transition3 atr="cool attr">
        <transition4 atr="cool attr">
        <transition5 atr="new transition 5 node">
        <transition5 atr="such">
        <transition6 atr="wow">
        <transition7 atr="much">
        <!-- <transition7 atr="old"> this is old -->
        <transition8 atr="taste">
        <transition9 atr="so">
        <transition10 atr="bao">
        <transition11 atr="hello world">
    </transitions>
```

These nodes had to be kept in number order. So whenever a new node was added, all nodes after it would have to have their numbers adjusted. That was a pain. In the above xml, we see that a new 'transition5' node was added. That means that the old 'transition5' node will become 'tranistion6', 6 will become 7 etc... Again, the solution is just to highlight all the text and call Number(). In the above example it would correctly number these nodes, ignoring the comments and everything.
