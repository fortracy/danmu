//
//  GLDanmuView.m
//  danmu
//
//  Created by newworld on 16/10/19.
//  Copyright © 2016年 siyuxing. All rights reserved.
//

#import "GLDanmuView.h"
#import <GLKit/GLKit.h>
#import "GLNode.h"
#import "NSAttributedString+Image.h"
#import "GLDanmuSpirite.h"

@interface GLDanmuView ()
{
    CAEAGLLayer *eaglLayer;
    EAGLContext *glcontext;
    CADisplayLink *displayLink;
    NSInteger channelCount;
    GLKBaseEffect *effect;
    NSMutableArray *channelArray;
}

@property (nonatomic) NSMutableArray *danmuSpiriteArray;


@end


@implementation GLDanmuView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - setup

+ (Class) layerClass
{
    return [CAEAGLLayer class];
}

- (void) setupLayer
{
    eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.opaque = YES;
}

- (void) setupContext
{
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    glcontext = [[EAGLContext alloc] initWithAPI:api];
    [EAGLContext setCurrentContext:glcontext];
}

- (void) setupDisplayLink
{
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(refresh:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    displayLink.paused = YES;
}

- (void) setUpDanmuChannel:(NSUInteger)channelcount
{
    channelCount = channelcount;
    CGFloat Viewheight = CGRectGetHeight(self.bounds);
    CGFloat channelHeight = Viewheight/channelCount;
    
    channelArray = [NSMutableArray new];
    for (NSUInteger index = 0; index<channelCount; index++) {
        CGFloat x = CGRectGetWidth(self.bounds);
        CGFloat y = (index+0.5)*channelHeight;
        
        CGPoint channelStart = CGPointMake(x, y);
        CGPoint channelEnd = CGPointMake(0, y);
        NSValue *startValue = [NSValue valueWithCGPoint:channelStart];
        NSValue *endValue = [NSValue valueWithCGPoint:channelEnd];
        
        NSMutableDictionary * dic = [NSMutableDictionary new];
        [dic setObject:startValue forKey:@"start"];
        [dic setObject:endValue forKey:@"end"];
        
        [channelArray addObject:dic];
    }
}

- (void) setUpEffect
{
    float right = CGRectGetWidth(self.bounds);
    float bottom = CGRectGetHeight(self.bounds);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, right,bottom, 0, -1024, 1024);
    effect.transform.projectionMatrix = projectionMatrix;
}

#pragma mark - operation

- (void) stop
{
    
}

- (void) pause
{
    if (!displayLink.paused) {
        displayLink.paused = YES;
    }
}

- (void) play
{
    if (displayLink.paused) {
        displayLink.paused = NO;
    }
}

- (void) refresh:(CADisplayLink *)displaylink
{
    [self update:displayLink.duration];
}

- (void) update:(float)dt
{
    NSMutableArray *tempDanmuSpirites = (NSMutableArray *)[NSArray arrayWithArray:self.danmuSpiriteArray];
    for (GLNode * node in tempDanmuSpirites) {
        [node update:dt];
        if (CGRectIsNull(CGRectIntersection(self.bounds, [node boundingBox]))) {
            [self.danmuSpiriteArray removeObject:node];
        }
    }
}

- (void) display:(float)dt
{
    glClearColor(0, 0.0,0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    float width = CGRectGetWidth(self.bounds);
    float height = CGRectGetHeight(self.bounds);
    glViewport(0, 0, width, height);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    for (GLNode *node in self.danmuSpiriteArray) {
        [node renderWithModelViewMatrix:GLKMatrix4Identity];
    }
    [glcontext presentRenderbuffer:GL_RENDERBUFFER];

    
}

#pragma marl - public

- (void) shootADanmuWithAttributedString:(NSAttributedString *)content index:(NSUInteger)index speed:(CGFloat)speed
{
    if (content && content.length>0) {
        UIImage *contentImage = [content contentImage];
        NSDictionary *channelDic = channelArray[index];
        NSValue *startValue = [channelDic objectForKey:@"start"];
        GLDanmuSpirite *danmuSpirite = [[GLDanmuSpirite alloc] initWithImage:contentImage Effect:effect];
        danmuSpirite.position = GLKVector2Make(startValue.CGPointValue.x,startValue.CGPointValue.y);
        danmuSpirite.moveVelocity = GLKVector2Make(-speed, 0.0);
        
        [self.danmuSpiriteArray addObject:danmuSpirite];
    }
}



@end
