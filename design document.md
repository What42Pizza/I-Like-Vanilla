Sometimes I can lose sight of what all I'm trying to achieve with this shader (and maybe others are just curious), so here's my list of design goals (in order of importance):

### Effects should be subtle

You shouldn't constantly notice the bloom, ssao, shadows, reflections, etc. There are some cases, like shadows and sunrays, where it's okay to briefly notice and appreciate the effects, but that should be a rarity. For the most part, you shouldn't even be able to tell that the effects are enabled. And a good way to think about it: you don't notice when it's enabled, but you do notice when it's not enabled.

### It should make everything look inspiring

Everything should look like something you want to build on, expand into, etc. I'm not exactly sure how to achieve this, but still it's one of the most important goals.

### It should look like Minecraft

I want it to be somewhat easy to look at a screenshot with ILV enabled and mistake it for vanilla graphics. That's not to say that it should look exactly like vanilla Minecraft in most situations, and in fact it would be ideal for it to be noticeably different in all situations. But still, the motto for this shader is 'improving Minecraft's style instead of copying or replacing it'.

### It shouldn't block what you're looking at

The sunrays, fog, and other atmospheric effects shouldn't stop you from easily seeing what you're looking at. All effects should improve your view, not replace it.

### It should be performant

This needs to run well, especially considering its simplistic graphics.
