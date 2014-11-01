//
//  main.c
//  LUAScriptElf
//
//  Created by LuoBin on 14-9-26.
//  Copyright (c) 2014年 __MyCompanyName__. All rights reserved.
//

#include <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SimulateTouch.h>
#import "LUAScripSupport.h"
#import "LuaManager.h"
#import <dlfcn.h>
#import <sys/types.h>

typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);
#if !defined(PT_DENY_ATTACH)
#define PT_DENY_ATTACH 31
#endif  // !defined(PT_DENY_ATTACH)

static void disable_gdb() {
    void* handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
    ptrace_ptr_t ptrace_ptr = dlsym(handle, "ptrace");
    ptrace_ptr(PT_DENY_ATTACH, 0, 0, 0);
    dlclose(handle);
}

int main (int argc, const char * argv[])
{
    if(argc < 2){
		printf("Please enter the filename\n");
		return EXIT_FAILURE;}
    
    @autoreleasepool {
        disable_gdb();
        setuid(0);
        
        registerLUAFunctions();
        
        NSString *path = [NSString stringWithUTF8String:argv[1]];
        [[LuaManager shareInstance] runCodeFromFileWithPath:path];
        [[LuaManager shareInstance] callFunctionNamed:@"main" withObject:nil];
    }

	return 0;
}

