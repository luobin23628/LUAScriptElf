//
//  ScreenUtil.m
//  LUAScriptElf
//
//  Created by LuoBin on 14-10-9.
//
//

#import "ScreenUtil.h"
#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import "IOSurface/IOSurface.h"

void CARenderServerRenderDisplay(kern_return_t a, CFStringRef b, IOSurfaceRef surface, int x, int y);

static IOSurfaceRef surface;

@implementation ScreenUtil

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

+ (void) getColorAtLocation:(CGPoint)point color:(TKColor *)color {
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
    
    if (!surface) {
        surface = [self createScreenSurface];
    }
    CARenderServerRenderDisplay(0, CFSTR("LCD"), surface, 0, 0);
    
    // Make a raw memory copy of the surface
    unsigned char *data = IOSurfaceGetBaseAddress(surface);
    int totalBytes = bytesPerRow * height;
    
    if (data != NULL) {
		//offset locates the pixel in the data from x,y.
		//4 for 4 bytes of data per pixel, w is width of one row of data.
		int offset = 4*((width*round(point.y))+round(point.x));
        
        if (offset < totalBytes) {
            unsigned char blue =  data[offset];
            unsigned char green = data[offset+1];
            unsigned char red = data[offset+2];
//            unsigned char alpha = data[offset+3];
            if (color) {
                color->red = red;
                color->green = green;
                color->blue = blue;
            }
        }
	}
}

+ (CGPoint)findColor:(TKColor)color {
    return [self findColor:color fuzzyOffset:0];
}

+ (CGPoint)findColor:(TKColor)color fuzzyOffset:(CGFloat)fuzzyOffset {
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
    
//    NSInteger bytesPerElement = 4;
//    NSInteger bytesPerRow = bytesPerElement * width;
    
    if (!surface) {
        surface = [self createScreenSurface];
    }
    CARenderServerRenderDisplay(0, CFSTR("LCD"), surface, 0, 0);
    
    // Make a raw memory copy of the surface
    unsigned char *data = IOSurfaceGetBaseAddress(surface);
//    int totalBytes = bytesPerRow * height;

	if (data != NULL) {
        for (int i = 0; i < width; i++) {
            for (int j = 0; j < height; j++) {
                int offset = 4*((width*i)+j);
                unsigned char blue =  data[offset];
                unsigned char green = data[offset+1];
                unsigned char red = data[offset+2];
                
                if (round(fabs(red - color.red)) <= ceil(fuzzyOffset)
                    &&round(fabs(green - color.green)) <= ceil(fuzzyOffset)
                    &&round(fabs(blue - color.blue)) <= ceil(fuzzyOffset)) {
                    return CGPointMake(i, j);
                }
            }
        }
	}
    return CGPointMake(NSNotFound, NSNotFound);
}

+ (CGPoint)findColor:(TKColor)color inRegion:(CGRect)region fuzzyOffset:(CGFloat)fuzzyOffset {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    float scale = [UIScreen mainScreen].scale;
    
    region = CGRectIntersection([UIScreen mainScreen].bounds, region);
    if (CGRectIsNull(region)) {
        return CGPointMake(NSNotFound, NSNotFound);
    }
    
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
    
    //    NSInteger bytesPerElement = 4;
    //    NSInteger bytesPerRow = bytesPerElement * width;
    
    if (!surface) {
        surface = [self createScreenSurface];
    }
    CARenderServerRenderDisplay(0, CFSTR("LCD"), surface, 0, 0);
    
    // Make a raw memory copy of the surface
    unsigned char *data = IOSurfaceGetBaseAddress(surface);
    //    int totalBytes = bytesPerRow * height;
    
	if (data != NULL) {
        for (int i = region.origin.x; i <= CGRectGetMaxX(region); i++) {
            for (int j = region.origin.y; j < CGRectGetMaxY(region); j++) {
                int offset = 4*((width*i)+j);
                unsigned char blue =  data[offset];
                unsigned char green = data[offset+1];
                unsigned char red = data[offset+2];
                
                if (round(fabs(red - color.red)) <= ceil(fuzzyOffset)
                    &&round(fabs(green - color.green)) <= ceil(fuzzyOffset)
                    &&round(fabs(blue - color.blue)) <= ceil(fuzzyOffset)) {
                    return CGPointMake(i, j);
                }
            }
        }
	}
    return CGPointMake(NSNotFound, NSNotFound);
}

@end
