LUA_CFLAGS="-I/usr/include/lua5.1 "
LIBTOOL="libtool --tag=CC --silent"
$LIBTOOL --mode=compile cc -c $LUA_CFLAGS luasdl.c 
$LIBTOOL --mode=link cc -rpath /usr/local/lib/lua/5.1 -lSDL -lm -lpng -pthread  -o libluasdl.la luasdl.lo
mv .libs/libluasdl.so.0.0.0 luasdl.so
rm libluasdl.la luasdl.lo luasdl.o
#optional
mv luasdl.so ../luasdl.so

$LIBTOOL --mode=compile cc -c $LUA_CFLAGS png.c 
$LIBTOOL --mode=link cc -rpath /usr/local/lib/lua/5.1 -lSDL -lpng -lm -pthread  -o libpng.la png.lo
mv .libs/libpng.so.0.0.0 png.so
rm libpng.la png.lo png.o
#optional
mv png.so ../png.so

$LIBTOOL --mode=compile cc -c $LUA_CFLAGS ms3d.c 
$LIBTOOL --mode=compile cc -c $LUA_CFLAGS MS3DFile.c
$LIBTOOL --mode=link cc -rpath /usr/local/lib/lua/5.1 -lSDL -lpng -lm -pthread  -o libms3d.la MS3DFile.lo ms3d.lo
mv .libs/libms3d.so.0.0.0 ms3d.so
rm libms3d.la ms3d.lo ms3d.o MS3DFile.o MS3DFile.lo
#optional
mv ms3d.so ../ms3d.so
