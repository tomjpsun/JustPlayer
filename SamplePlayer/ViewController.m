//
//  ViewController.m
//  SamplePlayer
//
//  Created by JP.Sun on 2013/12/23.
//  Copyright (c) 2013年 Coding-Addict. All rights reserved.
//

#import "ViewController.h"
#import "JustPlayer.h"
#import "JustPlayerLayerView.h"

@interface ViewController ()
@property (nonatomic, strong) JustPlayer *player;
@end

@implementation ViewController

//#define kSampleURL @"http://devimages.apple.com/samplecode/adDemo/ad.m3u8"
#define kSampleURL @"http://file.crdo.in/prt%2F%E4%B8%8D%E5%8F%AA%E6%98%AF%E5%B4%91%E6%9B%B2%2Faudio%2FKUN-20150329.mp3"
- (void)viewDidLoad
{
    [super viewDidLoad];

	NSURL *url = [NSURL URLWithString: kSampleURL];
    self.player = [[JustPlayer alloc] init];

    __weak ViewController *weak = self;
    self.player.blkPlayerItemReady = ^(AVPlayerItemStatus status) {

        if (AVPlayerItemStatusReadyToPlay == status) {

            [weak.player play];

        }
        else {

            NSLog(@"player item status is %ld", status);

        }
    };


    self.player.blkPlayerItemLoadTimeRange = ^(float start, float duration) {

        NSLog(@"get range (%.1f, %.1f)", start, duration);

    };

    [self.player prepareForURL: url];

    // set the display outlet to the player
    [self.playerLayer setPlayer: self.player.player];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
