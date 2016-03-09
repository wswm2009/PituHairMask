#ifndef __PITU_TWEAK_H
#define __PITU_TWEAK_H

#include <stdio.h>

//cydia substrate
#include <substrate.h>
#include <logos/logos.h>


//ios
#import <UIKit/UIKit.h>
//#import <GLKit/GLKit.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreGraphics/CoreGraphics.h>
//#import <OpenGLES/ES2/gl.h>
//#import <OpenGLES/ES2/glext.h>

@interface CosmeticViewController : NSObject
{
    
}

- (void)getHairmaskUploadImage:(id)arg1 index:(int)arg2;
@property(retain, nonatomic) UIImage *hairMask; // @synthesize hairMask=_hairMask;
@end


@interface UIImage (Resize)
- (id)aspectFillImageWithSize:(struct CGSize)arg1 redrawAnyway:(BOOL)arg2;
- (id)cropImageWithFrame:(struct CGRect)arg1;
- (id)resizeImageByHighQuality:(BOOL)arg1;
- (id)resizeImageByLongSide:(int)arg1;
- (id)resizeImageByQuality;
- (id)resizeImageContext:(id)arg1 size:(struct CGSize)arg2;
- (id)resizeImageCrazyWithMaxSize:(struct CGSize)arg1;
- (id)resizeImageWithMaxSize:(struct CGSize)arg1;
- (id)resizeImageWithMaxSize:(struct CGSize)arg1 andBound:(float)arg2 redrawAnyway:(BOOL)arg3;
- (id)resizeImageWithMaxSize:(struct CGSize)arg1 redrawAnyway:(BOOL)arg2;
- (id)resizeImageWithNewSize:(struct CGSize)arg1;
- (id)resizeImageWithNewSize:(struct CGSize)arg1 withCapInsets:(struct UIEdgeInsets)arg2;
- (id)resizeImageWithSize:(struct CGSize)arg1;
- (id)resizedImage:(struct CGSize)arg1 interpolationQuality:(int)arg2;
- (id)resizedImage:(struct CGSize)arg1 transform:(struct CGAffineTransform)arg2 drawTransposed:(BOOL)arg3 interpolationQuality:(int)arg4;
- (id)resizedImageWithContentMode:(int)arg1 bounds:(struct CGSize)arg2 interpolationQuality:(int)arg3;
- (id)rotate:(int)arg1;
- (id)screenSizeImageWithRedraw:(BOOL)arg1;
- (struct CGAffineTransform)transformForOrientation:(struct CGSize)arg1;
@end

@interface NSData (MD5)
- (id)MD5String;
@end


void SavePostHairMaskPic(NSString *fileName,NSString *fileDir,NSUInteger iNum, void(^completion)(void));

#endif