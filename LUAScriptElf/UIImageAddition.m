//
//  UIImage+Screenshot.m
//  LUAScriptElf
//
//  Created by luobin on 14-9-26.
//
//

#import "UIImageAddition.h"
#import "UIColorAddition.h"
#import <mach/mach.h>
#import "IOSurface/IOSurface.h"

extern CGImageRef UIGetScreenImage(void);
extern UIImage* _UICreateScreenUIImage();

@implementation UIImage (Addition)

+ (UIImage *)screenshot {
    return [_UICreateScreenUIImage() autorelease];
}

- (UIImage *)imageWithCrop:(CGRect)rect
{
    CGAffineTransform rectTransform;
    switch (self.imageOrientation)
    {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(90/180.0 * M_PI), 0, -self.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-90/180.0 * M_PI), -self.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-180/180.0 * M_PI), -self.size.width, -self.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };
    rectTransform = CGAffineTransformScale(rectTransform, self.scale, self.scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], CGRectApplyAffineTransform(rect, rectTransform));
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage {
	
	CGContextRef    context = NULL;
	CGColorSpaceRef colorSpace;
	void *          bitmapData;
	int             bitmapByteCount;
	int             bitmapBytesPerRow;
	
	// Get image width, height. We'll use the entire image.
	size_t pixelsWide = CGImageGetWidth(inImage);
	size_t pixelsHigh = CGImageGetHeight(inImage);
	
	// Declare the number of bytes per row. Each pixel in the bitmap in this
	// example is represented by 4 bytes; 8 bits each of red, green, blue, and
	// alpha.
	bitmapBytesPerRow   = (pixelsWide * 4);
	bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
	
	// Use the generic RGB color space.
	colorSpace = CGColorSpaceCreateDeviceRGB();
    
	if (colorSpace == NULL)
	{
		fprintf(stderr, "Error allocating color space\n");
		return NULL;
	}
	
	// Allocate memory for image data. This is the destination in memory
	// where any drawing to the bitmap context will be rendered.
	bitmapData = malloc( bitmapByteCount );
	if (bitmapData == NULL)
	{
		fprintf (stderr, "Memory not allocated!");
		CGColorSpaceRelease( colorSpace );
		return NULL;
	}
	
	// Create the bitmap context. We want pre-multiplied ARGB, 8-bits
	// per component. Regardless of what the source image format is
	// (CMYK, Grayscale, and so on) it will be converted over to the format
	// specified here by CGBitmapContextCreate.
	context = CGBitmapContextCreate (bitmapData,
									 pixelsWide,
									 pixelsHigh,
									 8,      // bits per component
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGImageAlphaPremultipliedFirst);
	if (context == NULL)
	{
		free (bitmapData);
		fprintf (stderr, "Context not created!");
	}
	
	// Make sure and release colorspace before returning
	CGColorSpaceRelease( colorSpace );
	
	return context;
}

- (UIColor*) getPixelColorAtLocation:(CGPoint)point {
	UIColor* color = nil;
	CGImageRef inImage = self.CGImage;
	// Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
	CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
	if (cgctx == NULL) { return nil; /* error */ }
	
    size_t w = CGImageGetWidth(inImage);
	size_t h = CGImageGetHeight(inImage);
	CGRect rect = {{0,0},{w,h}};
	
	// Draw the image to the bitmap context. Once we draw, the memory
	// allocated for the context for rendering will then contain the
	// raw image data in the specified color space.
	CGContextDrawImage(cgctx, rect, inImage);
	
	// Now we can get a pointer to the image data associated with the bitmap
	// context.
	unsigned char* data = CGBitmapContextGetData (cgctx);
	if (data != NULL) {
		//offset locates the pixel in the data from x,y.
		//4 for 4 bytes of data per pixel, w is width of one row of data.
		int offset = 4*((w*round(point.y))+round(point.x));
		int alpha =  data[offset];
		int red = data[offset+1];
		int green = data[offset+2];
		int blue = data[offset+3];
		color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
	}
	
	// When finished, release the context
	CGContextRelease(cgctx);
	// Free image data memory for the context
	if (data) { free(data); }
	
	return color;
}

- (CGPoint)findColor:(UIColor *)color {
    return [self findColor:color fuzzyOffset:0];
}

- (CGPoint)findColor:(UIColor *)color fuzzyOffset:(CGFloat)fuzzyOffset {
	CGImageRef inImage = self.CGImage;
	// Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
	CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
	if (cgctx == NULL) {
        return CGPointMake(NSNotFound, NSNotFound); /* error */
    }
    
    unsigned char components[4];
    [color getRGBComponents:components];
    
    size_t w = CGImageGetWidth(inImage);
	size_t h = CGImageGetHeight(inImage);
	CGRect rect = {{0,0},{w,h}};
	
	// Draw the image to the bitmap context. Once we draw, the memory
	// allocated for the context for rendering will then contain the
	// raw image data in the specified color space.
	CGContextDrawImage(cgctx, rect, inImage);
	
	// Now we can get a pointer to the image data associated with the bitmap
	// context.
	unsigned char* data = CGBitmapContextGetData (cgctx);
	if (data != NULL) {
        for (int i = 0; i < w; i++) {
            for (int j = 0; j < h; j++) {
                int offset = 4*((w*i)+j);
//                int alpha =  data[offset];
                unsigned char red = data[offset+1];
                unsigned char green = data[offset+2];
                unsigned char blue = data[offset+3];
                
                if (round(fabs(red - components[0])) <= ceil(fuzzyOffset)
                    &&round(fabs(green - components[1])) <= ceil(fuzzyOffset)
                    &&round(fabs(blue - components[2])) <= ceil(fuzzyOffset)) {
                    
                    // When finished, release the context
                    CGContextRelease(cgctx);
                    // Free image data memory for the context
                    if (data) { free(data); }
                    
                    return CGPointMake(i, j);
                }
            }
        }
	}
	
	// When finished, release the context
	CGContextRelease(cgctx);
	// Free image data memory for the context
	if (data) { free(data); }
    
    return CGPointMake(NSNotFound, NSNotFound);
}



@end

#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>

#define kNyxNumberOfComponentsPerARBGPixel 4

@implementation UIImage (NYX_Rotating)

- (CGContextRef)createARGBBitmapContext:(const size_t)width
                                 height:(const size_t)height
                            bytesPerRow:(const size_t)bytesPerRow withAlpha:(BOOL)withAlpha
{
	/// Use the generic RGB color space
	/// We avoid the NULL check because CGColorSpaceRelease() NULL check the value anyway, and worst case scenario = fail to create context
	/// Create the bitmap context, we want pre-multiplied ARGB, 8-bits per component
	CGImageAlphaInfo alphaInfo = (withAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst);
	CGContextRef bmContext = CGBitmapContextCreate(NULL, width, height, 8/*Bits per component*/, bytesPerRow, CGColorSpaceCreateDeviceRGB(), kCGBitmapByteOrderDefault | alphaInfo);
    
	return bmContext;
}

-(UIImage*)rotateInRadians:(CGFloat)radians flipOverHorizontalAxis:(BOOL)doHorizontalFlip verticalAxis:(BOOL)doVerticalFlip
{
	/// Create an ARGB bitmap context
	const size_t width = (size_t)CGImageGetWidth(self.CGImage);
	const size_t height = (size_t)CGImageGetHeight(self.CGImage);
    
	CGRect rotatedRect = CGRectApplyAffineTransform(CGRectMake(0., 0., width, height), CGAffineTransformMakeRotation(radians));

	CGContextRef bmContext = [self createARGBBitmapContext:(size_t)rotatedRect.size.width
                                                        height:(size_t)rotatedRect.size.height
                                                   bytesPerRow:rotatedRect.size.width*kNyxNumberOfComponentsPerARBGPixel
                                                     withAlpha:YES];
	if (!bmContext)
		return nil;
    
	/// Image quality
	CGContextSetShouldAntialias(bmContext, true);
	CGContextSetAllowsAntialiasing(bmContext, true);
	CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);
    
	/// Rotation happen here (around the center)
	CGContextTranslateCTM(bmContext, +(rotatedRect.size.width / 2.0f), +(rotatedRect.size.height / 2.0f));
	CGContextRotateCTM(bmContext, radians);
    
    // Do flips
	CGContextScaleCTM(bmContext, (doHorizontalFlip ? -1.0f : 1.0f), (doVerticalFlip ? -1.0f : 1.0f));
    
	/// Draw the image in the bitmap context
	CGContextDrawImage(bmContext, CGRectMake(-(width / 2.0f), -(height / 2.0f), width, height), self.CGImage);
    
	/// Create an image object from the context
	CGImageRef resultImageRef = CGBitmapContextCreateImage(bmContext);
	UIImage* resultImage = [UIImage imageWithCGImage:resultImageRef scale:self.scale orientation:self.imageOrientation];
    
	/// Cleanup
	CGImageRelease(resultImageRef);
	CGContextRelease(bmContext);
    
	return resultImage;
}

-(UIImage*)rotateInRadians:(float)radians
{
    return [self rotateInRadians:radians flipOverHorizontalAxis:NO verticalAxis:NO];
}

-(UIImage*)rotateInDegrees:(float)degrees
{
	return [self rotateInRadians:degrees*M_PI/180];
}

-(UIImage*)verticalFlip
{
	return [self rotateInRadians:0. flipOverHorizontalAxis:NO verticalAxis:YES];
}

-(UIImage*)horizontalFlip
{
    return [self rotateInRadians:0. flipOverHorizontalAxis:YES verticalAxis:NO];
}

-(UIImage*)rotateImagePixelsInRadians:(float)radians
{
	/// Create an ARGB bitmap context
	const size_t width = (size_t)(self.size.width * self.scale);
	const size_t height = (size_t)(self.size.height * self.scale);
	const size_t bytesPerRow = width * kNyxNumberOfComponentsPerARBGPixel;
    CGContextRef bmContext = [self createARGBBitmapContext:width
                                                    height:height
                                               bytesPerRow:bytesPerRow
                                                 withAlpha:YES];
    
    
	if (!bmContext)
		return nil;
    
	/// Draw the image in the bitmap context
	CGContextDrawImage(bmContext, CGRectMake(0.0f, 0.0f, width, height), self.CGImage);
    
	/// Grab the image raw data
	UInt8* data = (UInt8*)CGBitmapContextGetData(bmContext);
	if (!data)
	{
		CGContextRelease(bmContext);
		return nil;
	}
    
	vImage_Buffer src = {data, height, width, bytesPerRow};
	vImage_Buffer dest = {data, height, width, bytesPerRow};
	Pixel_8888 bgColor = {0, 0, 0, 0};
	vImageRotate_ARGB8888(&src, &dest, NULL, radians, bgColor, kvImageBackgroundColorFill);
    
	CGImageRef rotatedImageRef = CGBitmapContextCreateImage(bmContext);
	UIImage* rotated = [UIImage imageWithCGImage:rotatedImageRef scale:self.scale orientation:self.imageOrientation];
    
	/// Cleanup
	CGImageRelease(rotatedImageRef);
	CGContextRelease(bmContext);
    
	return rotated;
}

-(UIImage*)rotateImagePixelsInDegrees:(float)degrees
{
	return [self rotateImagePixelsInRadians:degrees*M_PI/180];
}

@end
