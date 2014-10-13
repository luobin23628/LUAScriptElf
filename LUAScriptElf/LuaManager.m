//
//  LuaManager.m
//  Lua on iOS
//

#import "LuaManager.h"
#import "Global.h"

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
        const char *errorMsg = lua_tostring(L, -1);
        if (errorMsg) {
            [self reportError:[NSString stringWithUTF8String:errorMsg]];
        }
        luaL_error(L, "cannot compile Lua code: %s", errorMsg);
        return;
    }

    // run
    error = lua_pcall(L, 0, 0, 0);
    if (error) {
        const char *errorMsg = lua_tostring(L, -1);
        if (errorMsg) {
            [self reportError:[NSString stringWithUTF8String:errorMsg]];
        }
        luaL_error(L, "cannot run Lua code: %s", errorMsg);
        return;
    }
}

- (void)runCodeFromFileWithPath:(NSString *)path {
    
    // get state
    lua_State *L = self.state;
    
    // compile
    int error = luaL_loadfile(L, to_cString(path));
    if (error) {
        const char *errorMsg = lua_tostring(L, -1);
        if (errorMsg) {
            [self reportError:[NSString stringWithUTF8String:errorMsg]];
        }
        luaL_error(L, "cannot compile Lua file: %s", errorMsg);
    }
    
    // run
    error = lua_pcall(L, 0, 0, 0);
    if (error) {
        const char *errorMsg = lua_tostring(L, -1);
        if (errorMsg) {
            [self reportError:[NSString stringWithUTF8String:errorMsg]];
        }
        luaL_error(L, "cannot run Lua code: %s", errorMsg);
    }
}

- (void)registerFunction:(lua_CFunction)function withName:(NSString *)name {
    lua_register(self.state, to_cString(name), function);
}

- (void)callFunctionNamed:(NSString *)name withObject:(NSObject *)object {
    // get state
    lua_State *L = self.state;
    
    // prepare for "function(object)"
    lua_getglobal(L, to_cString(name));
    lua_pushlightuserdata(L, (__bridge void *)(object));
    
    // run
    int error = lua_pcall(L, 1, 0, 0);
    
    if (error) {
        const char *errorMsg = lua_tostring(L, -1);
        if (errorMsg) {
            [self reportError:[NSString stringWithUTF8String:errorMsg]];
        }
        luaL_error(L, "cannot run Lua code: %s", errorMsg);
        return;
    }
}

- (void)reportError:(NSString *)errorMsg {
    NSData *data = [errorMsg dataUsingEncoding:NSUTF8StringEncoding];
    LMResponseBuffer buffer;
    kern_return_t ret = LMConnectionSendTwoWayData(&tweakConnection, TweakMessageIdReportError, (__bridge CFDataRef)data, &buffer);
    
    if (ret == KERN_SUCCESS) {
        NSLog(@"KERN_SUCCESS");
    }
}

@end
