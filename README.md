## ZYVideoPlayView

 ZYVideoPlayView is a new implementation based on AVPlayer. Support MP4 and m3u8

### Example

```objc
//add videoPlayView where you want to add
ZYVideoPlayView *videoPlayView = [[ZYVideoPlayView alloc] init];
videoPlayView.frame = CGRectMake(0, 0, 320, 180);
videoPlayView.delegate = self;
videoPlayView.videoURL = [NSURL URLWithString:@"http://www.xxx.com/xxx/xxx.mp4"];
[self.view addSubview:videoPlayView];
//...

//you can get video status from these delegate methods

#pragma mark - ZYVideoPlayViewDelegate

- (void)zy_videoPlayViewReadyToPlay:(ZYVideoPlayView *)videoPlayView
{
    //you can paly video in this method
}

- (void)zy_videoPlayView:(ZYVideoPlayView *)videoPlayView didUpdateCurrentTime:(NSTimeInterval)currenttime
{
    //update video current time (slider..)
}

//other delegate methods...

@end
```

### Usage
#### 1. Manual 
1. `Add ZYVideoPlayView.h and ZYVideoPlayView.m to your project.`
2. `#import "ZYVideoPlayView.h" where you want to add`

#### 2. CocoaPods
Add this to your podfile and run pod install to install:

```
pod 'ZYVideoPlayView'
```

### Demo Preview
![](https://github.com/zhiyongzou/ZYVideoPlayView/blob/master/video_list.jpg)
