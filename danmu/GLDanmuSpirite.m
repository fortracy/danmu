//
//  GLDanmuSpirite.m
//  danmu
//
//  Created by newworld on 16/10/18.
//  Copyright © 2016年 siyuxing. All rights reserved.
//
#import "GLDanmuSpirite.h"

typedef struct
{
    CGPoint geometryVertex;
    CGPoint textureVertex;
}_TexturedVertex;

typedef struct
{
    _TexturedVertex bl;
    _TexturedVertex br;
    _TexturedVertex tl;
    _TexturedVertex tr;
    
}TexturedQuad_t;






@interface GLDanmuSpirite ()

@property (nonatomic) GLKBaseEffect *effect;
@property (nonatomic) GLKTextureInfo *textureInfo;
@property (assign) TexturedQuad_t quad;

@end

@implementation GLDanmuSpirite

- (instancetype) initWithImage:(UIImage *)image Effect:(GLKBaseEffect *)effect
{
    if (self = [super init]) {
        self.effect = effect;
        
        NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithBool:YES],
                                  GLKTextureLoaderOriginBottomLeft,
                                  nil];
        
        NSError *error;
        self.textureInfo = [GLKTextureLoader textureWithCGImage:image.CGImage options:options error:&error];
        if (self.textureInfo == nil) {
            return nil;
        }
        
        self.contentsize = CGSizeMake(self.textureInfo.width, self.textureInfo.height);
        TexturedQuad_t newQuad;
        newQuad.bl.geometryVertex = CGPointMake(0, 0);
        newQuad.br.geometryVertex = CGPointMake(0, self.textureInfo.width);
        newQuad.tl.geometryVertex = CGPointMake(0, self.textureInfo.height);
        newQuad.tr.geometryVertex = CGPointMake(self.textureInfo.width, self.textureInfo.height);
        self.quad = newQuad;
        
        
    }
    
    return self;
}

- (void) renderWithModelViewMatrix:(GLKMatrix4)modelViewMatrix
{
    [super renderWithModelViewMatrix:modelViewMatrix];
    
    self.effect.texture2d0.name = self.textureInfo.name;
    self.effect.texture2d0.enabled = YES;
    self.effect.transform.modelviewMatrix = GLKMatrix4Multiply(modelViewMatrix, [self modelMatrix:YES]);
    [self.effect prepareToDraw];
    
    long offSet = (long)&_quad;
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(_TexturedVertex), (void *) (offSet + offsetof(_TexturedVertex, geometryVertex)));
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(_TexturedVertex), (void *) (offSet + offsetof(_TexturedVertex, textureVertex)));
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@end
