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

static NSString *encodeToBase64String(UIImage *image) {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

static void processMessage(SInt32 messageId, mach_port_t replyPort, CFDataRef dataRef) {
    
    NSLog(@"LUAScriptTweak processMessage messageId:%d", (int)messageId);

//    system("LUAScriptElf /var/touchelf/scripts/fifa15.lua YES&");
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    switch (messageId) {
        case GMMessageIdAlertView: {
            NSData *data = (NSData *)dataRef;
            double interval;
            [data getBytes:&interval range:NSMakeRange(0, sizeof(interval))];
            data = [data subdataWithRange:NSMakeRange(sizeof(interval), data.length - sizeof(interval))];
            NSString *message = [[[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding] autorelease];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
            [alertView show];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval/1000 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alertView dismissWithClickedButtonIndex:0 animated:NO];
                [alertView release];
                LMSendReply(replyPort, NULL, 0);
            });
            break;
        }
        default:
            LMSendReply(replyPort, NULL, 0);
            break;
    }
    [pool release];
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


static __attribute__((constructor)) void _LUAScriptTweakLocalInit() {
    
    @autoreleasepool {
        kern_return_t err = LMStartService(connection.serverName, CFRunLoopGetCurrent(), machPortCallback);
        NSLog(@"StartService err:%d", err);
    }
}
