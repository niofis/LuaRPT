#pragma warning(disable : 4786)
#include "MS3DFile.h"
#include <stdlib.h>
#include <stdio.h>

//#include <set>
//#include <vector>

#define MAKEDWORD(a, b)      ((unsigned int)(((word)(a)) | ((word)((word)(b))) << 16))

ms3d_vertex_t* ms3d_arrVertices;
word ms3d_numVertices;
ms3d_triangle_t* ms3d_arrTriangles;
word ms3d_numTriangles;
//ms3d_edge_t* arrEdges;
ms3d_group_t* ms3d_arrGroups;
word ms3d_numGroups;
ms3d_material_t* ms3d_arrMaterials;
word ms3d_numMaterials;
//float fAnimationFPS;
//float fCurrentTime;
//int iTotalFrames;
//ms3d_joint_t* arrJoints;

//CMS3DFile::CMS3DFile()
//{
//	_i = new CMS3DFileI();
//}

//CMS3DFile::~CMS3DFile()
//{
//	delete _i;
//}

void LoadSceneFromFile(const char* file)
{
	if(!MS3DLoadFromFile(file))
		return;
}

int MS3DLoadFromFile(const char* lpszFileName)
{
	int i;
	ms3d_header_t header;
	FILE *fp = fopen(lpszFileName, "rb");
	if (!fp)
		return 0;
	fread(&header, 1, sizeof(ms3d_header_t), fp);

	if (strncmp(header.id, "MS3D000000", 10) != 0)
		return 0;

	if (header.version != 4)
		return 0;

	// vertices
	//word nNumVertices;
	fread(&ms3d_numVertices, 1, sizeof(word), fp);
	ms3d_arrVertices = (ms3d_vertex_t*)malloc(ms3d_numVertices * sizeof(ms3d_vertex_t));
	fread(ms3d_arrVertices, ms3d_numVertices, sizeof(ms3d_vertex_t), fp);

	// triangles
	//word nNumTriangles;
	fread(&ms3d_numTriangles, 1, sizeof(word), fp);
	ms3d_arrTriangles=(ms3d_triangle_t*) malloc(ms3d_numTriangles * sizeof(ms3d_triangle_t));
	fread(ms3d_arrTriangles, ms3d_numTriangles, sizeof(ms3d_triangle_t), fp);

	//// edges
	//std::set<unsigned int> setEdgePair;
	//for (i = 0; i < ms3d_arrTriangles.size(); i++)
	//{
	//	word a, b;
	//	a = ms3d_arrTriangles[i].vertexIndices[0];
	//	b = ms3d_arrTriangles[i].vertexIndices[1];
	//	if (a > b)
	//		std::swap(a, b);
	//	if (setEdgePair.find(MAKEDWORD(a, b)) == setEdgePair.end())
	//		setEdgePair.insert(MAKEDWORD(a, b));

	//	a = ms3d_arrTriangles[i].vertexIndices[1];
	//	b = ms3d_arrTriangles[i].vertexIndices[2];
	//	if (a > b)
	//		std::swap(a, b);
	//	if (setEdgePair.find(MAKEDWORD(a, b)) == setEdgePair.end())
	//		setEdgePair.insert(MAKEDWORD(a, b));

	//	a = ms3d_arrTriangles[i].vertexIndices[2];
	//	b = ms3d_arrTriangles[i].vertexIndices[0];
	//	if (a > b)
	//		std::swap(a, b);
	//	if (setEdgePair.find(MAKEDWORD(a, b)) == setEdgePair.end())
	//		setEdgePair.insert(MAKEDWORD(a, b));
	//}

	//for(std::set<unsigned int>::iterator it = setEdgePair.begin(); it != setEdgePair.end(); ++it)
	//{
	//	unsigned int EdgePair = *it;
	//	ms3d_edge_t Edge;
	//	Edge.edgeIndices[0] = (word) EdgePair;
	//	Edge.edgeIndices[1] = (word) ((EdgePair >> 16) & 0xFFFF);
	//	arrEdges.push_back(Edge);
	//}

	// groups
	//word nNumGroups;
	fread(&ms3d_numGroups, 1, sizeof(word), fp);
	ms3d_arrGroups=(ms3d_group_t*)malloc(ms3d_numGroups * sizeof(ms3d_group_t));
	for (i = 0; i < ms3d_numGroups; i++)
	{
		fread(&ms3d_arrGroups[i].flags, 1, sizeof(byte), fp);
		fread(&ms3d_arrGroups[i].name, 32, sizeof(char), fp);
		fread(&ms3d_arrGroups[i].numtriangles, 1, sizeof(word), fp);
		ms3d_arrGroups[i].triangleIndices = (word*) malloc(ms3d_arrGroups[i].numtriangles * sizeof(word));
		fread(ms3d_arrGroups[i].triangleIndices, ms3d_arrGroups[i].numtriangles, sizeof(word), fp);
		fread(&ms3d_arrGroups[i].materialIndex, 1, sizeof(char), fp);
	}

	// materials
	//word nNumMaterials;
	fread(&ms3d_numMaterials, 1, sizeof(word), fp);
	ms3d_arrMaterials=(ms3d_material_t*) malloc(ms3d_numMaterials * sizeof(ms3d_material_t));
	fread(ms3d_arrMaterials, ms3d_numMaterials, sizeof(ms3d_material_t), fp);

	//fread(&fAnimationFPS, 1, sizeof(float), fp);
	//fread(&fCurrentTime, 1, sizeof(float), fp);
	//fread(&iTotalFrames, 1, sizeof(int), fp);

	//// joints
	//word nNumJoints;
	//fread(&nNumJoints, 1, sizeof(word), fp);
	//arrJoints.resize(nNumJoints);
	//for (i = 0; i < nNumJoints; i++)
	//{
	//	fread(&arrJoints[i].flags, 1, sizeof(byte), fp);
	//	fread(&arrJoints[i].name, 32, sizeof(char), fp);
	//	fread(&arrJoints[i].parentName, 32, sizeof(char), fp);
	//	fread(&arrJoints[i].rotation, 3, sizeof(float), fp);
	//	fread(&arrJoints[i].position, 3, sizeof(float), fp);
	//	fread(&arrJoints[i].numKeyFramesRot, 1, sizeof(word), fp);
	//	fread(&arrJoints[i].numKeyFramesTrans, 1, sizeof(word), fp);
	//	arrJoints[i].keyFramesRot = new ms3d_keyframe_rot_t[arrJoints[i].numKeyFramesRot];
	//	arrJoints[i].keyFramesTrans = new ms3d_keyframe_pos_t[arrJoints[i].numKeyFramesTrans];
	//	fread(arrJoints[i].keyFramesRot, arrJoints[i].numKeyFramesRot, sizeof(ms3d_keyframe_rot_t), fp);
	//	fread(arrJoints[i].keyFramesTrans, arrJoints[i].numKeyFramesTrans, sizeof(ms3d_keyframe_pos_t), fp);
	//}

	fclose(fp);

	return 1;
}

void MS3DClean()
{
	//ms3d_arrVertices.clear();
	//ms3d_arrTriangles.clear();
	//arrEdges.clear();
	//ms3d_arrGroups.clear();
	//ms3d_arrMaterials.clear();
	//arrJoints.clear();
	int i;

	free(ms3d_arrVertices);
	free(ms3d_arrTriangles);
	free(ms3d_arrMaterials);
	for (i = 0; i < ms3d_numGroups; i++)
	{
		free(ms3d_arrGroups[i].triangleIndices);
	}
	free(ms3d_arrGroups);
}

int MS3DGetNumVertices()
{
	return (int) ms3d_numVertices;
}

ms3d_vertex_t* MS3DGetVertexAt(int nIndex)
{
	if (nIndex >= 0 && nIndex < (int) ms3d_numVertices)
		return &ms3d_arrVertices[nIndex];
	return NULL;
}

int MS3DGetNumTriangles()
{
	return (int) ms3d_numTriangles;
}

ms3d_triangle_t* MS3DGetTriangleAt(int nIndex)
{
	if (nIndex >= 0 && nIndex < (int)ms3d_numTriangles)
		return &ms3d_arrTriangles[nIndex];
	return NULL;
}

//int MS3D:GetNumEdges()
//{
//	return (int) arrEdges.size();
//}
//
//void MS3DGetEdgeAt(int nIndex, ms3d_edge_t **ppEdge)
//{
//	if (nIndex >= 0 && nIndex < (int) arrEdges.size())
//		*ppEdge = &arrEdges[nIndex];
//}

int MS3DGetNumGroups()
{
	return (int) ms3d_numGroups;
}

ms3d_group_t* MS3DGetGroupAt(int nIndex)
{
	if (nIndex >= 0 && nIndex < (int) ms3d_numGroups)
		return &ms3d_arrGroups[nIndex];
	return NULL;
}

int MS3DGetNumMaterials()
{
	return (int) ms3d_numMaterials;
}

ms3d_material_t* MS3DGetMaterialAt(int nIndex)
{
	if (nIndex >= 0 && nIndex < (int) ms3d_numMaterials)
		return &ms3d_arrMaterials[nIndex];
	return NULL;
}

//int CMS3DFile::GetNumJoints()
//{
//	return (int) arrJoints.size();
//}

//void CMS3DFile::GetJointAt(int nIndex, ms3d_joint_t **ppJoint)
//{
//	if (nIndex >= 0 && nIndex < (int) arrJoints.size())
//		*ppJoint = &arrJoints[nIndex];
//}

//int CMS3DFile::FindJointByName(const char* lpszName)
//{
//	for (size_t i = 0; i < arrJoints.size(); i++)
//	{
//		if (!strcmp(arrJoints[i].name, lpszName))
//			return i;
//	}
//
//	return -1;
//}

//float CMS3DFile::GetAnimationFPS()
//{
//	return fAnimationFPS;
//}
//
//float CMS3DFile::GetCurrentTime()
//{
//	return fCurrentTime;
//}
//
//int CMS3DFile::GetTotalFrames()
//{
//	return iTotalFrames;
//}
