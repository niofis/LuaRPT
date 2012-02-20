#define LUA_LIB
#ifdef WIN32
	#define LUA_BUILD_AS_DLL
#endif

#include <lua.h>
#include <lauxlib.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include "MS3DFile.h"

//void Demo0()
//{
//	int i;
//	ms3d_material_t* ms3d_material;
//	ms3d_group_t* ms3d_group;
//	ms3d_vertex_t* ms3d_vertex;
//	ms3d_triangle_t* ms3d_triangle;
//
//#if defined(WINCE)
//	LoadSceneFromFile("\\Storage Card\\cRTu\\shadow_test.ms3d");
//#else
//	LoadSceneFromFile("D:/Enrique/Tesis/Modelos/f360/f360.ms3d");
//#endif
//
//	num_camaras=1;
//	camaras=(Camara*)malloc(sizeof(Camara)*num_camaras);
//	i=0;
//	camaras[0].eye[0]=0.0f;
//	camaras[0].eye[1]=0.0f;
//	camaras[0].eye[2]=-20.0f;
//
//	camaras[0].lefttop[0]=-3.2f;
//	camaras[0].lefttop[1]=2.4f;
//	camaras[0].lefttop[2]=-10.0f;
//
//	camaras[0].righttop[0]=3.2f;
//	camaras[0].righttop[1]=2.4f;
//	camaras[0].righttop[2]=-10.0f;
//
//	camaras[0].leftbottom[0]=-3.2f;
//	camaras[0].leftbottom[1]=-2.4f;
//	camaras[0].leftbottom[2]=-10.0f;
//
//	//Crear Luz
//	num_luces=1;
//	luces=(Luz*)malloc(sizeof(Luz)*num_luces);
//	i=0;
//	luces[i].color[0]=1.0f;
//	luces[i].color[1]=1.0f;
//	luces[i].color[2]=1.0f;
//	luces[i].color[3]=1.0f;
//	luces[i].intensidad=100.0f;
//	luces[i].id=i;
//	luces[i].posicion[0]=0.0f;
//	luces[i].posicion[1]=2.0f;
//	luces[i].posicion[2]=-5.0f;
//
//
//	//Crear Material
//	num_materiales=MS3DGetNumMaterials();
//	materiales=(Material*)malloc(sizeof(Material)*num_materiales);
//	for(i=0;i<num_materiales;i++)
//	{
//		ms3d_material=MS3DGetMaterialAt(i);
//		materiales[i].color[0]=1.0f;
//		materiales[i].color[1]=ms3d_material->diffuse[0];
//		materiales[i].color[2]=ms3d_material->diffuse[1];
//		materiales[i].color[3]=ms3d_material->diffuse[2];
//		materiales[i].id=i;
//		materiales[i].ptr_textura=0;
//		materiales[i].reflexion=ms3d_material->shininess;
//		materiales[i].refraccion=ms3d_material->transparency;
//		materiales[i].specular=1.0f;
//		materiales[i].textura=0;
//		materiales[i].txt_height=0;
//		materiales[i].txt_width=0;
//	}
//
//	num_grupos=MS3DGetNumGroups();
//	grupos=(Grupo*)malloc(sizeof(Grupo)*num_grupos);
//	for(i=0;i<num_grupos;i++)
//	{
//		ms3d_group=MS3DGetGroupAt(i);
//		grupos[i].id=i;
//		grupos[i].id_material=ms3d_group->materialIndex;
//	}
//
//
//	num_objetos=MS3DGetNumTriangles();
//	//objetos=(Objeto3D*)malloc(sizeof(Objeto3D)*num_objetos);
//	CreateObjects(num_objetos);
//	for(i=0;i<num_objetos;i++)
//	{
//		ms3d_triangle=MS3DGetTriangleAt(i);
//		objetos[i].id_grupo=ms3d_triangle->groupIndex;
//		objetos[i].id=i;
//		objetos[i].tipo=OBJ_TRIANGULO;
//
//		ms3d_vertex=MS3DGetVertexAt(ms3d_triangle->vertexIndices[0]);
//		V_INIT(objetos[i].v1,ms3d_vertex->vertex[0],ms3d_vertex->vertex[1],-ms3d_vertex->vertex[2]);
//
//		ms3d_vertex=MS3DGetVertexAt(ms3d_triangle->vertexIndices[1]);
//		V_INIT(objetos[i].v2,ms3d_vertex->vertex[0],ms3d_vertex->vertex[1],-ms3d_vertex->vertex[2]);
//
//		ms3d_vertex=MS3DGetVertexAt(ms3d_triangle->vertexIndices[2]);
//		V_INIT(objetos[i].v3,ms3d_vertex->vertex[0],ms3d_vertex->vertex[1],-ms3d_vertex->vertex[2]);
//	}
//	
//	MS3DClean();
//	BuildBVH();
//	PreprocessObjects();
//
//}

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

	lua_pushstring(L,"group");
	lua_pushstring(L,ms3d_group->name);
	lua_settable(L,-3);

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
			//negate the z coordinate so +z points away
			lua_pushstring(L,"z");
			lua_pushnumber(L,-ms3d_vertex->vertex[2]);
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