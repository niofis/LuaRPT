#define LUA_LIB
#ifdef WIN32
	#define LUA_BUILD_AS_DLL
#endif
#include <zlib.h>
#include <png.h>
#include <lua.h>
#include <lauxlib.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

static int width;
static int height;
static int bpp;
static int Bpp;
static unsigned char* image;

#define abort_(str) {printf(str);return 1;}

static int save(lua_State *L)
{
		char* file_name=(char *)lua_tostring(L,1);
		int r=0;
		png_structp png_ptr;
		png_infop info_ptr;
		static png_FILE_p fp;
        /* create file */
        fp = fopen(file_name, "wb");
        if (!fp)
                abort_("[write_png_file] File  could not be opened for writing");


        /* initialize stuff */
        png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);

        if (!png_ptr)
                abort_("[write_png_file] png_create_write_struct failed");

        info_ptr = png_create_info_struct(png_ptr);
        if (!info_ptr)
                abort_("[write_png_file] png_create_info_struct failed");

        if (setjmp(png_jmpbuf(png_ptr)))
                abort_("[write_png_file] Error during init_io");

        png_init_io(png_ptr, fp);


        /* write header */
        if (setjmp(png_jmpbuf(png_ptr)))
                abort_("[write_png_file] Error during writing header");

        png_set_IHDR(png_ptr, info_ptr, width, height,
                     8, PNG_COLOR_TYPE_RGB, PNG_INTERLACE_NONE,
                     PNG_COMPRESSION_TYPE_BASE, PNG_FILTER_TYPE_BASE);

        png_write_info(png_ptr, info_ptr);

		png_set_bgr(png_ptr);

        /* write bytes */
        if (setjmp(png_jmpbuf(png_ptr)))
                abort_("[write_png_file] Error during writing bytes");

        //png_write_image(png_ptr, row_pointers);
		for(r=0;r<height;r++)
		png_write_row(png_ptr,(char*)(&image[r*width*Bpp]));


        /* end write */
        if (setjmp(png_jmpbuf(png_ptr)))
                abort_("[write_png_file] Error during end of write");

        png_write_end(png_ptr, NULL);

        /* cleanup heap allocation */
		/*
        for (y=0; y<height; y++)
                free(row_pointers[y]);
        free(row_pointers);
		*/

        fclose(fp);
		return 0;
}


static int setpixel(lua_State *L)
{
	//int* theta = lua_topointer(L, 6);
	//int* usr=lua_touserdata(L,6);
	int x=lua_tonumber(L,1);
	int y=lua_tonumber(L,2);
	int r=lua_tonumber(L,3);
	int g=lua_tonumber(L,4);
	int b=lua_tonumber(L,5);
	int pos;
	//int c=lua_tonumber(L,6);
	pos=(y*width + x) * Bpp;
	image[pos]=b;
	image[pos+1]=g;
	image[pos+2]=r;

	return 0;
}

static int createnew(lua_State *L)
{
	int nw=lua_tonumber(L,1);
	int nh=lua_tonumber(L,2);
	Bpp=3;
	width=nw;
	height=nh;
	image=(unsigned char*)malloc(width*height*Bpp);
	//printf("%d %d %d",width, height,Bpp);
	printf("pnglib init\n");
}

static int release(lua_State *L)
{
	free(image);
}

static const luaL_reg pnglib[] = {
{"setpixel",   setpixel},
{"save",   save},
{"createnew",createnew},
{"release",release},
{NULL, NULL}
};

LUALIB_API int luaopen_png (lua_State *L)
{	
	luaL_register(L, "png", pnglib);
  return 1;
}