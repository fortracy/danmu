//
//  NSAttributedString+Image.m
//  danmu
//
//  Created by newworld on 16/10/19.
//  Copyright © 2016年 siyuxing. All rights reserved.
//

#import "NSAttributedString+Image.h"
#import <CoreText/CoreText.h>


@implementation NSAttributedString (Image)


- (UIImage *) contentImage
{
    UIImage *image = nil;
    CGSize stringSize = [self contentSize];
    CGRect stringRect = CGRectMake(0.0, 0.0, stringSize.width, stringSize.height);
    
    //MARK:set scale and opaque
    UIGraphicsBeginImageContextWithOptions(stringSize, NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[UIColor clearColor] setFill];
    CGContextFillRect(context, stringRect);
    
    //MARK:由于UIKit和opengl的坐标系原点不相同，所以在此不进行翻转操作
    //    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    //    CGContextTranslateCTM(context, 0, stringSize.height);
    //    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, stringRect);
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self);
    
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, [self length]), path, NULL);
    CTFrameDraw(frame, context);
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    CFRelease(frame);
    CFRelease(path);
    CFRelease(frameSetter);
    return image;
}




- (CGSize) contentSize
{
    CGSize size = CGSizeZero;
    
    CGFloat maxWidth = MAXFLOAT;
    CGFloat maxHeight = MAXFLOAT;
    CGSize maxSize = CGSizeMake(maxWidth, maxHeight);
    
    CGRect rect = [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil];
    
    //MARK:向上取整，防止字体过大时无法渲染;
    size.height = ceilf(rect.size.height);
    size.width = ceilf(rect.size.width);
    
    return size;
}


@end
