//
//  GLDanmuView.h
//  danmu
//
//  Created by newworld on 16/10/19.
//  Copyright © 2016年 siyuxing. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLDanmuView;

@protocol GLDanmuViewDataSource <NSObject>

- (NSInteger) channelCountInDanmuView:(GLDanmuView *)danmuView;

@end

@protocol  GLDanmuViewDelegate <NSObject>

- (void) danmuSpiriteIsTouched:(NSIndexPath*)indexPath;

@end



@interface GLDanmuView : UIView

- (void) clear;
- (void) pause;
- (void) play;
- (BOOL) isWork;

- (void) shootADanmuWithAttributedString:(NSAttributedString *)content index:(NSUInteger)index speed:(CGFloat)speed;

- (void) setUpDanmuChannel:(NSUInteger)channelcount;
@property (nonatomic) NSUInteger channelCount;


@property (nonatomic,weak) id<GLDanmuViewDataSource> dataSource;
@property (nonatomic,weak) id<GLDanmuViewDelegate> delegate;

@end
