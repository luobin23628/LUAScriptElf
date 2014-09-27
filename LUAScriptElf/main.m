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

int main (int argc, const char * argv[])
{
    if(argc < 2){
		printf("Please enter the filename\n");
		return EXIT_FAILURE;}
    
    @autoreleasepool {
        registerLUAFunctions();
        
        NSString *path = [NSString stringWithUTF8String:argv[1]];
        [[LuaManager shareInstance] runCodeFromFileWithPath:path];
        [[LuaManager shareInstance] callFunctionNamed:@"main" withObject:nil];
    }

	return 0;
}

