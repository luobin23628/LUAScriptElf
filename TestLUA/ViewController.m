//
//  ViewController.m
//  TestLUA
//
//  Created by luobin on 14-9-27.
//
//

#import "ViewController.h"
#import "LUAScripSupport.h"
#import "LuaManager.h"
#import "HIDManager.h"
#import "LightMessaging.h"
#import "Global.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    registerLUAFunctions();
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"lua"];
    [[LuaManager shareInstance] runCodeFromFileWithPath:path];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.image = [UIImage imageNamed:@"1.png"];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:imageView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"run" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    btn.frame = CGRectMake(100, 100, 100, 30);
    [btn addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
    UITextField *text = [[UITextField alloc] initWithFrame:CGRectMake(1, 20, 100, 30)];
    text.text = @"ttt";
    [self.view addSubview:text];
}

- (void)test {
    [[LuaManager shareInstance] callFunctionNamed:@"main" withObject:nil];
    
    /*
    LMResponseBuffer buffer;
    kern_return_t ret = LMConnectionSendTwoWay(&connection, GMMessageIdGetScreenUIImage, NULL, 0, &buffer);
    
    if (ret == KERN_SUCCESS) {
        
        NSLog(@"KERN_SUCCESS");
    }
     */
}


@end
