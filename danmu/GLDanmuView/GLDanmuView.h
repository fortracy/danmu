//
//  GLDanmuView.h
//  danmu
//
//  Created by newworld on 16/10/19.
//  Copyright © 2016年 siyuxing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLDanmuProtocol.h"

@class GLDanmuView;
@class GLNode;

@interface GLDanmuView : UIView


#pragma mark - operation

- (void) clear;

- (void) pause;

- (void) play;

- (BOOL) isPlay;

- (void) restart;

#pragma mark - public

- (void) shootADanmuWithString:(NSString *)content index:(NSUInteger)index;

- (void) shootADanmuWithAttributedString:(NSAttributedString *)content index:(NSUInteger)index speed:(CGFloat)speed;

- (NSIndexPath *)indexPathForPoint:(CGPoint)point;

- (NSIndexPath *)indexPathForNode:(GLNode *)node;

#pragma mark - property

@property (nonatomic,readonly) NSUInteger channelCount;
@property (nonatomic,weak) id<GLDanmuViewDataSource> dataSource;
@property (nonatomic,weak) id<GLDanmuViewDelegate> delegate;

@end
