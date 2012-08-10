//
//  HHDetailViewController.m
//  JSGridViewDemo
//
//  Created by Jey on 12-5-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HHDetailViewController.h"

#define  kOneCellImageWidth 100//图片宽度
#define  kOnceLoadingCount 40

@interface HHDetailViewController () <JSGridViewDataSource, JSGridViewDelegate> {
    NSArray *_images;
}
@end

@implementation HHDetailViewController
//@synthesize detailItem = _detailItem;
@synthesize gridView = _gridView;

- (void)dealloc
{
//    [_detailItem release];
    _gridView.dataSource = nil;
    _gridView.delegate = nil;
    [_gridView release];
    [_leftArray release];
    [_middleArray release];
    [_rightArray release];
    [_images release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"shu xiang", @"Detail");
    }
    return self;
}

#pragma mark - 
- (void)viewDidLoad {
    [super viewDidLoad];
    _leftArray = [[NSMutableArray alloc] init];
    _middleArray = [[NSMutableArray alloc] init];
    _rightArray = [[NSMutableArray alloc] init];
    _loadCount = 0;
    _isLoading = NO;
    _images = [[NSArray alloc] initWithObjects:
               [UIImage imageNamed:@"0.jpeg"],
               [UIImage imageNamed:@"1.jpeg"], 
               [UIImage imageNamed:@"2.jpeg"], 
               [UIImage imageNamed:@"3.jpeg"], 
               [UIImage imageNamed:@"4.jpeg"], 
               [UIImage imageNamed:@"5.jpeg"], 
               [UIImage imageNamed:@"6.jpeg"], 
               [UIImage imageNamed:@"7.jpeg"], 
               [UIImage imageNamed:@"8.jpeg"], 
               [UIImage imageNamed:@"9.jpeg"], 
               [UIImage imageNamed:@"10.jpeg"], nil];
    [self addTableViewData];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    _leftArray = nil;
    _middleArray = nil;
    _rightArray = nil;
    _images = nil;
}

#pragma mark - Helper
- (NSArray *)arrayValueByTableKey:(NSInteger)columnIndex {
    NSArray *array = [NSArray array];
    if (columnIndex==0) {
        array = _leftArray;
    } else if (columnIndex==1) {
        array = _middleArray;
    } else if (columnIndex==2) {
        array = _rightArray;
    }
    return array;
}

- (void)addTableViewData {
    _loadCount += kOnceLoadingCount;
    for (int i=0; i<_loadCount; i++) {
        float height = (float)(arc4random()%150);
        if (height<50) height += 50;
        double mininum = MIN(_lefeHeight, MIN(_middleHeight, _rightHeight));
        // data info
        NSDictionary *info = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%f", height]
                                                         forKey:@"usingHeight"];
        if (_lefeHeight == mininum) {
            _lefeHeight += height;
            [_leftArray addObject:info];
        } else if (_middleHeight == mininum) {
            _middleHeight += height;
            [_middleArray addObject:info];
        } else if (_rightHeight == mininum) {
            _rightHeight += height;
            [_rightArray addObject:info];
        } 
    }
    [_gridView reloadData];
}

#pragma mark - JSGridView
- (JSGridViewConstSize)constSizeForGeidView:(JSGridView *)gridView {
    return JSGridViewConstSizeWidth;
}

- (CGFloat)gridView:(JSGridView *)gridView heightForCellAtRow:(NSInteger)row column:(NSInteger)column {
    id obj = [[self arrayValueByTableKey:column] objectAtIndex:row];
    return [[obj objectForKey:@"usingHeight"] intValue]+5;
}

- (CGFloat)gridView:(JSGridView *)gridView widthForCellAtColumnIndex:(NSInteger)column {
    return kOneCellImageWidth+5;
}

- (NSInteger)numberOfRowsInGridView:(JSGridView *)gridView forConstColumnWithIndex:(NSInteger)column {
    return [[self arrayValueByTableKey:column] count];
}

- (NSInteger)numberOfConstColumnsInGridView:(JSGridView *)gridView {
    return 3;
}

- (void)gridView:(JSGridView *)gridView scrolledToEdge:(JSGridViewEdge)edge {
    if (edge == JSGridViewEdgeBottom) {
//        _isLoading = YES;
        [self addTableViewData];
    }
}

- (JSGridViewCell *)gridView:(JSGridView *)gridView viewForRow:(NSInteger)row column:(NSInteger)column {
    NSArray *array = [self arrayValueByTableKey:column];
    NSString *identifier = @"testCell";
    JSGridViewCell *cell = [gridView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[JSGridViewCell alloc] initWithReuseIdentifier:identifier] autorelease];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.tag = 50;
//        [imageView setDelegate:self];
//        imageView.backgroundColor = HHColor(110.0, 110.0, 110.0, 0.4);
        [cell addSubview:imageView];
        [imageView release];
        cell.delegate = self;
    }
    cell.row = row;
    cell.column = column;
    NSDictionary *oneDic = [array objectAtIndex:row];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:50];
    float height = [[oneDic objectForKey:@"usingHeight"] floatValue];
    imageView.frame = CGRectMake(5, 5, kOneCellImageWidth, height);
    int i = (row*column+row+column)%[_images count];
    imageView.image = [_images objectAtIndex:i];
    return cell;
}

- (void)gridViewCellWasTouched:(JSGridViewCell *)gridViewCell {
    NSLog(@"row : %d, column : %d", gridViewCell.row, gridViewCell.column);
}
@end
