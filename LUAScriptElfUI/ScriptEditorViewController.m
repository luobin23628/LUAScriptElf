//
//  ScriptEditorViewController.m
//  LUAScriptElf
//
//  Created by LuoBin on 14-10-17.
//
//

#import "ScriptEditorViewController.h"
#import "TKAlertView.h"
#import "UIViewAdditions.h"

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
        self.title = [scriptPath lastPathComponent];
        self.hasChange = NO;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrameNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITextView *textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    textView.alwaysBounceVertical = YES;
    textView.delegate = self;
    textView.backgroundColor = [UIColor whiteColor];
    textView.font = [UIFont systemFontOfSize:14];
    textView.text = [NSString stringWithContentsOfFile:self.scriptPath usedEncoding:nil error:nil];
    [self.view addSubview:textView];
    self.textView = textView;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    backButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back_indicator_image"] forState:UIControlStateNormal];
    [backButton setFrame:CGRectMake(0, 0, 25 + 22 + backButton.imageView.frame.size.width , 44)];
    [backButton setClipsToBounds:NO];
    [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, - 15, 0, 0)];
    [backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, backButton.imageEdgeInsets.left+15, 0, 0)];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
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
    NSError *error = nil;
    BOOL success = [self.textView.text writeToFile:self.scriptPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (success) {
        self.hasChange = NO;
    } else {
        TKAlertView * alertView = [TKAlertView alertWithTitle:@"保存出错" message:[error description]];
        [alertView addButtonWithTitle:@"确定" block:nil];
        [alertView show];
    }
}

- (void)back {
    if (self.hasChange) {
        TKAlertView * alertView = [TKAlertView alertWithTitle:nil message:@"确定要放弃所有修改吗？"];
        [alertView addButtonWithTitle:@"确定" block:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alertView addButtonWithTitle:@"取消" block:nil];
        [alertView show];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [self stopMonitor];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    self.hasChange = YES;
}

-(void) keyboardWillChangeFrameNotification:(NSNotification *)note{
    //    // get keyboard size and loctaion
    //	CGRect keyboardBounds;
    //    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    //
    //    // Need to translate the bounds to account for rotation.
    //    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    //    self.view.bottom = [UIScreen mainScreen].bounds.size.height - keyboardBounds.size.height;
    //
    
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    if ([duration doubleValue]) {
        // animations settings
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:[duration doubleValue]];
        [UIView setAnimationCurve:[curve integerValue]];
        [UIView setAnimationDelegate:self];
    }
    
    // set views with new info
    self.textView.height = self.view.height - keyboardBounds.size.height;
    
    if ([duration doubleValue]) {
        
        // commit animations
        [UIView commitAnimations];
    }
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
