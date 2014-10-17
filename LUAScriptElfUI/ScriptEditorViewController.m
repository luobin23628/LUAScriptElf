//
//  ScriptEditorViewController.m
//  LUAScriptElf
//
//  Created by LuoBin on 14-10-17.
//
//

#import "ScriptEditorViewController.h"

@interface ScriptEditorViewController ()

@property (nonatomic, strong) NSString *scriptPath;
@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) dispatch_source_t source;
@end

@implementation ScriptEditorViewController

- (id)initWithScriptPath:(NSString *)scriptPath {
    self = [super init];
    if (self) {
        self.scriptPath = scriptPath;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITextView *textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    textView.backgroundColor = [UIColor clearColor];
    textView.editable = NO;
    textView.text = [NSString stringWithContentsOfFile:self.scriptPath usedEncoding:nil error:nil];
    [self.view addSubview:textView];
    self.textView = textView;
    
}

- (void)startMonitorForProcess:(NSString *)filePath
{
    [self stopMonitor];
    
    int fd = open(filePath.UTF8String, O_EVTONLY);
    if (fd == -1)
        return;
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fd, DISPATCH_VNODE_WRITE, queue);
    self.source = source;
    if (source)
    {
        dispatch_source_set_event_handler(source, ^{
            NSLog(@"dispatch_source_set_event_handler====================");
            [self stopMonitor];
        });
        
        dispatch_source_set_cancel_handler(source, ^{
            close(fd);
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
