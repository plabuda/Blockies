# Blockies
Backend-agnostic, drag and drop code editor. In Lua, for Lua

Motivation behind Blockies is to allow users to comfortably edit Lua code from within VR, by representing the code as physical blocks that snap together, akin to Scratch
The main part of Blockies is designed to be agnostic of platform-specific bits, like representation of transform, rendering methods, cursor movement, etc. 
Officially supported backends include LÖVE and LÖVR.

While the main focus is to allow coding in Lua 5.1, there is nothing that prevents adding support for another language. Blockies itself is just a very crude version of a UI framework geared towards displaying simple, one color blocks and lines of text - it is not explicitely tied to one language. 


