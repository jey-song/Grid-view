//
//  HHDetailView1Controller.m
//  JSGridViewDemo
//
//  Created by Jey on 12-5-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HHDetailView1Controller.h"

#define  kOneCellImageHeight 132//图片高度
#define  kOnceLoadingCount 40

@interface HHDetailView1Controller () <JSGridViewDataSource, JSGridViewDelegate> {
    NSArray *_images;
}
@end


@implementation HHDetailView1Controller
@synthesize gridView = _gridView;

- (void)dealloc {
    _gridView.dataSource = nil;
    _gridView.delegate = nil;
    [_gridView release];
    [_leftArray release];
    [_middleArray release];
    [_rightArray release];
    [_images release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"heng xiang", @"Detail");
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
    _topWidth = 0;
    _middleWidth = 0;
    _bottomWidth = 0;
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
- (NSArray *)arrayValueByTableKey:(NSInteger)index {
    NSArray *array = [NSArray array];
    if (index==0) {
        array = _leftArray;
    } else if (index==1) {
        array = _middleArray;
    } else if (index==2) {
        array = _rightArray;
    }
    return array;
}

- (void)addTableViewData {
    _loadCount += kOnceLoadingCount;
    for (int i=0; i<_loadCount; i++) {
        float width = (float)(arc4random()%200);
        if (width<70) width += 70;
        double mininum = MIN(_topWidth, MIN(_middleWidth, _bottomWidth));
        // data info
        NSDictionary *info = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%f", width]
                                                         forKey:@"usingWidth"];
        if (_topWidth == mininum) {
            _topWidth += width;
            [_leftArray addObject:info];
        } else if (_middleWidth == mininum) {
            _middleWidth += width;
            [_middleArray addObject:info];
        } else if (_bottomWidth == mininum) {
            _bottomWidth += width;
            [_rightArray addObject:info];
        } 
    }
    [_gridView reloadData];
}

#pragma mark - JSGridView
- (JSGridViewConstSize)constSizeForGeidView:(JSGridView *)gridView {
    return JSGridViewConstSizeHeight;
}

- (CGFloat)gridView:(JSGridView *)gridView widthForCellAtColumn:(NSInteger)column row:(NSInteger)row {
    id obj = [[self arrayValueByTableKey:row] objectAtIndex:column];
    return [[obj objectForKey:@"usingWidth"] intValue]+5;
}

- (CGFloat)gridView:(JSGridView *)gridView heightForCellAtRow:(NSInteger)row {
    return kOneCellImageHeight+5;
}

- (NSInteger)numberOfColumnsInGridView:(JSGridView *)gridView forConstRowWithIndex:(NSInteger)row {
    return [[self arrayValueByTableKey:row] count];
}

- (NSInteger)numberOfConstRowsInGridView:(JSGridView *)gridView {
    return 3;
}

- (void)gridView:(JSGridView *)gridView scrolledToEdge:(JSGridViewEdge)edge {
    if (edge == JSGridViewEdgeRight) {
//        _isLoading = YES;
        [self addTableViewData];
    }
}

- (JSGridViewCell *)gridView:(JSGridView *)gridView viewForRow:(NSInteger)row column:(NSInteger)column {
    NSArray *array = [self arrayValueByTableKey:row];
    NSString *identifier = @"testCell";
    JSGridViewCell *cell = [gridView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[JSGridViewCell alloc] initWithReuseIdentifier:identifier] autorelease];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.tag = 50;
        [cell addSubview:imageView];
        [imageView release];
        cell.delegate = self;
    }
    cell.row = row;
    cell.column = column;
    NSDictionary *oneDic = [array objectAtIndex:column];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:50];
    float width = [[oneDic objectForKey:@"usingWidth"] floatValue];
    imageView.frame = CGRectMake(5, 5, width, kOneCellImageHeight);
    int i = (row*column+row+column)%[_images count];
    imageView.image = [_images objectAtIndex:i];
    return cell;
}

- (void)gridViewCellWasTouched:(JSGridViewCell *)gridViewCell {
    NSLog(@"row : %d, column : %d", gridViewCell.row, gridViewCell.column);
}
@end
