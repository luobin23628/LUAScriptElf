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


static NSString *encodeToBase64String(UIImage *image) {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

static void processMessage(SInt32 messageId, mach_port_t replyPort, CFDataRef dataRef) {
    
    NSLog(@"LUAScriptTweak processMessage messageId:%d", (int)messageId);
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    switch (messageId) {
        case GMMessageIdGetScreenUIImage: {
            UIImage *image = [_UICreateScreenUIImage() autorelease];
//            NSData *data = UIImagePNGRepresentation(image);
            NSData *data = [encodeToBase64String(image) dataUsingEncoding:NSUTF8StringEncoding];
            LMSendCFDataReply(replyPort, (CFDataRef)data);
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
    }
}
