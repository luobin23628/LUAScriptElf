//
//  ViewController.m
//  TestLUA
//
//  Created by luobin on 14-9-27.
//
//

#import "RootViewController.h"
#import "LUAScripSupport.h"
#import "LuaManager.h"
#import "HIDManager.h"
#import "LightMessaging.h"
#import "Global.h"
#import "ProcessHelper.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    registerLUAFunctions();
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.image = [UIImage imageNamed:@"Screenshot 2014.10.12 01.07.40@2x.png"];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:imageView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"run" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    btn.frame = CGRectMake(100, 50, 100, 30);
    [btn addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
    UITextField *text = [[UITextField alloc] initWithFrame:CGRectMake(1, 20, 100, 30)];
    text.text = @"ttt";
    [self.view addSubview:text];
}

- (void)test {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"lua"];
    [[LuaManager shareInstance] runCodeFromFileWithPath:path];
    
//
//    kern_return_t ret = LMConnectionSendEmptyOneWay(&connection, GMMessageIdRun);
//    
//    if (ret == KERN_SUCCESS) {
//        NSLog(@"KERN_SUCCESS");
//    }
}


@end
