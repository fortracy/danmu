//
//  GLDanmuView.h
//  danmu
//
//  Created by newworld on 16/10/19.
//  Copyright © 2016年 siyuxing. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLDanmuView;
@class GLNode;

@protocol GLDanmuViewDataSource <NSObject>

- (NSUInteger) channelCountInDanmuView:(GLDanmuView *)danmuView;

- (UIColor  *) defaultColorInDanmuView:(GLDanmuView *)danmuView;

- (UIFont *) defaultFontIndanmuView:(GLDanmuView *)danmuView;

- (CGFloat) defaultSpeedIndanmuView:(GLDanmuView *)danmuView;

@end

@protocol  GLDanmuViewDelegate <NSObject>

- (void) danmuSpiriteIsTouched:(GLNode*)danmuSpirite;

- (void) danmuView:(GLDanmuView *)danmuView willDisplayDanmuSpirite:(GLNode *)danmuSpirite channelIndex:(NSIndexPath *)indexPath;

- (void) danmuView:(GLDanmuView *)danmuView didEndDisplayDanmuSpirite:(GLNode *)danmuSpirite channelIndex:(NSIndexPath *)indexPath;

@end



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
