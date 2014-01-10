# Just Player

## Overview
Just Player is a very simple wrapper for Cocoa AVPlayer. It wrapps complicated usage of AVPlayer. For those who want to use AVPlayer in a super easy way, and tweek in her/his later need.

## Steps of Usage

Assume we declare a 'player' property of type JustPlayer* in our view controller like this:

``` objective-c

	#import "JustPlayer.h"
	#import "JustPlayerLayerView.h"

	@interface ViewController ()
	@property (nonatomic, strong) JustPlayer *player;
	@end
```	

### allocate

``` objective-c
	self.player = [[JustPlayer alloc] init];
```

### ready to play block

When it is ready to play, this block will be called.

Basically we have to call [play:] inside, you can
tweek your own.

``` objective-c
	__weak ViewController *weak = self;

	self.player.blkPlayerItemReady = ^(AVPlayerItemStatus

	status) {

        if (AVPlayerItemStatusReadyToPlay == status) {

            [weak.player play];

        }
        else {

            NSLog(@"player item status is %d", status);

        }
    };
```

### load range block (optional)

On playing, it will fetch next segmant of video asset, and
notifies us.

``` objective-c
	    self.player.blkPlayerItemLoadTimeRange = ^(float start, float duration) {

        NSLog(@"get range (%.1f, %.1f)", start, duration);

    };
```

### setup URL to play

``` objective-c
	    [self.player prepareForURL: url];
```

### setup display

Use storyboard to add a UIView UI object, set it as JustPlayerLayerView class, and make it as an outlet of
your view controller, say :

``` objective-c
	#import "JustPlayerLayerView.h"
	@interface ViewController : UIViewController
	@property (weak, nonatomic) IBOutlet JustPlayerLayerView *playerLayer;
```

Set the outlet view as the 'display' of JustPlayer:

``` objective-c
	[self.playerLayer setPlayer: self.player.player];
```

### note

For complete demo please reference the SamplePlayer project.

## License
JustPlayer is available under the MIT license. See the LICENSE file for more info.