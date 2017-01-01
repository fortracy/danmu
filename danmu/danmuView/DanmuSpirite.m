//
//  DanmuSpirite.m
//  danmu
//
//  Created by newworld on 16/10/1.
//  Copyright © 2016年 siyuxing. All rights reserved.
//

#import "DanmuSpirite.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <GLKit/GLKit.h>

@interface DanmuSpirite ()


@end


@implementation DanmuSpirite

- (void) dealloc
{
    glDeleteTextures(1,&_texture);
}

- (instancetype) initWithStart:(CGPoint)start End:(CGPoint)end Speed:(CGFloat)speed content:(UIImage *)contentImage
{
    if (self = [self init]) {
        self.contentImage = contentImage;
        self.start = start;
        self.end = end;
        self.speed = speed;
        
    }
    return self;
}

- (void) setStart:(CGPoint)start
{
    _startVector = GLKVector3Make(start.x, start.y, 0.0);
    _currentVector = _startVector;
}

- (void) setEnd:(CGPoint)end
{
    _endVector = GLKVector3Make(end.x-_textureWidth, end.y, 0.0);
}

- (void) setContentImage:(UIImage *)contentImage
{
    CGImageRef spriteImage = contentImage.CGImage;
    
    _textureWidth = contentImage.size.width;
    _textureHeight = contentImage.size.height;
    // 2
    size_t textureWidth = CGImageGetWidth(spriteImage);
    size_t textureHeight = CGImageGetHeight(spriteImage);
    
    GLubyte * spriteData = (GLubyte *) calloc(textureWidth*textureHeight*4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, textureWidth, textureHeight, 8, textureWidth*4,
                                                       CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    // 3
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, textureWidth, textureHeight), spriteImage);
    
    CGContextRelease(spriteContext);
    
    // 4
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)textureWidth, (GLsizei)textureHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);
    _texture = texName;
}


- (void) update:(CADisplayLink *)displayLink
{
    GLKVector3 move = GLKVector3Make(-_speed, 0, 0);
    _currentVector =  GLKVector3Add(_currentVector, move);
    if (_currentVector.x < _endVector.x) {
        _finish = YES;
        return;
    }
    
    self.Model = GLKMatrix4TranslateWithVector3(GLKMatrix4Identity, _currentVector);
    
    GLKMatrix4 scale = GLKMatrix4Scale(GLKMatrix4Identity, self.textureWidth, self.textureHeight, 0.0);
    
    self.Model = GLKMatrix4Multiply(self.Model, scale);
}


@end
