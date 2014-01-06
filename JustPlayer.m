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


@synthesize assetURL, playerItem, player, timeObserver;

- (CMTime)currentTime
{
    return player.currentTime;
}

- (AVPlayerItem*)currentItem
{
    return player.currentItem;
}

- (void)cleanPreviousResources
{
    [player.currentItem removeObserver: self forKeyPath: @"status"];
    [player.currentItem removeObserver: self forKeyPath: @"loadedTimeRanges"];
    [self removeScrubberTimer];
}

- (void)prepareForURL:(NSURL*)url
{
    assetURL = url;
    [self cleanPreviousResources];
    playerItem = [AVPlayerItem playerItemWithURL: url];

    [playerItem addObserver: self forKeyPath: @"status" options: NSKeyValueObservingOptionNew context: &PlayerItemStatusContext];
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options: NSKeyValueObservingOptionNew context:PlayerItemTimeRangesObservationContext];
    player = [AVPlayer playerWithPlayerItem: playerItem];

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
    [player pause];
}

- (BOOL)isPlaying
{
    return ([player rate] != 0.0);
}

- (void)play
{
    [player play];

}

- (void)playerSeekto:(float)position
{
    playerItem = player.currentItem;
    float totalTime = CMTimeGetSeconds( [self playerItemDuration] );
    CMTime scrubToTime = CMTimeMakeWithSeconds(totalTime * position, NSEC_PER_SEC);

    [playerItem seekToTime: scrubToTime];
}



- (CMTime)playerItemDuration
{
	AVPlayerItem *thePlayerItem = [player currentItem];
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
	timeObserver = [player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
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
	if (timeObserver)
	{
		[player removeTimeObserver:timeObserver];
		timeObserver = nil;
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
            NSValue* value = [times objectAtIndex:0];

            CMTimeRange range;
            [value getValue:&range];
            float start = CMTimeGetSeconds(range.start);
            float duration = CMTimeGetSeconds(range.duration);

            self.blkPlayerItemLoadTimeRange(start, duration);
        }
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object
                           change:change context:context];
    return;
}
@end
