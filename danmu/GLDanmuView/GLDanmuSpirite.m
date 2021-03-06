//
//  GLDanmuSpirite.m
//  danmu
//
//  Created by newworld on 16/10/18.
//  Copyright © 2016年 siyuxing. All rights reserved.
//
#import "GLDanmuSpirite.h"
#import <OpenGLES/ES2/glext.h>
#import <OpenGLES/ES3/glext.h>
#import "NSAttributedString+Image.h"

typedef struct {
    float Position[3];
    float Color[4];
    float TexCoord[2];
}Vertex;

//顶点信息
static const Vertex Vertices[] = {
    {{1.0, 0.0, 0.0}, {1, 1, 1, 1}, {1, 1}},
    {{1.0, 1.0, 0.0}, {1, 1, 1, 1}, {1, 0}},
    {{0.0, 1.0, 0.0}, {1, 1, 1, 1}, {0, 0}},
    {{0.0, 0.0, 0.0}, {1, 1,1, 1}, {0, 1}},
};

const GLubyte Indices[] = {
    //两个三角形，六个顶点,依次绘制
    0, 1, 2,
    2, 3, 0,
};

@interface GLDanmuSpirite ()
{
    GLuint VBO;
    GLuint VAO;
    GLuint IBO;
}
@property (nonatomic,strong) GLKBaseEffect *effect;
@property (nonatomic) GLKTextureInfo *textureInfo;

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
        [self genAndBindGLBuffer];
    }
    
    return self;
}

- (instancetype) init
{
    return [self initWithImage:nil Effect:nil];
}

- (void) dealloc
{
    [self deleteBuffer];
}

- (void) deleteBuffer
{
    if (VAO) {
        glDeleteBuffers(1, &VAO);
    }
    if (VBO) {
        glDeleteBuffers(1, &VBO);
    }
    if (IBO) {
        glDeleteBuffers(1, &IBO);
    }
}

- (void) genAndBindGLBuffer
{
    glGenVertexArraysOES(1, &VAO);
    glBindVertexArrayOES(VAO);
    
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &IBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, IBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    
    //position
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Position));
    //texCoord
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, TexCoord));
    
    glBindVertexArrayOES(0);
}

- (void) renderWithModelViewMatrix:(GLKMatrix4)modelViewMatrix
{
    [super renderWithModelViewMatrix:modelViewMatrix];

    self.effect.texture2d0.enabled = GL_TRUE;
    self.effect.texture2d0.name = self.textureInfo.name;
    self.effect.constantColor = GLKVector4Make(0.3, 0.4, 1.0, 1.0);
    
    //设置Model矩阵
    self.effect.transform.modelviewMatrix = GLKMatrix4Multiply(modelViewMatrix, [self modelMatrix:YES]);
    self.effect.transform.modelviewMatrix = GLKMatrix4Scale(self.effect.transform.modelviewMatrix, self.contentsize.width/2, self.contentsize.height/2, 0.0);

    [self.effect prepareToDraw];
    glBindVertexArrayOES(VAO);
    //此处不知道为何要画六个点
    glDrawElements(GL_TRIANGLE_STRIP, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
    //MARK:此处如果不进行解绑，在创建新的弹幕精灵进行顶点数组绑定时会产生崩溃;
    glBindVertexArrayOES(0);
    
}

#pragma mark - test

- (void) testMatrix
{
    GLKMatrix4 projectionMatrix = self.effect.transform.projectionMatrix;
    GLKMatrix4 modelMatrix = self.effect.transform.modelviewMatrix;
    GLKMatrix4 result = GLKMatrix4Multiply(projectionMatrix, modelMatrix);
    GLKMatrix4 position = GLKMatrix4Make(0, 0, 0, 1, self.textureInfo.width, 0, 0, 1, 0, self.textureInfo.height, 0, 1, self.textureInfo.width, self.textureInfo.height, 0, 1);
    GLKMatrix4 final = GLKMatrix4Multiply(result, position);
}


@end
