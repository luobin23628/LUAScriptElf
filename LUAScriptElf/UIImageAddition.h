//
//  UIImage+Screenshot.h
//  LUAScriptElf
//
//  Created by luobin on 14-9-26.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (Addition)

+ (UIImage *)screenshot;

- (UIImage *)imageWithCrop:(CGRect)rect;

- (UIColor*) getPixelColorAtLocation:(CGPoint)point;

- (CGPoint)findColor:(UIColor *)color fuzzyOffset:(CGFloat)offset;
- (CGPoint)findColor:(UIColor *)color;

@end

@interface UIImage (NYX_Rotating)

-(UIImage*)rotateInRadians:(float)radians;

-(UIImage*)rotateInDegrees:(float)degrees;

-(UIImage*)rotateImagePixelsInRadians:(float)radians;

-(UIImage*)rotateImagePixelsInDegrees:(float)degrees;

-(UIImage*)verticalFlip;

-(UIImage*)horizontalFlip;

@end
