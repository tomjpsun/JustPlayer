//
//  JustPlayer.h
//  ROD
//
//  Created by JP.Sun on 2013/12/13.
//  Copyright (c) 2013年 Coding-Addict. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>




typedef void (^BlkSyncScrubber)(CMTime time);
typedef void (^BlkPlayerItemReady)(AVPlayerItemStatus status);
typedef void (^BlkPlayerItemLoadTimeRange)(float start, float duration);

@interface JustPlayer : NSObject

@property (nonatomic, copy) BlkSyncScrubber blkSyncScrubber;
@property (nonatomic, copy) BlkPlayerItemReady blkPlayerItemReady;
@property (nonatomic, copy) BlkPlayerItemLoadTimeRange blkPlayerItemLoadTimeRange;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;

- (JustPlayer*)initWithURL:(NSURL*)url;
- (void)play;
- (void)pause;
- (CMTime)currentTime;
- (void)playerSeekto:(float)position;
- (BOOL)isPlaying;
- (void)prepareForURL:(NSURL*)url;
- (CMTime)playerItemDuration;
- (AVPlayerItem*)currentItem;
- (void)initScrubberTimer;
@end
