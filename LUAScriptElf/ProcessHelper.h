//
//  ProcessHelper.h
//  LUAScriptElf
//
//  Created by LuoBin on 14-10-11.
//
//

#import <Foundation/Foundation.h>

@interface ProcessHelper : NSObject {
@private
    NSInteger        _processCount;
    NSMutableArray * _processList;
}

@property (nonatomic, readwrite) NSInteger processCount;

+ (instancetype)shareInstance;

- (void)obtainFreshProcessList;
- (pid_t)findProcessWithName:(NSString *)procNameToSearch;

@end