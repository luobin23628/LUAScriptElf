#import <IOSurface/IOSurface.h>
#import <UIKit/UIKit.h>
#import "CaptureMyScreen.h"

void CARenderServerRenderDisplay(kern_return_t a, CFStringRef b, IOSurfaceRef surface, int x, int y);

static IOSurfaceRef _surface = nil;
static int _bytesPerRow = 0;
static int _width = 0;
static int _height = 0;

@implementation CaptureMyScreen

+(UIImage *)captureMyScreen
{
    // This is the current surface
    if (!_surface) {
        
        CGRect screenRect = [UIScreen mainScreen].bounds;
        float scale = [UIScreen mainScreen].scale;
        
        // setup the width and height of the framebuffer for the device
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            // iPhone frame buffer is Portrait
            _width = screenRect.size.width * scale;
            _height = screenRect.size.height * scale;
        } else {
            // iPad frame buffer is Landscape
            _width = screenRect.size.height * scale;
            _height = screenRect.size.width * scale;
        }
        
        // Pixel format for Alpha Red Green Blue
        unsigned pixelFormat = 0x42475241;//'ARGB';
        
        // 4 Bytes per pixel
        int bytesPerElement = 4;
        
        // Bytes per row
        _bytesPerRow = (bytesPerElement * _width);
        
        // Properties include: SurfaceIsGlobal, BytesPerElement, BytesPerRow, SurfaceWidth, SurfaceHeight, PixelFormat, SurfaceAllocSize (space for the entire surface)
        
        NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:YES], kIOSurfaceIsGlobal,
                                    [NSNumber numberWithInt:bytesPerElement], kIOSurfaceBytesPerElement,
                                    [NSNumber numberWithInt:_bytesPerRow], kIOSurfaceBytesPerRow,
                                    [NSNumber numberWithInt:_width], kIOSurfaceWidth,
                                    [NSNumber numberWithInt:_height], kIOSurfaceHeight,
                                    [NSNumber numberWithUnsignedInt:pixelFormat], kIOSurfacePixelFormat,
                                    [NSNumber numberWithInt:_bytesPerRow * _height], kIOSurfaceAllocSize,
                                    nil];
        // This is the current surface
        _surface = IOSurfaceCreate((CFDictionaryRef)properties);
    }

    IOSurfaceLock(_surface, 0, nil);
    // Take currently displayed image from the LCD
    CARenderServerRenderDisplay(0, CFSTR("LCD"), _surface, 0, 0);
    // Unlock the surface
    IOSurfaceUnlock(_surface, 0, 0);

    // Make a raw memory copy of the surface
    void *baseAddr = IOSurfaceGetBaseAddress(_surface);
    int totalBytes = _bytesPerRow * _height;
    
    // void *rawData = malloc(totalBytes);
    // memcpy(rawData, baseAddr, totalBytes);
    NSMutableData * rawDataObj = nil;
    rawDataObj = [NSMutableData dataWithBytes:baseAddr length:totalBytes];

    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, rawDataObj.bytes, rawDataObj.length, NULL);
    CGImageRef cgImage = CGImageCreate(_width, _height, 8,
                                     8*4, _bytesPerRow,
                                     CGColorSpaceCreateDeviceRGB(), kCGImageAlphaNoneSkipFirst |kCGBitmapByteOrder32Little,
                                     provider, NULL,
                                     YES, kCGRenderingIntentDefault);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGDataProviderRelease(provider);

    return image;
}

@end