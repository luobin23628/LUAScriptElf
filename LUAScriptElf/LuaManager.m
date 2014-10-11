//
//  LuaManager.m
//  Lua on iOS
//

#import "LuaManager.h"

#define to_cString(s) ([s cStringUsingEncoding:[NSString defaultCStringEncoding]])


@interface LuaManager ()

@property (nonatomic) lua_State *state;

@end


@implementation LuaManager

+ (instancetype)shareInstance {
    static LuaManager *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[LuaManager alloc] init];
    });
    return shareInstance;
}

- (lua_State *)state {
    if (!_state) {
        _state = luaL_newstate();
        luaL_openlibs(_state);
        lua_settop(_state, 0);
    }

    return _state;
}

- (void)runCodeFromString:(NSString *)code {
    // get state
    lua_State *L = self.state;

    // compile
    int error = luaL_loadstring(L, to_cString(code));
    if (error) {
        luaL_error(L, "cannot compile Lua code: %s", lua_tostring(L, -1));
        return;
    }

    // run
    error = lua_pcall(L, 0, 0, 0);
    if (error) {
        luaL_error(L, "cannot run Lua code: %s", lua_tostring(L, -1));
        return;
    }
}

static NSUncaughtExceptionHandler * orig_exception_handler = NULL;
static NSString *exception_handler_error = NULL;

static void lua_exception_handler(NSException *exception)
{
    NSLog(@"Lua exception:%@", exception_handler_error);
    if (orig_exception_handler) {
        orig_exception_handler(exception);
    }
}

- (void)runCodeFromFileWithPath:(NSString *)path {
    
    orig_exception_handler = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(lua_exception_handler);
    
    // get state
    lua_State *L = self.state;
    
    // compile
    int error = luaL_loadfile(L, to_cString(path));
    if (error) {
        luaL_error(L, "cannot compile Lua file: %s", lua_tostring(L, -1));
        goto skip;
    }
    
    // run
    error = lua_pcall(L, 0, 0, 0);
    if (error) {
        luaL_error(L, "cannot run Lua code: %s", lua_tostring(L, -1));
        goto skip;
    }
skip:
    
    NSSetUncaughtExceptionHandler(orig_exception_handler);
    orig_exception_handler = NULL;
    exception_handler_error = NULL;
}

- (void)registerFunction:(lua_CFunction)function withName:(NSString *)name {
    lua_register(self.state, to_cString(name), function);
}


static jmp_buf place;
static bool stop;

static void hook(lua_State* L, lua_Debug *ar) {
    if (stop) {
        longjmp(place, 1);
    }
}

- (void)stop {
    stop = YES;
}

- (void)callFunctionNamed:(NSString *)name withObject:(NSObject *)object {
    // get state
    lua_State *L = self.state;
    
    // prepare for "function(object)"
    lua_getglobal(L, to_cString(name));
    lua_pushlightuserdata(L, (__bridge void *)(object));
    
    lua_sethook(L, hook, LUA_MASKCOUNT, 100);
    setjmp(place);
    // run
    int error = lua_pcall(L, 1, 0, 0);
    if (error) {
        luaL_error(L, "cannot run Lua code: %s", lua_tostring(L, -1));
        return;
    }
}

@end
