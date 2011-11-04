LUA_CFLAGS="-I/usr/include/lua5.1 "
LIBTOOL="libtool --tag=CC --silent"
$LIBTOOL --mode=compile cc -c $LUA_CFLAGS LuaSDL.c 
$LIBTOOL --mode=link cc -rpath /usr/local/lib/lua/5.1 -lSDL -lm -lpng -pthread  -o libLuaSDL.la LuaSDL.lo
mv .libs/libLuaSDL.so.0.0.0 LuaSDL.so
rm libLuaSDL.la LuaSDL.lo LuaSDL.o
#optional
mv LuaSDL.so ../LuaSDL.so
