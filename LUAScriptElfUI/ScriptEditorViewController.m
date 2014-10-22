//
//  ScriptEditorViewController.m
//  LUAScriptElf
//
//  Created by LuoBin on 14-10-17.
//
//

#import "ScriptEditorViewController.h"
#import ""

@interface ScriptEditorViewController ()<UITextViewDelegate>

@property (nonatomic, strong) NSString *scriptPath;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, assign) BOOL hasChange;
@property (nonatomic, strong) dispatch_source_t source;
@end

@implementation ScriptEditorViewController

- (id)initWithScriptPath:(NSString *)scriptPath {
    self = [super init];
    if (self) {
        self.scriptPath = scriptPath;
        self.hasChange = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITextView *textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    textView.alwaysBounceVertical = YES;
    textView.delegate = self;
    textView.backgroundColor = [UIColor whiteColor];
    textView.font = [UIFont systemFontOfSize:14];
    textView.text = [NSString stringWithContentsOfFile:self.scriptPath usedEncoding:nil error:nil];
    [self.view addSubview:textView];
    self.textView = textView;
    
    
    UIButton *backButton = [UIButton buttonWithType:101];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitle:@"脚本" forState:UIControlStateNormal];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;

    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(save)];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
    [self startMonitorForFilePath:self.scriptPath];
}

- (void)save {
    [self.textView.text writeToFile:self.scriptPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)back {
    if (self.hasChange) {
        
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)dealloc {
    [self stopMonitor];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    self.hasChange = YES;
}

- (void)startMonitorForFilePath:(NSString *)filePath
{
    [self stopMonitor];
    
    int fd = open(filePath.UTF8String, O_EVTONLY);
    if (fd == -1)
        return;
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fd, DISPATCH_VNODE_WRITE | DISPATCH_VNODE_DELETE, queue);
    self.source = source;
    if (source)
    {
        dispatch_source_set_event_handler(source, ^{
            self.textView.text = [NSString stringWithContentsOfFile:self.scriptPath usedEncoding:nil error:nil];
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
