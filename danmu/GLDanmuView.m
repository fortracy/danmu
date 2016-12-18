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
    NSUInteger _channelCount;
    CGFloat channelHeight;
    UIColor *defaultColor;
    UIFont *defaultFont;
    CGFloat defaultSpeed;
    GLKBaseEffect *effect;
    
    GLuint colorRenderBuffer;
    GLuint framebuffer;
}

@property (nonatomic) NSMutableArray *GLNodeArray;

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
        [self setup];
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

- (void) setup
{
    [self setupLayer];
    [self setupContext];
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    [self setUpEffect];
    [self setUpBuffer];
    [self setupDisplayLink];
    [self setUpTouchable];
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

- (void) setUpEffect
{
    effect = [[GLKBaseEffect alloc] init];
    float right = CGRectGetWidth(self.bounds);
    float bottom = CGRectGetHeight(self.bounds);
    //MARK:设置投影矩阵
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
    self.GLNodeArray = [NSMutableArray new];
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

- (BOOL) isPlay
{
    return !displayLink.paused;
}

- (void) clear
{
    [self.GLNodeArray removeAllObjects];
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
        [self configDanmuView];
    }
}

- (void) restart
{
    [self pause];
    [self clear];
    [self play];
}

- (void) configDanmuView
{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(channelCountInDanmuView:)]) {
        _channelCount = [self.dataSource channelCountInDanmuView:self];
        CGFloat Viewheight = CGRectGetHeight(self.bounds);
        if (_channelCount) {
            channelHeight = Viewheight/_channelCount;
        }
    }
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(defaultColorInDanmuView:)]) {
        defaultColor = [self.dataSource defaultColorInDanmuView:self];
    }
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(defaultFontIndanmuView:)]) {
        defaultFont = [self.dataSource defaultFontIndanmuView:self];
    }
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(defaultSpeedIndanmuView:)]) {
        defaultSpeed = [self.dataSource defaultSpeedIndanmuView:self];
    }
}

- (void) refresh:(CADisplayLink *)displaylink
{
    [self update:displayLink.duration];
    [self display:displayLink.duration];
}

- (void) update:(float)dt
{
    NSMutableArray *tempDanmuSpirites = (NSMutableArray *)[NSArray arrayWithArray:self.GLNodeArray];
    for (GLNode * node in tempDanmuSpirites) {
        [node update:dt];
        if (CGRectIsNull(CGRectIntersection(self.bounds, [node boundingBox]))) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(danmuView:didEndDisplayDanmuSpirite:channelIndex:)]) {
                [self.delegate danmuView:self didEndDisplayDanmuSpirite:node channelIndex:[self indexPathForNode:node]];
            }
            [self.GLNodeArray removeObject:node];
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
    
    for (GLNode *node in self.GLNodeArray) {
        [node renderWithModelViewMatrix:GLKMatrix4Identity];
    }
    [glcontext presentRenderbuffer:GL_RENDERBUFFER];

    
}

#pragma mark - public

- (void) shootADanmuWithAttributedString:(NSAttributedString *)content index:(NSUInteger)index speed:(CGFloat)speed
{
    if (content && content.length>0 && [self isPlay] && index<_channelCount && _channelCount && speed) {
        UIImage *contentImage = [content contentImage];
        GLDanmuSpirite *danmuSpirite = [[GLDanmuSpirite alloc] initWithImage:contentImage Effect:effect];
        CGFloat x = CGRectGetWidth(self.bounds)+danmuSpirite.contentsize.width/2;
        CGFloat y = (index+0.5)*channelHeight;
        danmuSpirite.position = GLKVector2Make(x,y);
        danmuSpirite.moveVelocity = GLKVector2Make(speed, 0.0);
        
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(danmuView:willDisplayDanmuSpirite:channelIndex:)]) {
            [self.delegate danmuView:self willDisplayDanmuSpirite:danmuSpirite channelIndex:[self indexPathForNode:danmuSpirite]];
        }
        [self.GLNodeArray addObject:danmuSpirite];
    }
}
- (void) shootADanmuWithString:(NSString *)content index:(NSUInteger)index
{
    if (defaultFont && defaultColor) {
        NSMutableAttributedString *mutableattributedString = [[NSMutableAttributedString alloc] initWithString:content];
        [mutableattributedString addAttribute:NSForegroundColorAttributeName value:defaultColor range:NSMakeRange(0, mutableattributedString.string.length)];
        [mutableattributedString addAttribute:NSFontAttributeName value:defaultFont range:NSMakeRange(0,mutableattributedString.string.length)];
        [self shootADanmuWithAttributedString:mutableattributedString index:index speed:defaultSpeed];
    }
}

- (NSIndexPath *)indexPathForPoint:(CGPoint)point
{
    NSIndexPath *indexPath = nil;
    indexPath = [[NSIndexPath alloc] initWithIndex:ceilf(point.y/channelHeight)-1];
    return indexPath;
}

- (NSIndexPath *)indexPathForNode:(GLNode *)node
{
    CGPoint nodePoint  = CGPointMake(node.position.x, node.position.y);
    return [self indexPathForPoint:nodePoint];
}

#pragma mark - UIGestureRecognizer

- (void) DanmuIsTapped:(UIGestureRecognizer *)gr
{
    CGPoint touchLocation = [gr locationInView:gr.view];
    //MARK:需要将UIKit和Opengl的坐标原点进行转换;
    touchLocation = CGPointMake(touchLocation.x, touchLocation.y);
    for(GLNode *node in self.GLNodeArray){
       bool contained = CGRectContainsPoint([node boundingBox], touchLocation);
        if (contained) {
            //TODO:事件传递
        }
    }
}



@end
