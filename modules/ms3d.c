/*
Copyright (c) 2011 Enrique CR

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
*/

#define LUA_LIB
#ifdef WIN32
	#define LUA_BUILD_AS_DLL
#endif

#include <lua.h>
#include <lauxlib.h>
#include <math.h>
#include <stdio.h>
#include "MS3DFile.h"

static int gettriangle(lua_State *L)
{
	int index=lua_tonumber(L,1)-1;
	int i=1;
	int vi=0;
	int v=0;
	char str[256];

	ms3d_triangle_t* ms3d_triangle;
	ms3d_vertex_t* ms3d_vertex;
	ms3d_group_t* ms3d_group;
	ms3d_material_t* ms3d_material;


	ms3d_triangle=MS3DGetTriangleAt(index);
	ms3d_group=MS3DGetGroupAt(ms3d_triangle->groupIndex);
	ms3d_material=MS3DGetMaterialAt(ms3d_group->materialIndex);

	lua_newtable(L);
	for(v=0;v<3;v++)
	{
		ms3d_vertex=MS3DGetVertexAt(ms3d_triangle->vertexIndices[v]);
		sprintf(str,"v%d",v+1);
		lua_pushstring(L,str);
		lua_newtable(L);
		{
			lua_pushstring(L,"x");
			lua_pushnumber(L,ms3d_vertex->vertex[0]);
			lua_settable(L,-3);
		}
		{
			lua_pushstring(L,"y");
			lua_pushnumber(L,ms3d_vertex->vertex[1]);
			lua_settable(L,-3);
		}
		{
			lua_pushstring(L,"z");
			lua_pushnumber(L,ms3d_vertex->vertex[2]);
			lua_settable(L,-3);
		}
		lua_settable(L,-3);
	}

	//send color info to lua
	lua_pushstring(L,"color");
	lua_newtable(L);
	{
		{
			lua_pushstring(L,"r");
			lua_pushnumber(L,ms3d_material->diffuse[0]);
			lua_settable(L,-3);
		}
		{
			lua_pushstring(L,"g");
			lua_pushnumber(L,ms3d_material->diffuse[1]);
			lua_settable(L,-3);
		}
		{
			lua_pushstring(L,"b");
			lua_pushnumber(L,ms3d_material->diffuse[2]);
			lua_settable(L,-3);
		}
		{
			lua_pushstring(L,"a");
			lua_pushnumber(L,ms3d_material->diffuse[3]);
			lua_settable(L,-3);
		}
	}
	lua_settable(L,-3);

	return 1;
}

static int getnumtriangles(lua_State *L)
{
	int n = MS3DGetNumTriangles();
	lua_pushnumber(L,n);
	return 1;
}

static int loadfile(lua_State *L)
{
	char *file;
	file=lua_tostring(L,1);
	LoadSceneFromFile(file);
	return 0;
}

static int closefile(lua_State *L)
{
	MS3DClean();
	return 0;
}

static const luaL_reg ms3dlib[] = {
{"loadfile",   loadfile},
{"closefile",   closefile},
{"getnumtriangles",   getnumtriangles},
{"gettriangle",   gettriangle},
{NULL, NULL}
};

LUALIB_API int luaopen_ms3d (lua_State *L)
{
	luaL_register(L, "ms3d", ms3dlib);
	return 1;
}

void main()
{

}
