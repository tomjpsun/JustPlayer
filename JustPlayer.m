//
//  JustPlayer.m
//  ROD
//
//  Created by JP.Sun on 2013/12/13.
//  Copyright (c) 2013年 Coding-Addict. All rights reserved.
//

#import "JustPlayer.h"


static void *PlayerItemStatusContext = &PlayerItemStatusContext;
static void *PlayerItemTimeRangesObservationContext = &PlayerItemTimeRangesObservationContext;

@interface JustPlayer()

@property (nonatomic, strong) NSURL *assetURL;

@property (nonatomic, strong) id timeObserver;
@end


@implementation JustPlayer


- (CMTime)currentTime
{
    return self.player.currentTime;
}

- (AVPlayerItem*)currentItem
{
    return self.player.currentItem;
}

- (void)cleanPreviousResources
{
    if (self.playerItem) {
        [self.playerItem removeObserver: self forKeyPath: @"status"];
        [self.playerItem removeObserver: self forKeyPath: @"loadedTimeRanges"];
        [self removeScrubberTimer];
        self.playerItem = nil;
    }
}

- (void)prepareForURL:(NSURL*)url
{
    self.assetURL = url;
    
    [self cleanPreviousResources];
    self.playerItem = [AVPlayerItem playerItemWithURL: url];

    [self.playerItem addObserver: self forKeyPath: @"status" options: NSKeyValueObservingOptionNew context: &PlayerItemStatusContext];
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options: NSKeyValueObservingOptionNew context:PlayerItemTimeRangesObservationContext];
    self.player = [AVPlayer playerWithPlayerItem: self.playerItem];

}

- (JustPlayer*)initWithURL:(NSURL*)url
{
    /*  You cannot directly create an AVAsset instance to represent the media in an HTTP Live Stream,
        so create AVPlayerItem first, then it can generate corresponding AVAsset after downloading
     */

    if (self = [super init]) {
        [self prepareForURL: url];
    }
    else NSAssert(self != nil, @"JustPlayer initWithURL get nil");
    return self;
}

- (void)dealloc
{
    NSLog(@"deallocating JustPlayer %@", self);
    [self cleanPreviousResources];
}

- (void)pause
{
    [self.player pause];
}

- (BOOL)isPlaying
{
    return ([self.player rate] != 0.0);
}

- (void)play
{
    [self.player play];

}

- (void)playerSeekto:(float)position
{
    self.playerItem = self.player.currentItem;
    float totalTime = CMTimeGetSeconds( [self playerItemDuration] );
    CMTime scrubToTime = CMTimeMakeWithSeconds(totalTime * position, NSEC_PER_SEC);

    [self.playerItem seekToTime: scrubToTime];
}



- (CMTime)playerItemDuration
{
	AVPlayerItem *thePlayerItem = [self.player currentItem];
	if (thePlayerItem.status == AVPlayerItemStatusReadyToPlay)
	{
		return([thePlayerItem duration]);
	}

	return(kCMTimeInvalid);
}


- (void)initScrubberTimer
{
	double interval = .1f;

	CMTime playerDuration = [self playerItemDuration];
	if (CMTIME_IS_INVALID(playerDuration))
	{
		return;
	}

    JustPlayer *this = self;

	/* Update the scrubber during normal playback. */
	self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                           queue:NULL
                           usingBlock:
                    ^(CMTime time)
                    {
                        if (this.blkSyncScrubber != nil) {
                            this.blkSyncScrubber(time);
                        }
                    }];
}

-(void)removeScrubberTimer
{
	if (self.timeObserver)
	{
		[self.player removeTimeObserver:self.timeObserver];
		self.timeObserver = nil;
	}
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {

    if (context == &PlayerItemStatusContext) {

        // debug printing
        if (AVPlayerItemStatusReadyToPlay == self.playerItem.status) {
            NSLog(@"status ready");
        }
        else if (AVPlayerItemStatusFailed == self.playerItem.status) {
            NSLog(@"status failed: %@", self.playerItem.error);
        }
        else NSLog(@"status unknown");

        // invoke the block provided by the UI module
        if (self.blkPlayerItemReady) {
            AVPlayerItem *thePlayerItem = (AVPlayerItem*)object;
            self.blkPlayerItemReady(thePlayerItem.status);
        }
        return;

    }
    else if (context == &PlayerItemTimeRangesObservationContext) {
        if (self.blkPlayerItemLoadTimeRange) {
            AVPlayerItem* thePlayerItem = (AVPlayerItem*)object;
            NSArray* times = thePlayerItem.loadedTimeRanges;

            // there is only ever one NSValue in the array
            // could get empty array for the first time,
            // happened for some remote sites

            if (times != nil && times.count > 0) {
                NSValue* value = [times objectAtIndex:0];
                CMTimeRange range;
                [value getValue:&range];
                float start = CMTimeGetSeconds(range.start);
                float duration = CMTimeGetSeconds(range.duration);

                self.blkPlayerItemLoadTimeRange(start, duration);
            }
        }
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object
                           change:change context:context];
    return;
}
@end
