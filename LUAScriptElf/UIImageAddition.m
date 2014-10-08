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

static IOSurfaceRef surface;

@implementation UIImage (Addition)

+(IOSurfaceRef) createScreenSurface
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    float scale = [UIScreen mainScreen].scale;
    
    NSInteger width, height;
    // setup the width and height of the framebuffer for the device
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        // iPhone frame buffer is Portrait
        width = screenSize.width * scale;
        height = screenSize.height * scale;
    } else {
        // iPad frame buffer is Landscape
        width = screenSize.height * scale;
        height = screenSize.width * scale;
    }
    
    
    // Pixel format for Alpha Red Green Blue
    unsigned pixelFormat = 0x42475241;//'ARGB';
    
    // 4 Bytes per pixel
    int bytesPerElement = 4;
    
    // Bytes per row
    int bytesPerRow = (bytesPerElement * width);
    
    // Properties include: SurfaceIsGlobal, BytesPerElement, BytesPerRow, SurfaceWidth, SurfaceHeight, PixelFormat, SurfaceAllocSize (space for the entire surface)
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithBool:YES], kIOSurfaceIsGlobal,
                                [NSNumber numberWithInt:bytesPerElement], kIOSurfaceBytesPerElement,
                                [NSNumber numberWithInt:bytesPerRow], kIOSurfaceBytesPerRow,
                                [NSNumber numberWithInt:width], kIOSurfaceWidth,
                                [NSNumber numberWithInt:height], kIOSurfaceHeight,
                                [NSNumber numberWithUnsignedInt:pixelFormat], kIOSurfacePixelFormat,
                                [NSNumber numberWithInt:bytesPerRow * height], kIOSurfaceAllocSize,
                                nil];
    
    // This is the current surface
    return IOSurfaceCreate((__bridge CFDictionaryRef)properties);
    
}

+(NSMutableData*) captureShot
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    float scale = [UIScreen mainScreen].scale;
    
    NSInteger width, height;
    // setup the width and height of the framebuffer for the device
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        // iPhone frame buffer is Portrait
        width = screenSize.width * scale;
        height = screenSize.height * scale;
    } else {
        // iPad frame buffer is Landscape
        width = screenSize.height * scale;
        height = screenSize.width * scale;
    }
    
    NSInteger bytesPerElement = 4;
    NSInteger bytesPerRow = bytesPerElement * width;
    
    
    surface = [self createScreenSurface];
    CARenderServerRenderDisplay(0, CFSTR("LCD"), surface, 0, 0);
    
    // Make a raw memory copy of the surface
    void *baseAddr = IOSurfaceGetBaseAddress(surface);
    int totalBytes = bytesPerRow * height;
    
    //void *rawData = malloc(totalBytes);
    //memcpy(rawData, baseAddr, totalBytes);
    NSMutableData * rawDataObj = nil;
    rawDataObj = [NSMutableData dataWithBytes:baseAddr length:totalBytes];
    
    return rawDataObj;
}

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
