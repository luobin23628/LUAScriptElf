//
//  Global.m
//  LUAScriptElf
//
//  Created by LuoBin on 14/10/28.
//
//

#include "Global.h"
#include <mach-o/dyld.h>
#import <dlfcn.h>

NSString *uniqueDeviceID(void) {
    static CFStringRef (*$MGCopyAnswer)(CFStringRef);
    void *gestalt = dlopen("/usr/lib/libMobileGestalt.dylib", RTLD_GLOBAL | RTLD_LAZY);
    $MGCopyAnswer = (dlsym(gestalt, "MGCopyAnswer"));
//    CFStringRef SNumber = $MGCopyAnswer(CFSTR("SerialNumber"));
    return (__bridge NSString *)$MGCopyAnswer(CFSTR("UniqueDeviceID"));
}