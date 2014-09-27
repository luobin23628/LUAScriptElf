//
//  AppUtil.h
//  imem
//
//  Created by LuoBin on 14-8-19.
//
//

#import <Foundation/Foundation.h>

@interface AppUtil : NSObject

+ (NSString *)displayIdentifierForFronMostApp;

+ (pid_t)pidForDisplayIdentifier:(NSString *)displayIdentifier;

+ (NSDictionary *)appInfoForProcessID:(pid_t)pid;

+ (NSDictionary *)appInfoForDisplayIdentifier:(NSString *)displayIdentifier;

+ (NSArray*) getApps:(BOOL)onlyActive;

+ (NSArray*) getAppIdentifiers:(BOOL)onlyActive;

+ (BOOL)launchAppWithIdentifier:(NSString *)identifier;
+ (BOOL)launchAppWithIdentifier:(NSString *)identifier launchOptions:(NSDictionary *)launchOptions suspended:(BOOL)suspended error:(NSError **)error;

@end
