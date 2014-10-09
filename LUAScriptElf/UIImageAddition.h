//
//  UIImage+Screenshot.h
//  LUAScriptElf
//
//  Created by luobin on 14-9-26.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (Addition)

+ (UIImage*) captureShot;

+ (UIImage *)screenshot;

- (UIImage *)imageWithCrop:(CGRect)rect;

- (UIColor*) getPixelColorAtLocation:(CGPoint)point;

- (CGPoint)findColor:(UIColor *)color fuzzyOffset:(CGFloat)offset;
- (CGPoint)findColor:(UIColor *)color;

@end
