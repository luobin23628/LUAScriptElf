//
//  MemoryUtil.h
//  LUAScriptElf
//
//  Created by luobin on 14-10-3.
//
//

#import <Foundation/Foundation.h>
#import <mach/mach.h>

@interface MemoryUtil : NSObject

+ (BOOL)memoryReadFromPid:(pid_t)pid address:(vm_address_t)address buffer:(void *)buffer bufferSize:(size_t)size;

+ (BOOL)memoryWriteFromPid:(pid_t)pid address:(vm_address_t)address data:(void *)data dataSize:(size_t)dataSize;

@end
