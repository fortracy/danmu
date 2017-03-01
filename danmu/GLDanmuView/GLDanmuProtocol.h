//
//  GLDanmuProtocol.h
//  danmu
//
//  Created by newworld on 2017/3/1.
//  Copyright © 2017年 siyuxing. All rights reserved.
//

#import <Foundation/Foundation.h>


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
