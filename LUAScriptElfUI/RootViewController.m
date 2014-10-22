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
@property (nonatomic, strong) NSString *scriptsPath;
@property (nonatomic, strong) dispatch_source_t source;

@end

@implementation RootViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.navigationItem.title = @"脚本";
        self.scriptsPath = @"/var/mobile/luascriptelf/scripts/";
//        self.scriptsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    }
    return self;
}

- (void)dealloc {
    [self stopMonitor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadData];
    
    [self startMonitorForFilePath:self.scriptsPath];
}

- (void)reloadData {
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSMutableArray *scripts = [NSMutableArray array];
    NSDirectoryEnumerator *direnum = [fileManger enumeratorAtPath:self.scriptsPath];
    
    NSString *filename ;
    while (filename = [direnum nextObject]) {
        if ([[[direnum fileAttributes] fileType] isEqualToString:NSFileTypeRegular]
            && [[[filename pathExtension] lowercaseString] isEqualToString:@"lua"]) {
            [scripts addObject: filename];
        }
    }
    
    [scripts sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate *creationDate1 = [[fileManger attributesOfItemAtPath:[self.scriptsPath stringByAppendingPathComponent:obj1] error:nil] fileModificationDate];
        NSDate *creationDate2 = [[fileManger attributesOfItemAtPath:[self.scriptsPath stringByAppendingPathComponent:obj2] error:nil] fileModificationDate];
        return [creationDate2 compare:creationDate1];
    }];
    
    self.scripts = scripts;
    [self.tableView reloadData];
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *scriptPath = [self.scripts objectAtIndex:indexPath.row];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:scriptPath message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"播放", @"编辑", nil];
    [alertView show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *scriptPath = alertView.title;
    scriptPath = [self.scriptsPath stringByAppendingPathComponent:scriptPath];

    if (buttonIndex == 1) {
        NSData *data = [scriptPath dataUsingEncoding:NSUTF8StringEncoding];
        LMResponseBuffer buffer;
        kern_return_t ret = LMConnectionSendTwoWayData(&tweakConnection, TweakMessageIdSetScriptPath, (__bridge CFDataRef)data, &buffer);
            
        if (ret == KERN_SUCCESS) {
            NSLog(@"KERN_SUCCESS");
        }
    } else if (buttonIndex == 2) {
        ScriptEditorViewController *scriptEditorViewController = [[ScriptEditorViewController alloc] initWithScriptPath:scriptPath];
        [self.navigationController pushViewController:scriptEditorViewController animated:YES];
    }
}

- (void)startMonitorForFilePath:(NSString *)filePath {
    [self stopMonitor];
    
    int fd = open(filePath.UTF8String, O_RDONLY);
    if (fd == -1)
        return;
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fd, DISPATCH_VNODE_DELETE | DISPATCH_VNODE_WRITE | DISPATCH_VNODE_EXTEND | DISPATCH_VNODE_RENAME | DISPATCH_VNODE_REVOKE, queue);
    
    self.source = source;
    if (source)
    {
        dispatch_source_set_event_handler(source, ^{
            [self reloadData];
        });
        
        dispatch_source_set_cancel_handler(source, ^{
            close((int)dispatch_source_get_handle(source));
        });
        
        dispatch_resume(source);
    } else {
        close(fd);
    }
}

- (void)stopMonitor {
    if (self.source) {
        dispatch_source_cancel(self.source);
        self.source = nil;
    }
}

@end
