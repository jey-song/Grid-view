//
//  JSGridView.m
//  HHelloCat
//
//  Created by Song Jey on 4/28/12.
//  Copyright (c) 2012 Jey Song. All rights reserved.
//
//    http://www.apache.org/licenses/LICENSE-2.0

#import "JSGridView.h"


typedef enum _JSCellsReuseInfoKey {
    JSCellsReuseInfoKeyIndexPath = 0,
//    JSCellsReuseInfoKeyOriginY,
    JSCellsReuseInfoKeyFrame,
} JSCellsReuseInfoKey;

@interface JSGridView () {
    NSMutableDictionary *_reusableGridCells;
    NSMutableDictionary *_usedGridCells;
    NSMutableArray *_sortedUsedCellKeys;
    NSArray *_reuseCellsInfoOrderAsc; // i,j | originY | frame
    NSArray *_reuseCellsInfoOrderDesc; // i,j | originY | frame
    NSComparator _bottomSorter;
    NSComparator _originSorter;
    NSComparator _leftSorter;
    NSComparator _rightSorter;
}
@end

@implementation JSGridView
@synthesize dataSource=_dataSource;
@synthesize delegate;

static CGPoint latestContentOffset = (CGPoint){0, 0};
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _reusableGridCells = [[NSMutableDictionary alloc] init];
        _usedGridCells = [[NSMutableDictionary alloc] init];
        _sortedUsedCellKeys = [[NSMutableArray alloc] init];
        _bottomSorter = ^NSComparisonResult(id obj1, id obj2) {
            CGRect rect1 = CGRectFromString([obj1 objectAtIndex:JSCellsReuseInfoKeyFrame]);
            CGRect rect2 = CGRectFromString([obj2 objectAtIndex:JSCellsReuseInfoKeyFrame]);
            return rect1.origin.y+rect1.size.height < rect2.origin.y+rect2.size.height;// sort: desc
        };
        _originSorter = ^NSComparisonResult(id obj1, id obj2) {
            return CGRectFromString([obj1 objectAtIndex:JSCellsReuseInfoKeyFrame]).origin.y > CGRectFromString([obj2 objectAtIndex:JSCellsReuseInfoKeyFrame]).origin.y; // sort: asc
        };
        _rightSorter = ^NSComparisonResult(id obj1, id obj2) {
            CGRect rect1 = CGRectFromString([obj1 objectAtIndex:JSCellsReuseInfoKeyFrame]);
            CGRect rect2 = CGRectFromString([obj2 objectAtIndex:JSCellsReuseInfoKeyFrame]);
            return rect1.origin.x+rect1.size.width < rect2.origin.x+rect2.size.width;// sort: desc
        };
        _leftSorter = ^NSComparisonResult(id obj1, id obj2) {
            return CGRectFromString([obj1 objectAtIndex:JSCellsReuseInfoKeyFrame]).origin.x > CGRectFromString([obj2 objectAtIndex:JSCellsReuseInfoKeyFrame]).origin.x; // sort: asc
        };
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _reusableGridCells = [[NSMutableDictionary alloc] init];
    _usedGridCells = [[NSMutableDictionary alloc] init];
    _sortedUsedCellKeys = [[NSMutableArray alloc] init];
    _bottomSorter = ^NSComparisonResult(id obj1, id obj2) {
        CGRect rect1 = CGRectFromString([obj1 objectAtIndex:JSCellsReuseInfoKeyFrame]);
        CGRect rect2 = CGRectFromString([obj2 objectAtIndex:JSCellsReuseInfoKeyFrame]);
        return rect1.origin.y+rect1.size.height < rect2.origin.y+rect2.size.height;// sort: desc
    };
    _originSorter = ^NSComparisonResult(id obj1, id obj2) {
        return CGRectFromString([obj1 objectAtIndex:JSCellsReuseInfoKeyFrame]).origin.y > CGRectFromString([obj2 objectAtIndex:JSCellsReuseInfoKeyFrame]).origin.y; // sort: asc
    };
    _rightSorter = ^NSComparisonResult(id obj1, id obj2) {
        CGRect rect1 = CGRectFromString([obj1 objectAtIndex:JSCellsReuseInfoKeyFrame]);
        CGRect rect2 = CGRectFromString([obj2 objectAtIndex:JSCellsReuseInfoKeyFrame]);
        return rect1.origin.x+rect1.size.width < rect2.origin.x+rect2.size.width;// sort: desc
    };
    _leftSorter = ^NSComparisonResult(id obj1, id obj2) {
        return CGRectFromString([obj1 objectAtIndex:JSCellsReuseInfoKeyFrame]).origin.x > CGRectFromString([obj2 objectAtIndex:JSCellsReuseInfoKeyFrame]).origin.x; // sort: asc
    };
}

- (void)dealloc {
    self.delegate = nil;
    self.dataSource = nil;
    _bottomSorter = nil;
    _originSorter = nil;
    _rightSorter = nil;
    _leftSorter = nil;
    [_reusableGridCells release];
    [_usedGridCells release];
    [_reuseCellsInfoOrderAsc release];
    [_reuseCellsInfoOrderDesc release];
    [_sortedUsedCellKeys release];
    [super dealloc];
}

#pragma mark - 
- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutReuseCells];
}

//- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//}

- (void)setContentOffset:(CGPoint)offset {
    latestContentOffset = self.contentOffset;
//    HHDPRINT(@"-------offset : %@", NSStringFromCGPoint(offset));
    [super setContentOffset:offset];
    if ([_dataSource constSizeForGeidView:self] == JSGridViewConstSizeWidth) {
        if ((offset.y >= self.contentSize.height-self.frame.size.height)
            && [self directionOfScroll] & JSGridViewScrollToBottom) {
            if (_gridViewFlags.delegateScrolledToEdge==1) {
                [delegate gridView:self scrolledToEdge:JSGridViewEdgeBottom];
            }
        } else if ((offset.y <= 0)
                   && [self directionOfScroll] & JSGridViewScrollToTop) {
            if (_gridViewFlags.delegateScrolledToEdge==1) {
                [delegate gridView:self scrolledToEdge:JSGridViewEdgeTop];
            }
        }
    } else if ([_dataSource constSizeForGeidView:self] == JSGridViewConstSizeHeight) {
        if ((offset.x >= self.contentSize.width-self.frame.size.width)
            && [self directionOfScroll] & JSGridViewScrollToRight) {
            if (_gridViewFlags.delegateScrolledToEdge==1) {
                [delegate gridView:self scrolledToEdge:JSGridViewEdgeRight];
            }
        } else if ((offset.x <= 0)
                   && [self directionOfScroll] & JSGridViewScrollToTop) {
            if (_gridViewFlags.delegateScrolledToEdge==1) {
                [delegate gridView:self scrolledToEdge:JSTGridViewEdgeLeft];
            }
        }
    }
}

#pragma mark - Helper && Public methods
- (void)resetUsingCells {
    NSArray *arry = [_usedGridCells allValues];
    for (int i=0; i<[arry count]; i++) {
        JSGridViewCell *cell = (JSGridViewCell *)[arry objectAtIndex:i];
        [self addReusingCell:cell];
    }
    [_usedGridCells removeAllObjects];
    [_sortedUsedCellKeys removeAllObjects];
}

- (void)addReusingCell:(JSGridViewCell *)cell {
    id cells = [_reusableGridCells objectForKey:cell.identifier];
    if (!cells) {
        cells = [NSMutableSet set];
        [_reusableGridCells setObject:cells forKey:cell.identifier];
    }
    [cell removeFromSuperview];
    [cells addObject:cell];
}

- (JSGridViewScrollDirection)directionOfScroll {
    JSGridViewScrollDirection direction = 0;
    if (latestContentOffset.y > self.contentOffset.y) {
        direction |= JSGridViewScrollToTop;
    } else if (latestContentOffset.y < self.contentOffset.y) {
        direction |= JSGridViewScrollToBottom;
    }
    if (latestContentOffset.x > self.contentOffset.x) {
        direction |= JSGridViewScrollToLeft;
    } else if (latestContentOffset.x < self.contentOffset.x) {
        direction |= JSGridViewScrollToRight;
    }
//    HHDPRINT(@"direction : %d, latestContentOffset.y: %f, self.contentOffset.y: %f", direction, latestContentOffset.y, self.contentOffset.y);
    return direction;
}

- (NSArray *)sortedCellsDataByScrollDirection:(JSGridViewScrollDirection)direction {
    if (direction & JSGridViewScrollToBottom || direction & JSGridViewScrollToRight) {
        return _reuseCellsInfoOrderAsc;
    } else {
        return _reuseCellsInfoOrderDesc;
    }
}

- (NSComparator)sorterByScrollDirection:(JSGridViewScrollDirection)direction {
    if (direction & JSGridViewScrollToBottom) {
        return _originSorter;
    } else if (direction & JSGridViewScrollToTop) {
        return _bottomSorter;
    } else if (direction & JSGridViewScrollToRight) {
        return _leftSorter;
    } else {
        return _rightSorter;
    }
}

- (void)layoutReuseCells {
    @autoreleasepool {
        JSGridViewScrollDirection direction;
        if (!(self.tracking || self.dragging || self.decelerating)) {
            if ([_usedGridCells count]>0) {
                return;
            }
            [_sortedUsedCellKeys removeAllObjects];
            direction = JSGridViewScrollToBottom;
        } else {
            direction = [self directionOfScroll];
        }
        NSArray *data = [self sortedCellsDataByScrollDirection:direction];
        while ([_sortedUsedCellKeys count]>0) {
            [_sortedUsedCellKeys sortUsingComparator:[self sorterByScrollDirection:direction]];
            id oneObject = [_sortedUsedCellKeys objectAtIndex:0];
            CGRect rect = CGRectFromString([oneObject objectAtIndex:JSCellsReuseInfoKeyFrame]);
            // 1. remove unshow cell
            NSString *indexPathKey = [oneObject objectAtIndex:JSCellsReuseInfoKeyIndexPath];
            BOOL value = NO;
            if (_constSizeValue == JSGridViewConstSizeWidth) {
                if (direction & JSGridViewScrollToBottom) {
                    value = (rect.origin.y+rect.size.height < self.contentOffset.y);
                } else {
                    value = (rect.origin.y > self.contentOffset.y+self.frame.size.height);
                }
            } else {
                if (direction & JSGridViewScrollToRight) {
                    value = (rect.origin.x+rect.size.width < self.contentOffset.x);
                } else {
                    value = (rect.origin.x > self.contentOffset.x+self.frame.size.width);
                } 
            }
            if (value) {
                JSGridViewCell *cell = (JSGridViewCell *)[_usedGridCells objectForKey:indexPathKey];
                [self addReusingCell:cell];
                [_usedGridCells removeObjectForKey:indexPathKey];
                [_sortedUsedCellKeys removeObject:oneObject];
            } else {
                break;
            }
        }
        int bI = 0;
        if ([_sortedUsedCellKeys count]>0) {
            int index = [data indexOfObject:[_sortedUsedCellKeys lastObject]];
            if (index != NSNotFound) {
                bI = index;
//                HHDPRINT(@"last show object index: %d", index);
            }
        }
        for (int i=bI; i<[data count]; i++) {
            id oneObject = [data objectAtIndex:i];
            CGRect rect = CGRectFromString([oneObject objectAtIndex:JSCellsReuseInfoKeyFrame]);
            BOOL value = NO;
            if (_constSizeValue == JSGridViewConstSizeWidth) {
                if (direction & JSGridViewScrollToTop) {
                    value = (rect.origin.y > self.contentOffset.y+self.frame.size.height);
                } else {
                    value = (rect.origin.y+rect.size.height < self.contentOffset.y);                        
                }
            } else {
                if (direction & JSGridViewScrollToLeft) {
                    value = (rect.origin.x > self.contentOffset.x+self.frame.size.width);
                } else {
                    value = (rect.origin.x+rect.size.width < self.contentOffset.x);                        
                } 
            }
            if (value) {
                continue;
            }
            if (_constSizeValue == JSGridViewConstSizeWidth) {
                if (direction & JSGridViewScrollToTop) {
                    value = rect.origin.y+rect.size.height < self.contentOffset.y;
                } else {
                    value = rect.origin.y > self.contentOffset.y+self.frame.size.height;                        
                }
            } else {
                if (direction & JSGridViewScrollToLeft) {
                    value = rect.origin.x+rect.size.width < self.contentOffset.x;
                } else {
                    value = rect.origin.x > self.contentOffset.x+self.frame.size.width;                        
                } 
            }
            if (value) {
                break;
            }
            NSString *indexPathKey = [oneObject objectAtIndex:JSCellsReuseInfoKeyIndexPath];
            NSArray *indexPath = [indexPathKey componentsSeparatedByString:@","];// column, index
            if ([_usedGridCells objectForKey:indexPathKey]) {
                JSGridViewCell *cell = (JSGridViewCell *)[_usedGridCells objectForKey:indexPathKey];
                [self addReusingCell:cell];
                [_usedGridCells removeObjectForKey:indexPathKey];
                [_sortedUsedCellKeys removeObject:oneObject];
            }
            JSGridViewCell *cell = [_dataSource gridView:self
                                              viewForRow:[[indexPath objectAtIndex:1] intValue] 
                                                  column:[[indexPath objectAtIndex:0] intValue]];
            [self addSubview:cell];
            NSMutableSet *reuseSet = (NSMutableSet *)[_reusableGridCells objectForKey:cell.identifier];
            if ([reuseSet containsObject:cell]) {
                [reuseSet removeObject:cell];
            }
            cell.frame = CGRectFromString([oneObject objectAtIndex:JSCellsReuseInfoKeyFrame]);
            [_usedGridCells setObject:cell forKey:indexPathKey];
            if (![_sortedUsedCellKeys containsObject:oneObject])
                [_sortedUsedCellKeys addObject:oneObject];
        }
//        HHDINFO(@"%@, %@", [self subviews], @"");
    }
}

- (CGSize)contentSizeForView {
    _constSizeValue = [_dataSource constSizeForGeidView:self];
    float width = 0.0;
    float height = 0.0;
    if (_constSizeValue == JSGridViewConstSizeWidth) {
        int maxRowCount = 1;
        if (NO) {// TODO: check data source flag
            [NSException exceptionWithName:NSGenericException reason:@"JSGroidView datasource must implement more methods...." userInfo:nil];
        }
        int columnsCount = [_dataSource numberOfConstColumnsInGridView:self];
        NSMutableArray *cellsOrigin = [NSMutableArray array];
        float heights[columnsCount];
        for (int i=0; i<columnsCount; i++) {
            CGFloat widthI = [_dataSource gridView:self widthForCellAtColumnIndex:i];
            int rowsAtColumnIndex = [_dataSource numberOfRowsInGridView:self forConstColumnWithIndex:i];
            heights[i] = 0.0;
            maxRowCount = MAX(maxRowCount, rowsAtColumnIndex);
            for (int j=0; j<rowsAtColumnIndex; j++) {
                CGFloat heightJ = [_dataSource gridView:self heightForCellAtRow:j column:i];
                [cellsOrigin addObject:[NSMutableArray arrayWithObjects:
                                        [NSString stringWithFormat:@"%d,%d", i, j],
                                        NSStringFromCGRect((CGRect){width, heights[i], widthI, heightJ}), nil]];                
                heights[i] += heightJ;
            }
            width += widthI;
            height = MAX(heights[i], height);
        }
        if (_reuseCellsInfoOrderAsc) {
            [_reuseCellsInfoOrderAsc release];
        }
        _reuseCellsInfoOrderAsc = [[cellsOrigin sortedArrayUsingComparator:_originSorter] retain];
        if (_reuseCellsInfoOrderDesc) {
            [_reuseCellsInfoOrderDesc release];
        }
        _reuseCellsInfoOrderDesc = [[cellsOrigin sortedArrayUsingComparator:_bottomSorter] retain];
        height = MAX(self.bounds.size.height+1, height);
    } else {
        int maxRowCount = 1;
        int rowsCount = [_dataSource numberOfConstRowsInGridView:self];
        NSMutableArray *cellsOrigin = [NSMutableArray array];
        float widths[rowsCount];
        for (int i=0; i<rowsCount; i++) {
            CGFloat heightI = [_dataSource gridView:self heightForCellAtRow:i];
            int columnsAtRowIndex = [_dataSource numberOfColumnsInGridView:self forConstRowWithIndex:i];
            widths[i] = 0.0;
            maxRowCount = MAX(maxRowCount, columnsAtRowIndex);
            for (int j=0; j<columnsAtRowIndex; j++) {
                CGFloat widthJ = [_dataSource gridView:self widthForCellAtColumn:j row:i];
                [cellsOrigin addObject:[NSMutableArray arrayWithObjects:
                                        [NSString stringWithFormat:@"%d,%d", j, i],
                                        NSStringFromCGRect((CGRect){widths[i], height, widthJ, heightI}), nil]];                
                widths[i] += widthJ;
            }
            height += heightI;
            width = MAX(widths[i], width);
        }
        if (_reuseCellsInfoOrderAsc) {
            [_reuseCellsInfoOrderAsc release];
        }
        _reuseCellsInfoOrderAsc = [[cellsOrigin sortedArrayUsingComparator:_leftSorter] retain];
        if (_reuseCellsInfoOrderDesc) {
            [_reuseCellsInfoOrderDesc release];
        }
        _reuseCellsInfoOrderDesc = [[cellsOrigin sortedArrayUsingComparator:_rightSorter] retain];
        width = MAX(self.bounds.size.width+1, width);
    }
    return (CGSize){width, height};
}

- (void)prepareLoadView {
    self.contentSize = [self contentSizeForView];
}

- (void)setDelegate:(id<JSGridViewDelegate>)obj {
    if ( (obj!=nil) && ([obj conformsToProtocol:@protocol(JSGridViewDelegate)]==NO ))
        [NSException raise: NSInvalidArgumentException format: @"Argument to -setDelegate must conform to the JSGridViewDelegate protocol"];
    delegate = obj;
    super.delegate = obj;
    _gridViewFlags.dalegateHeightAtRowAndColumnIndex = (obj && [obj respondsToSelector:@selector(gridView:heightForCellAtRow:column:)]);
    _gridViewFlags.delegateWillDisplayCellAtRowIndexColumnIndex = (obj && [obj respondsToSelector:@selector(gridView:willDisplayCell:atRowIndex:columnIndex:)]);
//    _gridViewFlags.delegateDidSelectRowIndexAndColumnIndex = (obj && [obj respondsToSelector:@selector(gridView:didSelectRowIndex:columnIndex:)]);
    _gridViewFlags.delegateScrolledToEdge = (obj && [obj respondsToSelector:@selector(gridView:scrolledToEdge:)]);
    _gridViewFlags.delegateFooterOnTableView = (obj && [obj respondsToSelector:@selector(footerOnTableView:)]);
    _gridViewFlags.delegateHeightForFooterOnTableView = (obj && [obj respondsToSelector:@selector(heightForFooterOnTableView:)]);
    _gridViewFlags.delegateWidthForFooterOnTableView = (obj && [obj respondsToSelector:@selector(widthForFooterOnTableView:)]);
}

- (void)setDataSource:(id<JSGridViewDataSource>)obj {
    if ((obj != nil) && ([obj conformsToProtocol:@protocol(JSGridViewDataSource)] == NO ))
        [NSException raise: NSInvalidArgumentException format: @"Argument to -setDataSource must conform to the JSGridViewDataSource protocol"];
    _dataSource = obj;
    _gridViewFlags.dataSourceWidthForCellAtColumnIndex = (obj && [obj respondsToSelector:@selector(gridView:widthForCellAtColumnIndex:)]);
    _gridViewFlags.dataSourceHeightForCellAtRowAndColumn = (obj && [obj respondsToSelector:@selector(gridView:heightForCellAtRow:column:)]);
    _gridViewFlags.dataSourceNumberOfConstColumnsInGridView = (obj && [obj respondsToSelector:@selector(numberOfConstColumnsInGridView:)]);
    _gridViewFlags.dataSourceNumberOfRowsInGridViewForConstColumnWithIndex = (obj && [obj respondsToSelector:@selector(numberOfRowsInGridView:forConstColumnWithIndex:)]);
    
    _gridViewFlags.dataSourceHeightForCellAtRow = (obj && [obj respondsToSelector:@selector(gridView:heightForCellAtRow:)]);
    _gridViewFlags.dataSourceWidthForCellAtRowAndColumn = (obj && [obj respondsToSelector:@selector(gridView:widthForCellAtRow:column:)]);
    _gridViewFlags.dataSourceNumberOfConstRowsInGridView = (obj && [obj respondsToSelector:@selector(numberOfConstRowsInGridView:)]);
    _gridViewFlags.dataSourceNumberOfColumnsInGridViewForConstRowWithIndex = (obj && [obj respondsToSelector:@selector(numberOfColumnsInGridView:forConstRowWithIndex:)]);
}

- (JSGridViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    id cells = [_reusableGridCells objectForKey:identifier];
    if (!cells) {
        cells = [NSMutableSet set];
        [_reusableGridCells setObject:cells forKey:identifier];
    }
    return [(NSMutableSet *)cells anyObject];
}

- (JSGridViewCell *)cellForRow:(NSInteger)rowIndex column:(NSInteger)columnIndex {
    return nil;
}

- (void)reloadData {
    [self resetUsingCells];
    [self prepareLoadView];
//    [self setNeedsDisplay];
}

@end


//#pragma mark - JSGridViewCell
//struct JSPosition {
//    CGPoint topLeft;
//    CGPoint topRight;
//    CGPoint bottomLeft;
//    CGPoint bottomRight;
//};
//typedef struct JSPosition JSPosition;
//
//struct JSIndexPath {
//    unsigned int row;
//    unsigned int column;
//};
//typedef struct JSIndexPath JSIndexPath;
//
//@interface JSGridViewCell (Position) 
//@property (nonatomic, assign) JSPosition _position;
//@property (nonatomic, assign) JSIndexPath _indexPath;
//@end
//
//@implementation JSGridViewCell (Position)
//@dynamic _position;
//@dynamic _indexPath;
//@end
