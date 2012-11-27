LuaRPT
=============

This is a ray and path tracing program build on lua. It doesn't try to be the fastest
implementation around (altough it uses a BVH structure), but a somewhat easy to read,
maintain and extend.

Licence
-------

This project is released under a MIT license, unless otherwise especified.

Copyright (c) 2012 Enrique CR

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

Version
-------
1.0.3
- Scene can now be specified via command line arguments; usage: -scene file. See demo.lua for a scene example.

1.0.2
- Path tracing wasn't working when activated from command line arguments.

1.0.1
- Added parameter for hex output filename. (-hex filename.hex)
- Added parameter for png image filename. (-png image.png)
- Added parameter to define render resolution. (-res width height)
- Added parameter to define a section to render. (-s section_x section_y section_width section_height)
- Added parameter to activate path tracing with number of samples. (-path samples)
- Modified image.lua to support partial render output.

Other Stuff
-----------

Will be added later.
