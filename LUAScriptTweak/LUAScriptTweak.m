//
//  LUAScriptTweak.m
//  LUAScriptTweak
//
//  Created by luobin on 14-10-4.
//  Copyright (c) 2014年 __MyCompanyName__. All rights reserved.
//

// LibActivator by Ryan Petrich
// See https://github.com/rpetrich/libactivator

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LightMessaging.h"
#import "Global.h"
#import "LuaManager.h"
#import "LUAScripSupport.h"
#import "ProcessHelper.h"
#include <substrate.h>
#import <GraphicsServices/GraphicsServices.h>
#import "NSTimer+Blocks.h"
#import <IOKit/hid/IOHIDEvent.h>


static NSString *scriptPath = nil;

static void processMessage(SInt32 messageId, mach_port_t replyPort, CFDataRef dataRef) {
    
    NSLog(@"LUAScriptTweak processMessage messageId:%d", (int)messageId);
    @autoreleasepool {
        switch (messageId) {
            case TweakMessageIdAlertView: {
                NSData *data = (__bridge NSData *)dataRef;
                double interval;
                [data getBytes:&interval range:NSMakeRange(0, sizeof(interval))];
                data = [data subdataWithRange:NSMakeRange(sizeof(interval), data.length - sizeof(interval))];
                NSString *message = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
                [alertView show];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval/1000 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [alertView dismissWithClickedButtonIndex:0 animated:NO];
                    LMSendReply(replyPort, NULL, 0);
                });
                break;
            }
            case TweakMessageIdReportError: {
                NSData *data = (__bridge NSData *)dataRef;
                NSString *message = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
                LMSendReply(replyPort, NULL, 0);
                
                break;
            }
            case TweakMessageIdSetScriptPath: {
                NSData *data = (__bridge NSData *)dataRef;
                NSString *path = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
                scriptPath = path;
                LMSendReply(replyPort, NULL, 0);
                
                break;
            }
            default:
                LMSendReply(replyPort, NULL, 0);
                break;
        }
    }
}

static void machPortCallback(CFMachPortRef port, void *bytes, CFIndex size, void *info) {
	LMMessage *request = bytes;
	if (size < sizeof(LMMessage)) {
		LMSendReply(request->head.msgh_remote_port, NULL, 0);
		LMResponseBufferFree(bytes);
		return;
	}
	// Send Response
	const void *data = LMMessageGetData(request);
	size_t length = LMMessageGetDataLength(request);
	mach_port_t replyPort = request->head.msgh_remote_port;
	CFDataRef cfdata = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, data ?: &data, length, kCFAllocatorNull);
	processMessage(request->head.msgh_id, replyPort, cfdata);
	if (cfdata)
		CFRelease(cfdata);
	LMResponseBufferFree(bytes);
}


static UIAlertView *runAlertView = nil;
static UIAlertView *cancelAlertView = nil;

@interface AlertViewDeletege : NSObject <UIAlertViewDelegate>

@end

@implementation AlertViewDeletege

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"buttonIndex == %d", buttonIndex);
    
    if (buttonIndex == 0) {
        
    } else if (buttonIndex == 1) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            if (scriptPath) {
//                system("LUAScriptElf /var/touchelf/scripts/fifa15_.lua");
                
                system([[NSString stringWithFormat:@"LUAScriptElf %@", scriptPath] UTF8String]);
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    NSString *message = [NSString stringWithFormat:@"%@播放结束", scriptPath];

                    cancelAlertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [cancelAlertView show];
                });
            }
        });
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    cancelAlertView = nil;
    runAlertView = nil;
}

@end

static AlertViewDeletege *delegate = nil;

static void handleVolumeDownButtonLongPress()
{
    if (!scriptPath || cancelAlertView || runAlertView) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        @autoreleasepool {
            
            pid_t pid = [[ProcessHelper shareInstance] findProcessWithName:@"LUAScriptElf"];
            
            if (pid > 0) {
                kill(pid, SIGKILL);
            } else {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if (scriptPath) {
                        NSString *message = [NSString stringWithFormat:@"是否运行%@", scriptPath];
                        delegate = [[AlertViewDeletege alloc] init];
                        runAlertView = [[UIAlertView alloc] initWithTitle:message message:nil delegate:delegate cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                        [runAlertView show];
                    }
                });
            }
        }
    });
}

@class SpringBoard;

static void (*origVolumeChanged)(SpringBoard*, SEL, GSEventRef);

static NSTimer *timer = nil;
static void volumeChanged(SpringBoard* self, SEL _cmd, GSEventRef gsEvent) {
    NSLog(@"volumeChanged:%d", GSEventGetType(gsEvent));
    
    switch (GSEventGetType(gsEvent)) {
		case kGSEventVolumeUpButtonDown: {
            
			break;
		}
		case kGSEventVolumeUpButtonUp: {
            
			break;
		}
		case kGSEventVolumeDownButtonDown: {
            [timer invalidate];
            timer = [NSTimer scheduledTimerWithTimeInterval:0.8 block:^{
                handleVolumeDownButtonLongPress();
            }
                                                    repeats:NO];
			break;
		}
		case kGSEventVolumeDownButtonUp: {
            if (timer) {
                [timer invalidate];
                timer = nil;
            }
			break;
		}
		default:
			break;
	}
	origVolumeChanged(self, _cmd, gsEvent);
}


static BOOL (*origin_volumeChanged)(SpringBoard*, SEL, IOHIDEventRef);

static BOOL _volumeChanged(SpringBoard* self, SEL _cmd, IOHIDEventRef event) {
    NSLog(@"-[<SpringBoard: %p> _volumeChanged:%@]", self, event);
    
    if(IOHIDEventGetType(event) == kIOHIDEventTypeKeyboard) {
        int usage = IOHIDEventGetIntegerValue(event, kIOHIDEventFieldKeyboardUsage);
        //音量-
        if (usage == 0xea) {
            int isDown = IOHIDEventGetIntegerValue(event, kIOHIDEventFieldKeyboardDown);
            if (isDown) {
                [timer invalidate];
                timer = [NSTimer scheduledTimerWithTimeInterval:0.8
                                                          block:^{
                                                              handleVolumeDownButtonLongPress();
                                                          }
                                                        repeats:NO];
            } else {
                if (timer) {
                    [timer invalidate];
                    timer = nil;
                }
            }
        }
    }
    
    return origin_volumeChanged(self, _cmd, event);
}


static __attribute__((constructor)) void _LUAScriptTweakLocalInit() {
    @autoreleasepool {
        //for ios 6
        MSHookMessageEx(objc_getClass("SpringBoard"), @selector(volumeChanged:), (IMP)&volumeChanged, (IMP*)&origVolumeChanged);
        
        //for ios 7 +
        MSHookMessageEx(objc_getClass("SpringBoard"), @selector(_volumeChanged:), (IMP)&_volumeChanged, (IMP*)&origin_volumeChanged);
        
        
        kern_return_t err = LMStartService(tweakConnection.serverName, CFRunLoopGetCurrent(), machPortCallback);
        NSLog(@"StartService err:%d", err);
    }
}
