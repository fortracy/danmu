//
//  GLNode.h
//  danmu
//
//  Created by siyuxing on 16/10/18.
//  Copyright © 2016年 siyuxing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface GLNode : NSObject

@property(assign) GLKVector2 position;
@property(assign) CGSize contentsize;
@property (assign) GLKVector2 moveVelocity;
@property (nonatomic) NSMutableArray *children;
@property (assign) CGFloat rotation;
@property (assign) CGFloat scale;
@property (assign) CGFloat rotationVelocity;
@property (assign) CGFloat scaleVelocity;


- (void) addchild:(GLNode *)child;
- (void) update:(float)dt;
- (void) renderWithModelViewMatrix:(GLKMatrix4)modelViewMatrix;
- (CGRect) boundingBox;
- (void) handleTap:(CGPoint)touchLocation;
- (GLKMatrix4) modelMatrix:(BOOL)renderingSelf;


@end
