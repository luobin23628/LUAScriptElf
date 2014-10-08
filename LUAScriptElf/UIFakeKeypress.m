#import "UIFakeKeypress.h"
#import "GraphicsServices/GraphicsServices.h"
#import <dlfcn.h>
#define SBSERVPATH  "/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices"

@interface UIKeyboard : UIView

+ (UIKeyboard *)activeKeyboard;
- (id)_typeCharacter:(id)arg1 withError:(CGPoint)arg2 shouldTypeVariants:(BOOL)arg3 baseKeyForVariants:(BOOL)arg4;

@end

void sendKeypressForString(NSString *string) {
    UIKeyboard *keyboard = [UIKeyboard activeKeyboard];
    if (keyboard) {
        for (int i=0; i<string.length; i++) {
            NSRange range = NSMakeRange(i, 1);
            NSString *singleChar = [string substringWithRange:range];
            [keyboard _typeCharacter:singleChar withError:CGPointZero shouldTypeVariants:NO baseKeyForVariants:NO];
        }
    }
}
