
//
//  LUAScripEngine.m
//  LUAScriptElf
//
//  Created by LuoBin on 14-9-26.
//
//

#import "LUAScripSupport.h"
#import "LuaManager.h"
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "GraphicsServices/GraphicsServices.h"
#import "UIImageAddition.h"
#import "UIFakeKeypress.h"
#import "AppUtil.h"
#import "UIColorAddition.h"
#import "HIDManager.h"
#import <SimulateTouch.h>
#import "MemoryUtil.h"
#import "AppUtil.h"
#import <libactivator/libactivator.h>
#import "LightMessaging.h"
#import "Global.h"

static BOOL keepScreen;
static NSInteger rotateDegree;

static void rotatePosition(CGFloat *x, CGFloat *y) {
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGFloat scale = [UIScreen mainScreen].scale;
    
    NSInteger width = (NSInteger)ceil(bounds.size.width * scale);
    NSInteger height = (NSInteger)ceil(bounds.size.height * scale);

    switch (rotateDegree) {
        case -90:
        {
            CGFloat tempX = *x;
            *x = *y;
            *y = height - tempX - 1;
            break;
        }
            break;
        case 90:
        {
            CGFloat tempX = *x;
            *x = width - (*y) - 1;
            *y = tempX;
            break;
        }
        
        case 180:
        {
            *x = width - (*x) - 1;
            *y = height - (*y) - 1;
            break;
        }
            break;
        case 0:
        default:
            break;
    }
}

static UIImage *getScreenUIImage() {
    @autoreleasepool {
        static UIImage *image = nil;
        if (!image || !keepScreen) {
            image = [UIImage screenshot];
        }
        return image;
    }
}

extern void AudioServicesPlaySystemSoundWithVibration(SystemSoundID inSystemSoundID,id arg,NSDictionary* vibratePattern);
extern void AudioServicesStopSystemSound(SystemSoundID inSystemSoundID);

static int l_logDebug(lua_State *L) {
    @autoreleasepool {
        const char *s = lua_tostring(L, 1);
        if (s) {
            NSString *message = [NSString stringWithUTF8String:s];
            NSLog(@"%@", message);
        }
    }
    return 0;
}

static int l_mSleep(lua_State *L) {
    @autoreleasepool {
        double x = lua_tonumber(L, 1);
        [NSThread sleepForTimeInterval:x/1000.0];
    }
    return 0;
}

static int l_notifyMessage(lua_State *L) {
    @autoreleasepool {
        const char *s = lua_tostring(L, 1);
        if (s) {
            NSString *message = [NSString stringWithUTF8String:s];
            double interval = lua_tonumber(L, 2);
            if (interval == 0) {
                interval = 1000.f;
            }
            
            NSMutableData *data = [NSMutableData data];
            [data appendBytes:&interval length:sizeof(interval)];
            [data appendData:[message dataUsingEncoding:NSUTF8StringEncoding]];
            
            LMResponseBuffer buffer;
            
            kern_return_t ret = LMConnectionSendTwoWayData(&connection, GMMessageIdAlertView, (__bridge CFDataRef)data, &buffer);
            
            if (ret == KERN_SUCCESS) {
                NSLog(@"KERN_SUCCESS");
            }
        }
    }
    return 0;
}

static int l_notifyVibrate(lua_State *L) {
    @autoreleasepool {
        double duration = lua_tonumber(L, 1);
        if (duration == 0) {
            duration = 1000;
        }
        
        //        if([[UIDevice currentDevice].model isEqualToString:@"iPhone"])
        //        {
        //            AudioServicesPlaySystemSound (kSystemSoundID_Vibrate); //works ALWAYS as of this post
        //        }
        //        else
        //        {
        //            // Not an iPhone, so doesn't have vibrate
        //            // play the less annoying tick noise or one of your own
        //            AudioServicesPlayAlertSound (1105);
        //        }
        
        
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        NSMutableArray* arr = [NSMutableArray array ];
        
        [arr addObject:[NSNumber numberWithBool:YES]]; //vibrate for 2000ms
        [arr addObject:[NSNumber numberWithDouble:duration]];
        
        [dict setObject:arr forKey:@"VibePattern"];
        [dict setObject:[NSNumber numberWithInt:1] forKey:@"Intensity"];
        
        AudioServicesStopSystemSound(kSystemSoundID_Vibrate);
        AudioServicesPlaySystemSoundWithVibration(kSystemSoundID_Vibrate,nil,dict);
    }
    return 0;
}

static int l_notifyVoice(lua_State *L) {
    @autoreleasepool {
        const char *s = lua_tostring(L, 1);
        if (s) {
            NSString *path = [NSString stringWithUTF8String:s];
            if (path) {
                SystemSoundID soundID = 0;
                AudioServicesCreateSystemSoundID( (__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID );
                AudioServicesPlaySystemSound(soundID);
                AudioServicesDisposeSystemSoundID(soundID);
            }
        }
    }
    return 0;
}

#import <dlfcn.h>
#define SBSERVPATH  "/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices"

static int l_touchDown(lua_State *L) {
    @autoreleasepool {
        NSInteger ID = lua_tointeger(L, 1);
        CGFloat x = lua_tonumber(L, 2);
        CGFloat y = lua_tonumber(L, 3);
        rotatePosition(&x, &y);
        
        CGFloat scale = [UIScreen mainScreen].scale;
        CGPoint point = CGPointMake(x/scale, y/scale);
        int r = [SimulateTouch simulateTouch:ID atPoint:point withType:STTouchDown];
        lua_pushinteger(L, r);
    }
    return 1;
}

static int l_touchMove(lua_State *L) {
    @autoreleasepool {
        NSInteger ID = lua_tointeger(L, 1);
        CGFloat x = lua_tonumber(L, 2);
        CGFloat y = lua_tonumber(L, 3);
        rotatePosition(&x, &y);
        
        CGPoint point = CGPointMake(x, y);
        [SimulateTouch simulateTouch:ID atPoint:point withType:STTouchMove];
    }
    return 0;
}

static int l_touchUp(lua_State *L) {
    @autoreleasepool {
        NSInteger ID = lua_tointeger(L, 1);
        CGFloat x = lua_tonumber(L, 2);
        CGFloat y = lua_tonumber(L, 3);
        rotatePosition(&x, &y);
        
        CGFloat scale = [UIScreen mainScreen].scale;
        CGPoint point = CGPointMake(x/scale, y/scale);
        [SimulateTouch simulateTouch:ID atPoint:point withType:STTouchUp];
    }
    return 0;
}

static int l_keyDown(lua_State *L) {
    @autoreleasepool {
        const char *s = lua_tostring(L, 1);
        if (s) {
            NSString *keyName = [NSString stringWithUTF8String:s];
            if ([[keyName uppercaseString] isEqualToString:@"HOME"]) {
            }
        }
    }
    return 0;
}

static int l_keyUp(lua_State *L) {
    @autoreleasepool {
        const char *s = lua_tostring(L, 1);
        if (s) {
            NSString *keyName = [NSString stringWithUTF8String:s];
            if ([[keyName uppercaseString] isEqualToString:@"HOME"]) {
                
            }
        }
    }
    return 0;
}

static int l_getColor(lua_State *L) {
    @autoreleasepool {
        CGFloat x = lua_tonumber(L, 1);
        CGFloat y = lua_tonumber(L, 2);
        rotatePosition(&x, &y);
        
        UIImage *image = getScreenUIImage();
        
        UIColor *color = [image getPixelColorAtLocation:CGPointMake(x, y)];
        unsigned char components[4];
        [color getRGBComponents:components];
        
        NSUInteger r = components[0]<<16;
        NSUInteger g = components[1]<<8;
        NSUInteger b = components[2];
        
        lua_pushinteger(L, r + g + b);
    }
    return 1;
}

static int l_getColorRGB(lua_State *L) {
    @autoreleasepool {
        CGFloat x = lua_tonumber(L, 1);
        CGFloat y = lua_tonumber(L, 2);
        rotatePosition(&x, &y);
        
        UIImage *image = getScreenUIImage();
        
        UIColor *color = [image getPixelColorAtLocation:CGPointMake(x, y)];
        unsigned char components[4];
        [color getRGBComponents:components];
        
        lua_pushinteger(L, components[0]);
        lua_pushinteger(L, components[1]);
        lua_pushinteger(L, components[2]);
    }
    return 3;
}

static int l_findColor(lua_State *L) {
    @autoreleasepool {
        NSInteger color = lua_tointeger(L, 1);
        
        UIImage *image = getScreenUIImage();
        CGPoint point = [image findColor:[UIColor colorWithRed:(color&0xFF0000)/255.0 green:(color&0x00FF00)/255.0 blue:(color&0x0000FF)/255.0 alpha:1]];
        if (point.x != NSNotFound && point.y != NSNotFound) {
            rotatePosition(&point.x, &point.y);
            
            lua_pushnumber(L, point.x);
            lua_pushnumber(L, point.y);
        } else {
            lua_pushnumber(L, -1);
            lua_pushnumber(L, -1);
        }
    }
    return 2;
}

static int l_findColorFuzzy(lua_State *L) {
    @autoreleasepool {
        NSInteger color = lua_tointeger(L, 1);
        
        CGFloat offset = lua_tonumber(L, 4);
        
        unsigned char r = color & 0xFF0000 >> 16;
        unsigned char g = color & 0x00FF00 >> 8;
        unsigned char b = color & 0x0000FF;
        
        UIImage *image = getScreenUIImage();
        CGPoint point = [image findColor:[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1] fuzzyOffset:offset];
        if (point.x != NSNotFound && point.y != NSNotFound) {
            rotatePosition(&point.x, &point.y);
            
            lua_pushnumber(L, point.x);
            lua_pushnumber(L, point.y);
        } else {
            lua_pushnumber(L, -1);
            lua_pushnumber(L, -1);
            
        }
    }
    return 2;
}

static CGPoint findColorInRegion(NSInteger color, CGFloat x1, CGFloat y1, CGFloat x2, CGFloat y2, NSInteger offset) {
    @autoreleasepool {
        rotatePosition(&x1, &y2);
        rotatePosition(&x2, &y2);
        
        if (x1 >= x2 || y1 >= y2) {
            return CGPointMake(NSNotFound, NSNotFound);
        }
        
        unsigned char r = color & 0xFF0000 >> 16;
        unsigned char g = color & 0x00FF00 >> 8;
        unsigned char b = color & 0x0000FF;
        
        UIImage *image = getScreenUIImage();
        image = [image imageWithCrop:CGRectMake(x1, y1, x2 - x1, y2 - y1)];
        CGPoint point =  [image findColor:[UIColor colorWithRed:r/255 green:g/255 blue:b/255 alpha:1] fuzzyOffset:offset];
        if (point.x != NSNotFound && point.y != NSNotFound) {
            point.x += x1;
            point.y += y1;
            rotatePosition(&point.x, &point.y);
            return point;
        } else {
            return point;
        }
    }
}

static int l_findColorInRegion(lua_State *L) {
    @autoreleasepool {
        NSInteger color = lua_tointeger(L, 1);
        
        CGFloat x1 = lua_tonumber(L, 2);
        CGFloat y1 = lua_tonumber(L, 3);
        
        CGFloat x2 = lua_tonumber(L, 4);
        CGFloat y2 = lua_tonumber(L, 5);
        
        CGPoint point = findColorInRegion(color, x1, y1, x2, y2, 0);
        
        if (point.x != NSNotFound && point.y != NSNotFound) {
            
            lua_pushnumber(L, point.x);
            lua_pushnumber(L, point.y);
        } else {
            lua_pushinteger(L, -1);
            lua_pushinteger(L, -1);
        }
    }
    return 2;
}

static int l_findColorInRegionFuzzy(lua_State *L) {
    @autoreleasepool {
        NSInteger color = lua_tointeger(L, 1);
        
        unsigned char x1 = lua_tonumber(L, 2);
        unsigned char y1 = lua_tonumber(L, 3);
        
        unsigned char x2 = lua_tonumber(L, 4);
        unsigned char y2 = lua_tonumber(L, 5);
        
        NSInteger offset = lua_tointeger(L, 6);
        
        CGPoint point = findColorInRegion(color, x1, y1, x2, y2, offset);
        
        if (point.x != NSNotFound && point.y != NSNotFound) {
            lua_pushnumber(L, point.x);
            lua_pushnumber(L, point.y);
        } else {
            lua_pushinteger(L, -1);
            lua_pushinteger(L, -1);
        }
    }
    
    return 2;
}

static int l_findImage(lua_State *L) {
    
    
    return 0;
}

static int l_findImageFuzzy(lua_State *L) {
    
    
    return 0;
}

static int l_findImageInRegion(lua_State *L) {
    
    
    return 0;
}

static int l_findImageInRegionFuzzy(lua_State *L) {
    
    
    return 0;
}

static int l_snapshotScreen(lua_State *L) {
    
    
    return 0;
}

static int l_snapshotRegion(lua_State *L) {
    
    
    return 0;
}

static int l_localOcrText(lua_State *L) {
    
    lua_pushstring(L, "Unsupport");
    return 1;
}

static int l_keepScreen(lua_State *L) {
    keepScreen = lua_toboolean(L, 1);
    return 0;
}

static int l_rotateScreen(lua_State *L) {
    NSInteger rotate = lua_tointeger(L, 1);
    rotateDegree = rotate;
    return 0;
}

static int l_copyText(lua_State *L) {
    @autoreleasepool {
        
        const char *s = lua_tostring(L, 1);
        if (s) {
            NSString *text = [NSString stringWithUTF8String:s];
            
            
        }
        
        return 0;
    }
}
static int l_inputText(lua_State *L) {
    @autoreleasepool {
        const char *s = lua_tostring(L, 1);
        if (s) {
            NSString *text = [NSString stringWithUTF8String:s];
            sendKeypressForString(text);
        }
    }
    return 0;
}

static int l_appRun(lua_State *L) {
    @autoreleasepool {
        
        const char *s = lua_tostring(L, 1);
        if (s) {
            NSString *appID = [NSString stringWithUTF8String:s];
            [AppUtil launchAppWithIdentifier:appID];
        }
    }
    return 0;
}

static int l_appKill(lua_State *L) {
    @autoreleasepool {
        
        const char *s = lua_tostring(L, 1);
        if (s) {
            NSString *appID = [NSString stringWithUTF8String:s];
            if (appID) {
                pid_t pid = [AppUtil pidForDisplayIdentifier:appID];
                if (pid) {
                    kill(pid, SIGKILL);
                }
            }
        }
    }
    return 0;
}


static int l_appRunning(lua_State *L) {
    @autoreleasepool {
        
        const char *s = lua_tostring(L, 1);
        BOOL isRunning = NO;
        if (s) {
            NSString *appID = [NSString stringWithUTF8String:s];
            pid_t pid = [AppUtil pidForDisplayIdentifier:appID];
            isRunning = pid > 0;
        }
        lua_pushboolean(L, isRunning);
    }
    return 1;
}


static int l_httpGet(lua_State *L) {
    
    return 0;
}


static int l_ftpGet(lua_State *L) {
    
    return 0;
}
static int l_ftpPut(lua_State *L) {
    
    return 0;
}

static int l_memoryRead(lua_State *L) {
    
    /*
     I8: 有符号的8位整数
     I16: 有符号的16位整数
     I32: 有符号的32位整数
     I64: 有符号的64位整数
     U8: 无符号的8位整数
     U16: 无符号的16位整数
     U32: 无符号的32位整数
     U64: 无符号的64位整数
     F32: 有符号的32位浮点数
     F64: 有符号的64位浮点数
     */
    
    const char *a = lua_tostring(L, 1);
    const char *b = lua_tostring(L, 2);
    const char *c = lua_tostring(L, 3);

    if (a && b) {
        NSString *appID = [NSString stringWithUTF8String:a];
        NSString *address = [NSString stringWithUTF8String:b];
        NSString *type = [NSString stringWithUTF8String:c];

        pid_t pid = [AppUtil pidForDisplayIdentifier:appID];
        if (pid) {
            if ([[type uppercaseString] isEqualToString:@"I8"]) {
                int8_t value;
                BOOL ok = [MemoryUtil memoryReadFromPid:pid address:address buffer:&value bufferSize:sizeof(value)];
                if (ok) {
                    lua_pushboolean(L, YES);
                    lua_pushnumber(L, value);
                    return 2;
                }
                
            } else if ([[type uppercaseString] isEqualToString:@"I16"]) {
                int16_t value;
                BOOL ok = [MemoryUtil memoryReadFromPid:pid address:address buffer:&value bufferSize:sizeof(value)];
                if (ok) {
                    lua_pushboolean(L, YES);
                    lua_pushnumber(L, value);
                    return 2;
                }
            } else if ([[type uppercaseString] isEqualToString:@"I64"]) {
                int64_t value;
                BOOL ok = [MemoryUtil memoryReadFromPid:pid address:address buffer:&value bufferSize:sizeof(value)];
                if (ok) {
                    lua_pushboolean(L, YES);
                    lua_pushnumber(L, value);
                    return 2;
                }
            } else if ([[type uppercaseString] isEqualToString:@"U16"]) {
                uint16_t value;
                BOOL ok = [MemoryUtil memoryReadFromPid:pid address:address buffer:&value bufferSize:sizeof(value)];
                if (ok) {
                    lua_pushboolean(L, YES);
                    lua_pushnumber(L, value);
                    return 2;
                }
            } else if ([[type uppercaseString] isEqualToString:@"U32"]) {
                uint32_t value;
                BOOL ok = [MemoryUtil memoryReadFromPid:pid address:address buffer:&value bufferSize:sizeof(value)];
                if (ok) {
                    lua_pushboolean(L, YES);
                    lua_pushnumber(L, value);
                    return 2;
                }
            } else if ([[type uppercaseString] isEqualToString:@"U64"]) {
                uint64_t value;
                BOOL ok = [MemoryUtil memoryReadFromPid:pid address:address buffer:&value bufferSize:sizeof(value)];
                if (ok) {
                    lua_pushboolean(L, YES);
                    lua_pushnumber(L, value);
                    return 2;
                }
            } else if ([[type uppercaseString] isEqualToString:@"F32"]) {
                Float32 value;
                BOOL ok = [MemoryUtil memoryReadFromPid:pid address:address buffer:&value bufferSize:sizeof(value)];
                if (ok) {
                    lua_pushboolean(L, YES);
                    lua_pushnumber(L, value);
                    return 2;
                }
            } else if ([[type uppercaseString] isEqualToString:@"F64"]) {
                Float64 value;
                BOOL ok = [MemoryUtil memoryReadFromPid:pid address:address buffer:&value bufferSize:sizeof(value)];
                if (ok) {
                    lua_pushboolean(L, YES);
                    lua_pushnumber(L, value);
                    return 2;
                }
            } else {
                int32_t value;
                BOOL ok = [MemoryUtil memoryReadFromPid:pid address:address buffer:&value bufferSize:sizeof(value)];
                if (ok) {
                    lua_pushboolean(L, YES);
                    lua_pushnumber(L, value);
                    return 2;
                }
            }
        }
    }
    lua_pushboolean(L, NO);

    return 1;
}

static int l_memoryWrite(lua_State *L) {
    const char *a = lua_tostring(L, 1);
    const char *b = lua_tostring(L, 2);
    const char *c = lua_tostring(L, 4);
    
    if (a && b) {
        NSString *appID = [NSString stringWithUTF8String:a];
        NSString *address = [NSString stringWithUTF8String:b];
        NSString *type = [NSString stringWithUTF8String:c];
        
        pid_t pid = [AppUtil pidForDisplayIdentifier:appID];
        if (pid) {
            
            if ([[type uppercaseString] isEqualToString:@"I8"]) {
                int8_t value = lua_tonumber(L, 3);
                BOOL ok = [MemoryUtil memoryWriteFromPid:pid address:address data:&value dataSize:sizeof(value)];
                if (ok) {
                    lua_pushboolean(L, YES);
                    return 1;
                }
                
            } else if ([[type uppercaseString] isEqualToString:@"I16"]) {
                int16_t value = lua_tonumber(L, 3);
                BOOL ok = [MemoryUtil memoryWriteFromPid:pid address:address data:&value dataSize:sizeof(value)];
                if (ok) {
                    lua_pushboolean(L, YES);
                    return 1;
                }
            } else if ([[type uppercaseString] isEqualToString:@"I64"]) {
                int64_t value = lua_tonumber(L, 3);
                BOOL ok = [MemoryUtil memoryWriteFromPid:pid address:address data:&value dataSize:sizeof(value)];
                if (ok) {
                    lua_pushboolean(L, YES);
                    return 1;
                }
            } else if ([[type uppercaseString] isEqualToString:@"U16"]) {
                uint16_t value = lua_tonumber(L, 3);
                BOOL ok = [MemoryUtil memoryWriteFromPid:pid address:address data:&value dataSize:sizeof(value)];
                if (ok) {
                    lua_pushboolean(L, YES);
                    return 1;
                }
            } else if ([[type uppercaseString] isEqualToString:@"U32"]) {
                uint32_t value = lua_tonumber(L, 3);
                BOOL ok = [MemoryUtil memoryWriteFromPid:pid address:address data:&value dataSize:sizeof(value)];
                if (ok) {
                    lua_pushboolean(L, YES);
                    return 1;
                }
            } else if ([[type uppercaseString] isEqualToString:@"U64"]) {
                uint64_t value = lua_tonumber(L, 3);
                BOOL ok = [MemoryUtil memoryWriteFromPid:pid address:address data:&value dataSize:sizeof(value)];
                if (ok) {
                    lua_pushboolean(L, YES);
                    return 1;
                }
            } else if ([[type uppercaseString] isEqualToString:@"F32"]) {
                Float32 value = lua_tonumber(L, 3);
                BOOL ok = [MemoryUtil memoryWriteFromPid:pid address:address data:&value dataSize:sizeof(value)];
                if (ok) {
                    lua_pushboolean(L, YES);
                    return 1;
                }
            } else if ([[type uppercaseString] isEqualToString:@"F64"]) {
                Float64 value = lua_tonumber(L, 3);
                BOOL ok = [MemoryUtil memoryWriteFromPid:pid address:address data:&value dataSize:sizeof(value)];
                if (ok) {
                    lua_pushboolean(L, YES);
                    return 1;
                }
            } else {
                int32_t value = lua_tonumber(L, 3);
                BOOL ok = [MemoryUtil memoryWriteFromPid:pid address:address data:&value dataSize:sizeof(value)];
                if (ok) {
                    lua_pushboolean(L, YES);
                    return 1;
                }
            }
        }
    }
    lua_pushboolean(L, NO);
    
    return 1;
}

static int l_getScreenResolution(lua_State *L) {
    @autoreleasepool {
        CGRect bounds = [UIScreen mainScreen].bounds;
        CGFloat scale = [UIScreen mainScreen].scale;
        
        bounds = CGRectApplyAffineTransform(bounds, CGAffineTransformMakeRotation(rotateDegree*M_PI/180));
        
        NSInteger width = (NSInteger)ceil(bounds.size.width * scale);
        NSInteger height = (NSInteger)ceil(bounds.size.height * scale);
        
        lua_pushinteger(L, width);
        lua_pushinteger(L, height);
    }
    return 2;
}

static int l_getScreenColorBits(lua_State *L) {
    
    return 0;
}

static int l_getDeviceID(lua_State *L) {
    
    return 0;
}

static int l_getNetTime(lua_State *L) {
    
    return 0;
}

static int l_getVersion(lua_State *L) {
    lua_pushstring(L, "1.0");
    return 1;
}

void registerLUAFunctions(void) {
    @autoreleasepool {
        
        rotateDegree = 0;
        keepScreen = NO;
        
        LuaManager *m = [LuaManager shareInstance];
        
        [m registerFunction:l_logDebug withName:@"logDebug"];
        
        [m registerFunction:l_mSleep withName:@"mSleep"];
        [m registerFunction:l_notifyMessage withName:@"notifyMessage"];
        [m registerFunction:l_notifyVibrate withName:@"notifyVibrate"];
        [m registerFunction:l_notifyVoice withName:@"notifyVoice"];
        [m registerFunction:l_touchDown withName:@"touchDown"];
        [m registerFunction:l_touchMove withName:@"touchMove"];
        [m registerFunction:l_touchUp withName:@"touchUp"];
        [m registerFunction:l_keyDown withName:@"keyDown"];
        [m registerFunction:l_keyUp withName:@"keyUp"];
        
        [m registerFunction:l_getColor withName:@"getColor"];
        [m registerFunction:l_getColorRGB withName:@"getColorRGB"];
        [m registerFunction:l_findColor withName:@"findColor"];
        [m registerFunction:l_findColorFuzzy withName:@"findColorFuzzy"];
        [m registerFunction:l_findColorInRegion withName:@"findColorInRegion"];
        [m registerFunction:l_findColorInRegionFuzzy withName:@"findColorInRegionFuzzy"];
        [m registerFunction:l_findImage withName:@"findImage"];
        [m registerFunction:l_findImageFuzzy withName:@"findImageFuzzy"];
        [m registerFunction:l_findImageInRegion withName:@"findImageInRegion"];
        [m registerFunction:l_findImageInRegionFuzzy withName:@"findImageInRegionFuzzy"];
        [m registerFunction:l_snapshotScreen withName:@"snapshotScreen"];
        [m registerFunction:l_snapshotRegion withName:@"snapshotRegion"];
        
        
        [m registerFunction:l_localOcrText withName:@"localOcrText"];
        
        [m registerFunction:l_keepScreen withName:@"keepScreen"];
        [m registerFunction:l_rotateScreen withName:@"rotateScreen"];
        [m registerFunction:l_copyText withName:@"copyText"];
        [m registerFunction:l_inputText withName:@"inputText"];
        [m registerFunction:l_appRun withName:@"appRun"];
        [m registerFunction:l_appKill withName:@"appKill"];
        [m registerFunction:l_appRunning withName:@"appRunning"];
        
        [m registerFunction:l_httpGet withName:@"httpGet"];
        [m registerFunction:l_ftpGet withName:@"ftpGet"];
        [m registerFunction:l_ftpPut withName:@"ftpPut"];
        
        [m registerFunction:l_memoryRead withName:@"memoryRead"];
        [m registerFunction:l_memoryWrite withName:@"memoryWrite"];
        
        [m registerFunction:l_getScreenResolution withName:@"getScreenResolution"];
        [m registerFunction:l_getScreenColorBits withName:@"getScreenColorBits"];
        [m registerFunction:l_getDeviceID withName:@"getDeviceID"];
        [m registerFunction:l_getNetTime withName:@"getNetTime"];
        [m registerFunction:l_getVersion withName:@"getVersion"];
        
    }
}
