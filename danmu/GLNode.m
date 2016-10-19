//
//  GLNode.m
//  danmu
//
//  Created by newworld on 16/10/18.
//  Copyright © 2016年 siyuxing. All rights reserved.
//

#import "GLNode.h"

@implementation GLNode

- (instancetype) init
{
    if (self = [super init]) {
        self.children = [NSMutableArray new];
    }
    return self;
}

- (void) addchild:(GLNode *)child
{
    [self.children addObject:child];
}

- (void) handleTap:(CGPoint)touchLocation
{
    
}

- (void) renderWithModelViewMatrix:(GLKMatrix4)modelViewMatrix
{
    GLKMatrix4 childModelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, [self modelMatrix:NO]);
    
    for (GLNode* node in self.children) {
        [node renderWithModelViewMatrix:childModelViewMatrix];
    }
}

- (void) update:(float)dt
{
    for (GLNode *node in self.children) {
        [node update:dt];
    }
    GLKVector2 curMove = GLKVector2MultiplyScalar(self.moveVelocity, dt);
    self.position = GLKVector2Add(self.position, curMove);
    
    float curRoate = self.rotationVelocity * dt;
    self.rotation = self.rotation + curRoate;
    
    float curScale = self.scaleVelocity *dt;
    self.scale = self.scale + curScale;
}

- (GLKMatrix4) modelMatrix:(BOOL)renderingSelf
{
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    GLKVector3 position = GLKVector3Make(self.position.x, self.position.y, 0.0);
    modelMatrix = GLKMatrix4TranslateWithVector3(modelMatrix, position);
    
    float radians = GLKMathDegreesToRadians(self.rotation);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, radians, 0, 0, 1);
    modelMatrix = GLKMatrix4Scale(modelMatrix, self.scale, self.scale, 0.0);
    
    if (renderingSelf) {
        modelMatrix = GLKMatrix4Translate(modelMatrix, -self.contentsize.width/2, -self.contentsize.height/2, 0);
    }
    return modelMatrix;
}

- (CGRect) boundingBox
{
    CGRect boundingBox = CGRectZero;
    boundingBox = CGRectMake(0, 0, self.contentsize.width, self.contentsize.height);
    GLKMatrix4 modelMatrix4 = [self modelMatrix:YES];
    CGAffineTransform transform = CGAffineTransformMake(modelMatrix4.m00, modelMatrix4.m01, modelMatrix4.m10, modelMatrix4.m11, modelMatrix4.m30, modelMatrix4.m31);
    
    boundingBox = CGRectApplyAffineTransform(boundingBox, transform);
    return boundingBox;
}

@end
