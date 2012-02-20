#define LUA_LIB
#ifdef WIN32
	#define LUA_BUILD_AS_DLL
#endif
#include <SDL/SDL.h>
#include <lua.h>
#include <lauxlib.h>
#include <math.h>
#include <stdio.h>

static int done = 0;
static SDL_Surface* screen;
static int width=640;
static int height=480;
static int bpp=24;
static int Bpp=3;
static int busy=0;
static unsigned char* image;
static int videoflags=SDL_HWACCEL | SDL_HWSURFACE | SDL_ASYNCBLIT;
static int wait=0;

#if defined(WIN32)
		#include <windows.h>
		#define THREAD DWORD __stdcall
		#define CreateThread(f,p) CreateThread(NULL,0,f,p,0,NULL)
#else
		#include <pthread.h>
		#define THREAD void*

		#define CreateThread(fc,pc) {pthread_t  handle; pthread_create(&handle,0,fc,pc);}
		#define Sleep(x) usleep(x*1000)
		#define CopyMemory memcpy
#endif

#define abort_(str) {printf(str);return 1;}

static int sdl_setpixel(lua_State *L)
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
	if(!done)
	{
		pos=(y*width + x) * Bpp;
		image[pos]=b;
		image[pos+1]=g;
		image[pos+2]=r;
	}
	return 0;
}

static int sdl_getwidth(lua_State *L)
{
	lua_pushinteger(L,width);
	return 1;
}

static int sdl_getheight(lua_State *L)
{
	lua_pushinteger(L,height);
	return 1;
}


static int sdl_setresolution(lua_State *L)
{
	int nw=lua_tonumber(L,1);
	int nh=lua_tonumber(L,2);
	width=nw;
	height=nh;
	/*
	if(nw && nh)
	{
		width=nw;
		height=nh;

		wait=1;

		free(image);
		image=(int*)malloc(width*height*sizeof(int));

		SDL_FreeSurface(screen);
		screen = SDL_SetVideoMode(width, height, bpp, videoflags);
		if(!screen)
			done = 1;
		else
			wait=0;
	}
	*/
	return 0;
}



THREAD mainloop(void* p)
{
	SDL_Event event;
	
	while(!done)
	{
		if(SDL_PollEvent(&event))
		{
			switch (event.type)
			{
				case SDL_KEYDOWN:
					if(event.key.keysym.sym == SDLK_LALT || event.key.keysym.sym == SDLK_TAB)
						break;
					if(event.key.keysym.sym == SDLK_RETURN)
					{
						videoflags ^= SDL_FULLSCREEN;
						SDL_FreeSurface(screen);
						screen = SDL_SetVideoMode(width, height, bpp, videoflags);
						if(!screen)
							done = 1;
						break;
					}
					if(event.key.keysym.sym == SDLK_ESCAPE)
						done=1;
					break;
				case SDL_MOUSEBUTTONDOWN:
					break;
				case SDL_MOUSEMOTION:
					break;
				case SDL_KEYUP:
					break;
				case SDL_QUIT:
					done = 1;
					break;
				default:
					break;
			}
		}
		
		if(!wait)
		{
			SDL_LockSurface(screen);
			memcpy(screen->pixels,image,width*height*Bpp);
			SDL_UnlockSurface(screen);
			SDL_Flip(screen);
		}
		
		Sleep(10);
	}
	
	free(image);
	SDL_FreeSurface(screen);
	SDL_Quit();
	return 0;
}

static int sdl_showsurface(lua_State *L)
{
	const SDL_VideoInfo *info;
	Uint8 * keys;
	int rd=0;

	if(SDL_Init(SDL_INIT_VIDEO) < 0)

	{
		printf("Error: SDL_Init");
		return 1;
	}
	SDL_WM_SetCaption("LuaSDL",NULL);



	info = SDL_GetVideoInfo();

	screen = SDL_SetVideoMode(width, height,bpp, videoflags);
	if(!screen)
	{
		printf("Error: SDL_SetVideoMode");
		return 2;
	}
	image=(unsigned char*)malloc(width*height*Bpp);
	CreateThread(mainloop,0);
	return 0;
}

static int sdl_exit(lua_State *L)
{
	done=1;
	return 0;
}

static int sdl_waitclose(lua_State *L)
{
	while(!done)
		Sleep(100);
	return 0;
}


static const luaL_reg sdllib[] = {
{"setpixel",   sdl_setpixel},
{"getwidth",   sdl_getwidth},
{"getheight",   sdl_getheight},
{"setresolution",   sdl_setresolution},
{"showsurface",sdl_showsurface},
{"exit",sdl_exit},
{"waitclose",sdl_waitclose},
{NULL, NULL}
};

LUALIB_API int luaopen_luasdl (lua_State *L)
{
  
	done = 0;
	screen=0;
	width=640;
	height=480;
	bpp=24;
	Bpp=3;
	busy=0;
	image=0;
	videoflags=SDL_HWACCEL | SDL_HWSURFACE | SDL_ASYNCBLIT;
	wait=0;
	
	luaL_register(L, "luasdl", sdllib);
  return 1;
}

int main()
{
	printf("LuaSDL is a library not a executable\n");
	return 0;
}