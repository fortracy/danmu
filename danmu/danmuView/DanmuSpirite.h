//
//  DanmuSpirite.h
//  danmu
//
//  Created by newworld on 16/10/1.
//  Copyright © 2016年 siyuxing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface DanmuSpirite : NSObject

@property (nonatomic) CGPoint start;
@property (nonatomic) CGPoint end;
@property (nonatomic) CGFloat speed;
@property (nonatomic) UIImage *contentImage;
@property (nonatomic) GLKVector3 currentVector;
@property (nonatomic) GLKVector3 startVector;
@property (nonatomic) GLKVector3 endVector;
@property (nonatomic) GLuint texture;
@property (nonatomic) size_t textureWidth;
@property (nonatomic) size_t textureHeight;

@property (nonatomic) GLKMatrix4 Model;

@property (nonatomic) BOOL finish;

- (instancetype) initWithStart:(CGPoint)start End:(CGPoint)end Speed:(CGFloat)speed content:(UIImage *)contentImage;



- (void) update:(CADisplayLink *)displayLink;



@end
