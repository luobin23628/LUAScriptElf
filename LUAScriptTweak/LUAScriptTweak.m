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
#import <libactivator/libactivator.h>
#import "CaptureMyScreen.h"
#import "LightMessaging.h"
#import "Global.h"
#import "LuaManager.h"
#import "LUAScripSupport.h"
#import "ProcessHelper.h"

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


static UIAlertView *alertView = nil;

@interface AlertViewDeletege : NSObject <UIAlertViewDelegate>

@end

@implementation AlertViewDeletege

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        
    } else if (buttonIndex == 1) {
//        LMResponseBuffer buffer;
//        kern_return_t ret = LMConnectionSendTwoWayData(&daemonConnection, DaemonConnectionMessageIdRun, NULL, &buffer);
//        if (ret == KERN_SUCCESS) {
//            NSLog(@"run lua success");
//        }
//        LMResponseBufferFree(&buffer);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            system("killall -9 LUAScriptElf;LUAScriptElf /var/touchelf/scripts/fifa15_.lua");
        });
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
}

@end

static AlertViewDeletege *delegate = nil;


static void systemVolumeDidChangeNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @autoreleasepool {
//            LMResponseBuffer buffer;
//            kern_return_t kert = LMConnectionSendTwoWayData(&daemonConnection, DaemonConnectionMessageIdRunStatus, NULL, &buffer);
//            
//            uint32_t length = LMMessageGetDataLength(&buffer.message);
//            
//            
//            NSLog(@"kert === %d, length==== %d", kert, length);
//
//            
//            if (length && kert == KERN_SUCCESS) {
            
            BOOL isRunning = [[ProcessHelper shareInstance] findProcessWithName:@"LUAScriptElf"];
            
                NSLog(@"isRunning === %d", isRunning);
                
                if (isRunning) {
                    
                    
//                    LMResponseBuffer buffer2;
//                    kern_return_t ret = LMConnectionSendTwoWayData(&daemonConnection, DaemonConnectionMessageIdStop, NULL, &buffer2);
//                    if (ret == KERN_SUCCESS) {
//                        NSLog(@"stop lua success");
//                    }
//                    LMResponseBufferFree(&buffer2);
                    
                    system("killall -9 LUAScriptElf;");
                } else {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        NSString *message = @"是否运行lua脚本";
                        delegate = [[AlertViewDeletege alloc] init];
                        alertView = [[UIAlertView alloc] initWithTitle:message message:nil delegate:delegate cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                        [alertView show];
                    });
                }
            }
//            LMResponseBufferFree(&buffer);
//            
//        }
    });
}

static __attribute__((constructor)) void _LUAScriptTweakLocalInit() {
    
    @autoreleasepool {
        CFNotificationCenterRef center = CFNotificationCenterGetLocalCenter();
		CFNotificationCenterAddObserver(center, NULL, systemVolumeDidChangeNotification, CFSTR("AVSystemController_SystemVolumeDidChangeNotification"), NULL, CFNotificationSuspensionBehaviorCoalesce);

        kern_return_t err = LMStartService(tweakConnection.serverName, CFRunLoopGetCurrent(), machPortCallback);
        NSLog(@"StartService err:%d", err);

    }
}
