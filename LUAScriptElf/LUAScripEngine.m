
//
//  LUAScripEngine.m
//  LUAScriptElf
//
//  Created by LuoBin on 14-9-26.
//
//

#import "LUAScripEngine.h"
#import "LuaManager.h"
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "GraphicsServices.h"

extern void AudioServicesPlaySystemSoundWithVibration(SystemSoundID inSystemSoundID,id arg,NSDictionary* vibratePattern);
extern void AudioServicesStopSystemSound(SystemSoundID inSystemSoundID);


static int l_mSleep(lua_State *L) {
    double x = lua_tonumber(L, 1);
    [NSThread sleepForTimeInterval:x/1000.0];
    return 0;
}

int l_notifyMessage(lua_State *L) {
    NSString *message = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    double interval = lua_tonumber(L, 2);
    if (interval == 0) {
        interval = 1000.f;
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alertView show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval/1000 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alertView dismissWithClickedButtonIndex:0 animated:NO];
    });
    
    return 0;
}

int l_notifyVibrate(lua_State *L) {
    double duration = lua_tonumber(L, 1);
    if (duration == 0) {
        duration = 1000;
    }
    
//    if([[UIDevice currentDevice].model isEqualToString:@"iPhone"])
//    {
//        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate); //works ALWAYS as of this post
//    }
//    else
//    {
//        // Not an iPhone, so doesn't have vibrate
//        // play the less annoying tick noise or one of your own
//        AudioServicesPlayAlertSound (1105);
//    }
    
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    NSMutableArray* arr = [NSMutableArray array ];
    
    [arr addObject:[NSNumber numberWithBool:YES]]; //vibrate for 2000ms
    [arr addObject:[NSNumber numberWithDouble:duration]];
  
    [dict setObject:arr forKey:@"VibePattern"];
    [dict setObject:[NSNumber numberWithInt:1] forKey:@"Intensity"];
    
    AudioServicesPlaySystemSoundWithVibration(kSystemSoundID_Vibrate,nil,dict);
    
    AudioServicesStopSystemSound(kSystemSoundID_Vibrate);
    
    return 0;
}

int l_notifyVoice(lua_State *L) {
    NSString *path = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    if (path) {
        SystemSoundID soundID = 0;
        AudioServicesCreateSystemSoundID( (__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID );
        AudioServicesPlaySystemSound(soundID);
        AudioServicesDisposeSystemSoundID(soundID);
    }
    return 0;
}

#import <dlfcn.h>
#define SBSERVPATH  "/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices"

static mach_port_t getFrontmostAppPort() {
    mach_port_t *port;
    void *lib = dlopen(SBSERVPATH, RTLD_LAZY);
    int (*SBSSpringBoardServerPort)() = dlsym(lib, "SBSSpringBoardServerPort");
    port = (mach_port_t *)SBSSpringBoardServerPort();
    dlclose(lib);
    
    void *(*SBFrontmostApplicationDisplayIdentifier)(mach_port_t *port, char *result) = dlsym(lib, "SBFrontmostApplicationDisplayIdentifier");
    
    char appId[256];
    memset(appId, 0, sizeof(appId));
    SBFrontmostApplicationDisplayIdentifier(port, appId);
    
    return GSCopyPurpleNamedPort(appId);
}

static void sendTouchEvent(NSInteger ID, CGPoint point, UITouchPhase phase) {
    uint8_t touchEvent[sizeof(GSEventRecord) + sizeof(GSHandInfo) + sizeof(GSPathInfo)];
    struct GSTouchEvent {
        GSEventRecord record;
        GSHandInfo    handInfo;
    } * event = (struct GSTouchEvent*) &touchEvent;
    bzero(event, sizeof(event));
    
    event->record.type = kGSEventHand;
    event->record.subtype = kGSEventSubTypeUnknown;
    event->record.location = point;
    event->record.timestamp = GSCurrentEventTimestamp();
    event->record.infoSize = sizeof(GSHandInfo) + sizeof(GSPathInfo);
    
    event->handInfo.type = (phase == UITouchPhaseBegan) ? kGSHandInfoTypeTouchDown : kGSHandInfoTypeTouchUp;
    event->handInfo.pathInfosCount = 1;
    
    bzero(&event->handInfo.pathInfos[0], sizeof(GSPathInfo));
    event->handInfo.pathInfos[0].pathIndex     = 1;
    event->handInfo.pathInfos[0].pathIdentity  = 2;
    event->handInfo.pathInfos[0].pathProximity = (phase == UITouchPhaseBegan) ? 0x03 : 0x00;
    event->handInfo.pathInfos[0].pathLocation  = point;

    mach_port_t port = getFrontmostAppPort();
    GSEventRecord* record = (GSEventRecord*)event;
    record->timestamp = GSCurrentEventTimestamp();
    GSSendEvent(record, port);
}


static int l_touchDown(lua_State *L) {
    NSInteger ID = lua_tointeger(L, 1);
    double x = lua_tonumber(L, 2);
    double y = lua_tonumber(L, 3);
    
    CGPoint point = CGPointMake(x, y);
    sendTouchEvent(ID, point, UITouchPhaseBegan);
    return 0;
}

int l_touchMove(lua_State *L) {
    double ID = lua_tointeger(L, 1);
    double x = lua_tonumber(L, 2);
    double y = lua_tonumber(L, 3);
    
    CGPoint point = CGPointMake(x, y);
    sendTouchEvent(ID, point, UITouchPhaseMoved);
    
    return 0;
}

int l_touchUp(lua_State *L) {
    double ID = lua_tointeger(L, 1);
    
    CGPoint point = CGPointMake(0, 0);
    sendTouchEvent(ID, point, UITouchPhaseEnded);

    return 0;
}

int l_keyDown(lua_State *L) {
    NSString *keyName = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    if ([[keyName uppercaseString] isEqualToString:@"HOME"]) {
        
    }
    return 0;
}

int l_keyUp(lua_State *L) {
    NSString *keyName = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    if ([[keyName uppercaseString] isEqualToString:@"HOME"]) {
        
    }
    return 0;
}

@implementation LUAScripEngine

- (void)registerFunctions {
    LuaManager *m = [[LuaManager alloc] init];

    [m registerFunction:l_mSleep withName:@"mSleep"];
    [m registerFunction:l_notifyMessage withName:@"notifyMessage"];
    [m registerFunction:l_notifyVibrate withName:@"notifyVibrate"];
    [m registerFunction:l_notifyVoice withName:@"notifyVoice"];
    [m registerFunction:l_touchDown withName:@"touchDown"];
    [m registerFunction:l_touchMove withName:@"touchMove"];
    [m registerFunction:l_touchUp withName:@"touchUp"];
    [m registerFunction:l_keyDown withName:@"keyDown"];
    [m registerFunction:l_keyUp withName:@"keyUp"];

    
}

@end
