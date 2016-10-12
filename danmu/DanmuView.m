//
//  DanmuView.m
//  danmu
//
//  Created by newworld on 16/10/1.
//  Copyright © 2016年 siyuxing. All rights reserved.
//

#import "DanmuView.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <CoreText/CoreText.h>
#import "DanmuSpirite.h"
#import <GLKit/GLKit.h>

typedef struct {
    float Position[3];
    float Color[4];
    float TexCoord[2];
}Vertex;

static const Vertex Vertices[] = {
    {{1.0, 0.0, 0.0}, {1, 1, 1, 1}, {1, 1}},
    {{1.0, 1.0, 0.0}, {1, 1, 1, 1}, {1, 0}},
    {{0.0, 1.0, 0.0}, {1, 1, 1, 1}, {0, 0}},
    {{0.0, 0.0, 0.0}, {1, 1,1, 1}, {0, 1}},
};

static const GLubyte Indices[] = {
    1, 0, 2, 3
};



@class DanmuSpirite;

@interface DanmuView ()
{
    CAEAGLLayer *eaglLayer;
    EAGLContext *glcontext;
    
    CADisplayLink *displayLink;
    NSMutableArray *danmuSpirites;
    NSMutableArray *channelArray;
    
    //shader
    GLuint programHandle;
    GLuint positionSlot;
    GLuint colorSlot;
    GLuint texCoordSlot;
    GLuint textureUniform;
    GLuint gModelUniform;
    GLuint gWorldUniform;
    //buffer
    GLuint VBO;
    GLuint IBO;
    GLuint colorRenderBuffer;
    GLuint framebuffer;
    
    size_t backingWidth;
    size_t backingHeight;
}

@end


@implementation DanmuView


- (instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupLayer];
        [self setupContext];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self setupDanmuSpirites];
        [self setupDisplayLink];
        [self setupShader];
        [self setupIBO];
        [self setupVBO];
    }
    
    return self;
}


- (void) dealloc
{
    if (programHandle) {
        glDeleteProgram(programHandle);
    }
    if (colorRenderBuffer) {
        glDeleteRenderbuffers(1, &colorRenderBuffer);
    }
    if (framebuffer) {
        glDeleteBuffers(1, &framebuffer);
    }
    if (IBO) {
        glDeleteBuffers(1, &IBO);
    }
    if (VBO) {
        glDeleteBuffers(1, &VBO);
    }
    if ([EAGLContext currentContext] == glcontext){
        [EAGLContext setCurrentContext:nil];
    }
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

- (void) setupRenderBuffer
{
    glGenRenderbuffers(1, &colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
    [glcontext renderbufferStorage:GL_RENDERBUFFER fromDrawable:eaglLayer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
}

- (void) setupFrameBuffer
{
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, colorRenderBuffer);
}

- (void) setupDanmuSpirites
{
    danmuSpirites = [NSMutableArray new];
}

- (void) setupDisplayLink
{
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(display:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void) setupIBO
{
    glGenBuffers(1, &IBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, IBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
}

- (void) setupVBO
{
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
}

- (void) setUpDanmuChannel:(NSUInteger)channelCount
{
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

- (void) setupShader
{
    GLuint vertexShader = [self compileShader:@"DanmuVertex"
                                     withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"DanmuFragment"
                                       withType:GL_FRAGMENT_SHADER];
    
    programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    // 4
    glUseProgram(programHandle);
    
    positionSlot = glGetAttribLocation(programHandle, "Position");
    colorSlot = glGetAttribLocation(programHandle, "sourceColor");
    glEnableVertexAttribArray(positionSlot);
    glEnableVertexAttribArray(colorSlot);
    
    
    //texture
    texCoordSlot = glGetAttribLocation(programHandle, "TexCoordIn");
    glEnableVertexAttribArray(texCoordSlot);
    textureUniform = glGetUniformLocation(programHandle, "Texture");
    gModelUniform = glGetUniformLocation(programHandle, "gModel");
    gWorldUniform = glGetUniformLocation(programHandle, "gWorld");
    
    //MARK:由于UIKit和opengl的坐标原点不同，这里应该注意bottom和top的设置
    GLKMatrix4 World=   GLKMatrix4MakeOrtho(0.0, backingWidth ,backingHeight,0.0  , -1.0, 1.0);
    glUniformMatrix4fv(gWorldUniform, 1, 0, World.m);
}

- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType
{
    // 1
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName
                                                           ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath
                                                       encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    // 2
    GLuint shaderHandle = glCreateShader(shaderType);
    
    // 3
    const char* shaderStringUTF8 = [shaderString UTF8String];
    NSUInteger shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    // 4
    glCompileShader(shaderHandle);
    
    // 5
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shaderHandle;

}

#pragma mark - public


- (void) shootADanmuWithAttributedString:(NSAttributedString *)content index:(NSUInteger)index speed:(CGFloat)speed
{
    if (content && content.length>0) {
        UIImage *contentImage = [self drawAImage:content];
        NSDictionary *channelDic = channelArray[index];
        NSValue *startValue = [channelDic objectForKey:@"start"];
        NSValue *endValue = [channelDic objectForKey:@"end"];
        DanmuSpirite *spirite = [[DanmuSpirite alloc] initWithStart:startValue.CGPointValue End:endValue.CGPointValue Speed:speed content:contentImage];

        [danmuSpirites addObject:spirite];
    }
}

- (void) shootAAnimationWithAttributedString:(NSAttributedString *)content index:(NSUInteger)index speed:(CGFloat)speed
{
    if (content && content.length>0) {
        UILabel *alabel = [UILabel new];
        alabel.attributedText = content;
        [alabel sizeToFit];
        
        NSDictionary *channelDic = channelArray[index];
        NSValue *startValue = [channelDic objectForKey:@"start"];
        NSValue *endValue = [channelDic objectForKey:@"end"];
        
        CGPoint startPoint = startValue.CGPointValue;
        CGPoint endPoint = endValue.CGPointValue;
        
        alabel.frame = CGRectMake(startPoint.x, startPoint.y, CGRectGetWidth(alabel.frame), CGRectGetHeight(alabel.frame));
        [self addSubview:alabel];
        
        [UIView animateWithDuration:3.0 animations:^{
            alabel.frame = CGRectMake(endPoint.x-CGRectGetWidth(alabel.frame), endPoint.y, CGRectGetWidth(alabel.frame), CGRectGetHeight(alabel.frame));
        } completion:^(BOOL finished) {
            [alabel removeFromSuperview];
        }];
    }
}

- (void) update:(BOOL)state
{
    if (displayLink) {
        displayLink.paused = !state;
    }
}

#pragma mark - CoreText

- (UIImage *) drawAImage:(NSAttributedString *)attributedString
{
    
    UIImage *image = nil;
    CGSize stringSize = [self sizeofAnAttributedString:attributedString];
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
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, [attributedString length]), path, NULL);
    CTFrameDraw(frame, context);
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    CFRelease(frame);
    CFRelease(path);
    CFRelease(frameSetter);
    return image;
}




- (CGSize) sizeofAnAttributedString:(NSAttributedString *)attributedString
{
    CGSize size = CGSizeZero;
    
    CGFloat maxWidth = MAXFLOAT;
    CGFloat maxHeight = MAXFLOAT;
    CGSize maxSize = CGSizeMake(maxWidth, maxHeight);
    
    CGRect rect = [attributedString boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil];
    
    //MARK:向上取整，防止字体过大时无法渲染;
    size.height = ceilf(rect.size.height);
    size.width = ceilf(rect.size.width);
    
    
    return size;
}


#pragma mark - refresh

- (void) display:(CADisplayLink *)displayLink
{
    [self _update:displayLink];
    [self _display:displayLink];
}



- (void) _update:(CADisplayLink *)displayLink
{
    NSMutableArray *tempDanmuSpirites = (NSMutableArray *)[NSArray arrayWithArray:danmuSpirites];
    for (DanmuSpirite * spirite in tempDanmuSpirites) {
        [spirite update:displayLink];
        if (spirite.finish) {
            [danmuSpirites removeObject:spirite];
        }
    }
}

- (void) _display:(CADisplayLink *)displayLink
{
    if (danmuSpirites.count == 0) {
        glClearColor(1, 1, 1, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
        glViewport(0, 0, backingWidth, backingHeight);
        [glcontext presentRenderbuffer:GL_RENDERBUFFER];

        return;
    }
    
    glClearColor(0, 0.0,0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, backingWidth, backingHeight);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    glBindBuffer(GL_ARRAY_BUFFER , VBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, IBO);
    
    for (DanmuSpirite *danmu in danmuSpirites) {
        [self _render:danmu];
    }
    
    [glcontext presentRenderbuffer:GL_RENDERBUFFER];

}

- (void) _render:(DanmuSpirite *)danmu
{
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, danmu.texture);
    glUniform1i(textureUniform, 0);
    glUniformMatrix4fv(gModelUniform, 1, 0,danmu.Model.m);
    
    glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glVertexAttribPointer(colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)(sizeof(float)*3));
    glVertexAttribPointer(texCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)(sizeof(float)*7));
    glDrawElements(GL_TRIANGLE_STRIP, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
