//
//  VideoViewController.m
//  ZYVideoPlayViewDemo
//
//  Created by zzyong on 2017/8/21.
//  Copyright © 2017年 zzyong. All rights reserved.
//

#import "VideoModel.h"
#import "VideoViewCell.h"
#import "ZYVideoPlayView.h"
#import "VideoViewController.h"

@interface VideoViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, VideoViewCellDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<VideoModel *> *videoList;
@property (nonatomic, strong) NSIndexPath *currentPlayIndexP;

@end

@implementation VideoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubviews];
    [self loadVideoList];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.collectionView.frame = self.view.bounds;
}

#pragma mark - private

- (void)setupSubviews
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    [self.collectionView registerClass:[VideoViewCell class] forCellWithReuseIdentifier:@"VideoViewCell"];
    [self.view addSubview:self.collectionView];
}

- (void)loadVideoList
{
#ifdef DEBUG
    NSLog(@"loadVideoList - begin");
#endif
    
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"VideoList" ofType:@"plist"];
    if (dataPath.length) {
        NSMutableArray *tempArray = [NSMutableArray array];
        [[NSArray arrayWithContentsOfFile:dataPath] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            VideoModel *model = [VideoModel videoModelWithDictionary:obj];
            [tempArray addObject:model];
        }];
        self.videoList = tempArray;
        
#ifdef DEBUG
        NSLog(@"loadVideoList - end");
#endif
        
        [self.collectionView reloadData];
    } else {
        NSLog(@"video list load failed");
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.videoList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VideoViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VideoViewCell" forIndexPath:indexPath];
    [cell setupVideoInfo:[self.videoList objectAtIndex:indexPath.row] indexPath:indexPath];
    cell.delegate = self;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath == self.currentPlayIndexP) {
        [(VideoViewCell *)cell stopPlay];
        self.currentPlayIndexP = nil;
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.width * 9 / 16.0 + 40);
}

#pragma mark - VideoViewCellDelegate

- (void)videoDidPlayVideo:(VideoModel *)videoInfo indexPath:(NSIndexPath *)indexPath
{
    if (self.currentPlayIndexP == indexPath) {
        return;
    }
    
    VideoViewCell *last = (VideoViewCell *)[self.collectionView cellForItemAtIndexPath:self.currentPlayIndexP];
    [last stopPlay];
    
    self.currentPlayIndexP = indexPath;
    
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
}

@end
