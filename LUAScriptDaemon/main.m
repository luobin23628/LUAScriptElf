//
//  main.m
//  LUAScriptDaemon
//
//  Created by LuoBin on 14-10-11.
//  Copyright (c) 2014年 __MyCompanyName__. All rights reserved.
//

// XPC Service: Lightweight helper tool that performs work on behalf of an application.
// see http://developer.apple.com/library/mac/#documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingXPCServices.html

#include <Foundation/Foundation.h>
#import "LightMessaging.h"
#import "Global.h"
#import "LUAScripSupport.h"
#import "LuaManager.h"
#import <AVFoundation/AVFoundation.h>

@interface WorkThread : NSThread

@end

static WorkThread *workThread = nil;

@implementation WorkThread

- (void)main {
    @autoreleasepool {
        CFRunLoopRun();
    }
}

- (void)runLuaScript {
    [workThread performSelector:@selector(doRunLuaScript) onThread:workThread withObject:nil waitUntilDone:NO];
}

- (void)doRunLuaScript {
    
    NSString *path = [NSString stringWithUTF8String:"/var/touchelf/scripts/fifa15_.lua"];
    [[LuaManager shareInstance] runCodeFromFileWithPath:path];
    [[LuaManager shareInstance] callFunctionNamed:@"main" withObject:nil];
}

- (void)stopLuaScript {
    [[LuaManager shareInstance] stop];
}

@end

static void volumeListenerCallback (void *inClientData,
                             AudioSessionPropertyID inID,
                             UInt32 inDataSize,
                             const void *inData
                             ){
 
    const float *volumePointer = inData;
    float volume = *volumePointer;
    NSLog(@"systemVolumeDidChangeNotification volume:%.f", volume);
}

static BOOL isRunning = false;

static void processMessage(SInt32 messageId, mach_port_t replyPort, CFDataRef dataRef) {
    
    NSLog(@"processMessage messageId:%d", (int)messageId);
    
    @autoreleasepool {
        switch (messageId) {
            case DaemonConnectionMessageIdRun: {
                if (workThread == nil) {
                    workThread = [[WorkThread alloc] init];
                    [workThread start];
                }
                isRunning = YES;
                [workThread runLuaScript];
                LMSendReply(replyPort, NULL, 0);
                break;
            }
            case DaemonConnectionMessageIdStop: {
                LMSendReply(replyPort, NULL, 0);
                exit(0);
                break;
            }
            case DaemonConnectionMessageIdRunStatus: {
                NSLog(@"DaemonConnectionMessageIdRunStatus isRunning:%d", isRunning);
                LMSendIntegerReply(replyPort, isRunning);
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

int main(int argc, const char *argv[])
{
    @autoreleasepool {
        registerLUAFunctions();
        
        NSLog(@"Service start...");
        while (YES) {
            
            kern_return_t err = LMStartService(daemonConnection.serverName, CFRunLoopGetCurrent(), machPortCallback);
            if (err) {
                NSLog(@"Unable to register mach server with error %x", err);
                [NSThread sleepForTimeInterval:60];
            } else {
                NSLog(@"Register mach server:%s with succeed.", daemonConnection.serverName);
                [[NSRunLoop currentRunLoop] run];
            }
        }
        NSLog(@"Service end...");
    }
    return EXIT_SUCCESS;
}
