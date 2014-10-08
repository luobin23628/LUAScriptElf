#ifndef __APPLE_API_PRIVATE
#define __APPLE_API_PRIVATE
#include "sandbox.h"
#undef __APPLE_API_PRIVATE
#else
#include "sandbox.h"
#endif

#ifndef LIGHTMESSAGING_USE_ROCKETBOOTSTRAP
#define LIGHTMESSAGING_USE_ROCKETBOOTSTRAP 1
#endif

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>
#include <mach/mach.h>
#include <mach/mach_init.h>
#if LIGHTMESSAGING_USE_ROCKETBOOTSTRAP
#include "RocketBootstrap/rocketbootstrap.h"
#else
#include "bootstrap.h"
#endif

typedef struct {
	mach_port_t serverPort;
	name_t serverName;
} LMConnection;
typedef LMConnection *LMConnectionRef;

#define __LMMaxInlineSize 4096 + sizeof(LMMessage)
typedef struct __LMMessage {
	mach_msg_header_t head;
	mach_msg_body_t body;
	union {
		struct {
			mach_msg_ool_descriptor_t descriptor;
		} out_of_line;
		struct {
			uint32_t length;
			uint8_t bytes[0];
		} in_line;
	} data;
} LMMessage;

typedef struct __LMResponseBuffer {
	LMMessage message;
	uint8_t slack[__LMMaxInlineSize - sizeof(LMMessage) + MAX_TRAILER_SIZE];
} LMResponseBuffer;

 uint32_t LMBufferSizeForLength(uint32_t length);

 void LMMessageCopyInline(LMMessage *message, const void *data, uint32_t length);

 void LMMessageAssignOutOfLine(LMMessage *message, const void *data, uint32_t length);

 void LMMessageAssignData(LMMessage *message, const void *data, uint32_t length);

 void *LMMessageGetData(LMMessage *message);

 uint32_t LMMessageGetDataLength(LMMessage *message);

 mach_msg_return_t LMMachMsg(LMConnection *connection, mach_msg_header_t *msg, mach_msg_option_t option, mach_msg_size_t send_size, mach_msg_size_t rcv_size, mach_port_name_t rcv_name, mach_msg_timeout_t timeout, mach_port_name_t notify);

 kern_return_t LMConnectionSendOneWay(LMConnectionRef connection, SInt32 messageId, const void *data, uint32_t length);

 kern_return_t LMConnectionSendEmptyOneWay(LMConnectionRef connection, SInt32 messageId);

 kern_return_t LMConnectionSendTwoWay(LMConnectionRef connection, SInt32 messageId, const void *data, uint32_t length, LMResponseBuffer *responseBuffer);

 void LMResponseBufferFree(LMResponseBuffer *responseBuffer);

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
 kern_return_t LMStartServiceWithUserInfo(name_t serverName, CFRunLoopRef runLoop, CFMachPortCallBack callback, void *userInfo);
#pragma GCC diagnostic warning "-Wdeprecated-declarations"

 kern_return_t LMStartService(name_t serverName, CFRunLoopRef runLoop, CFMachPortCallBack callback);

 kern_return_t LMSendReply(mach_port_t replyPort, const void *data, uint32_t length);

 kern_return_t LMSendIntegerReply(mach_port_t replyPort, int integer);

 kern_return_t LMSendCFDataReply(mach_port_t replyPort, CFDataRef data);

#ifdef __OBJC__

 kern_return_t LMSendNSDataReply(mach_port_t replyPort, NSData *data);

 kern_return_t LMSendPropertyListReply(mach_port_t replyPort, id propertyList);

#endif

// Remote functions

 bool LMConnectionSendOneWayData(LMConnectionRef connection, SInt32 messageId, CFDataRef data);

 kern_return_t LMConnectionSendTwoWayData(LMConnectionRef connection, SInt32 messageId, CFDataRef data, LMResponseBuffer *buffer);

 int32_t LMResponseConsumeInteger(LMResponseBuffer *buffer);

#ifdef __OBJC__

 kern_return_t LMConnectionSendTwoWayPropertyList(LMConnectionRef connection, SInt32 messageId, id propertyList, LMResponseBuffer *buffer);

 id LMResponseConsumePropertyList(LMResponseBuffer *buffer);

 kern_return_t LMConnectionSendTwoWayArchiverObject(LMConnectionRef connection, SInt32 messageId, id<NSCoding> archiverObject, LMResponseBuffer *buffer);

 kern_return_t LMSendArchiverObjectReply(mach_port_t replyPort, id<NSCoding> archiverObject);

 id<NSCoding> LMResponseConsumeArchiverObject(LMResponseBuffer *buffer);

#ifdef UIKIT_EXTERN
#import <UIKit/UIImage.h>

typedef struct __attribute__((aligned(0x1))) __attribute__((packed)) {
	uint32_t width;
	uint32_t height;
	uint32_t bitsPerComponent;
	uint32_t bitsPerPixel;
	uint32_t bytesPerRow;
	CGBitmapInfo bitmapInfo;
	float scale;
	UIImageOrientation orientation;
} LMImageHeader;

typedef struct {
	LMMessage response;
	LMImageHeader imageHeader;
} LMImageMessage;

 UIImage *LMResponseConsumeImage(LMResponseBuffer *buffer);

typedef struct CGAccessSession *CGAccessSessionRef;

CGAccessSessionRef CGAccessSessionCreate(CGDataProviderRef provider);
void *CGAccessSessionGetBytePointer(CGAccessSessionRef session);
size_t CGAccessSessionGetBytes(CGAccessSessionRef session,void *buffer,size_t bytes);
void CGAccessSessionRelease(CGAccessSessionRef session);

 kern_return_t LMSendImageReply(mach_port_t replyPort, UIImage *image);

#endif

#endif
