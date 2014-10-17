//
//  ViewController.m
//  LUAScriptElfUI
//
//  Created by luobin on 14-10-12.
//
//

#import "RootViewController.h"
#import "Global.h"
#import "ScriptEditorViewController.h"

@interface RootViewController ()<UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *scripts;

@end

@implementation RootViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.navigationItem.title = @"脚本";
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActiveNotification:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)reloadData {
    self.scripts = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/mobile/luascriptelf/scripts/" error:nil];
    [self.tableView reloadData];
}

- (void)appDidBecomeActiveNotification:(NSNotification *)notification {
    [self reloadData];
}

#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.scripts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"reuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
    }
    NSString *scriptPath = [self.scripts objectAtIndex:indexPath.row];
    cell.textLabel.text = [scriptPath lastPathComponent];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *scriptPath = [self.scripts objectAtIndex:indexPath.row];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:scriptPath message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"播放", @"编辑", nil];
    [alertView show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *scriptPath = alertView.title;
    
    if (buttonIndex == 0) {
        NSData *data = [scriptPath dataUsingEncoding:NSUTF8StringEncoding];
        LMResponseBuffer buffer;
        kern_return_t ret = LMConnectionSendTwoWayData(&tweakConnection, TweakMessageIdSetScriptPath, (__bridge CFDataRef)data, &buffer);
            
        if (ret == KERN_SUCCESS) {
            NSLog(@"KERN_SUCCESS");
        }
    } else if (buttonIndex == 1) {
        ScriptEditorViewController *scriptEditorViewController = [[ScriptEditorViewController alloc] initWithScriptPath:scriptPath];
        [self.navigationController pushViewController:scriptEditorViewController animated:YES];
    }
}


@end
