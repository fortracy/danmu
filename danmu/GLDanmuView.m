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
    
    GLuint colorRenderBuffer;
    GLuint framebuffer;
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

- (instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupLayer];
        [self setupContext];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self setUpEffect];
        [self setUpBuffer];
        [self setupDisplayLink];
        [self setUpTouchable];
    }
    return self;
}

- (void) dealloc
{
    if (colorRenderBuffer) {
        glDeleteRenderbuffers(1, &colorRenderBuffer);
    }
    if (framebuffer) {
        glDeleteFramebuffers(1, &framebuffer);
    }
    if ([EAGLContext currentContext] == glcontext){
        [EAGLContext setCurrentContext:nil];
    }
}


- (void) layoutSubviews
{
    [super layoutSubviews];
}

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
}

- (void) setUpEffect
{
    effect = [[GLKBaseEffect alloc] init];
    float right = CGRectGetWidth(self.bounds);
    float bottom = CGRectGetHeight(self.bounds);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, right,0,bottom, -1024, 1024);
    effect.transform.projectionMatrix = projectionMatrix;
}

- (void) setUpTouchable
{
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(DanmuIsTapped:)];
    [self addGestureRecognizer:tgr];
    
}

- (void) setUpBuffer
{
    self.danmuSpiriteArray = [NSMutableArray new];
}

- (void) setupRenderBuffer
{
    glGenRenderbuffers(1, &colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
    [glcontext renderbufferStorage:GL_RENDERBUFFER fromDrawable:eaglLayer];
}

- (void) setupFrameBuffer
{
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, colorRenderBuffer);
}


#pragma mark - operation

- (BOOL) isWork
{
    return !displayLink.paused;
}

- (void) clear
{
    [self.danmuSpiriteArray removeAllObjects];
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
    [self display:displayLink.duration];
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
    glClearColor(1.0,1.0,1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    float width = CGRectGetWidth(self.bounds);
    float height = CGRectGetHeight(self.bounds);
    glViewport(0, 0, width, height);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    for (GLNode *node in self.danmuSpiriteArray) {
        [node renderWithModelViewMatrix:GLKMatrix4Identity];
    }
    [glcontext presentRenderbuffer:GL_RENDERBUFFER];

    
}

#pragma mark - public

- (void) shootADanmuWithAttributedString:(NSAttributedString *)content index:(NSUInteger)index speed:(CGFloat)speed
{
    if (content && content.length>0) {
        UIImage *contentImage = [content contentImage];
        GLDanmuSpirite *danmuSpirite = [[GLDanmuSpirite alloc] initWithImage:contentImage Effect:effect];
        CGFloat Viewheight = CGRectGetHeight(self.bounds);
        CGFloat channelHeight = Viewheight/channelCount;
        CGFloat x = CGRectGetWidth(self.bounds)+danmuSpirite.contentsize.width/2;
        CGFloat y = (index+0.5)*channelHeight;
        danmuSpirite.position = GLKVector2Make(x,y);
        danmuSpirite.moveVelocity = GLKVector2Make(-50.0, 0.0);
        
        [self.danmuSpiriteArray addObject:danmuSpirite];
    }
}

#pragma mark - UIGestureRecognizer

- (void) DanmuIsTapped:(UIGestureRecognizer *)gr
{
    CGPoint touchLocation = [gr locationInView:gr.view];
    //MARK:需要将UIKit和Opengl的坐标原点进行转换;
    touchLocation = CGPointMake(touchLocation.x, touchLocation.y);
    for(GLNode *node in self.danmuSpiriteArray){
       bool contained = CGRectContainsPoint([node boundingBox], touchLocation);
        if (contained) {
            
        }
    }
}



@end
