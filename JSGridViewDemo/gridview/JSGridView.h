//
//  JSGridView.h
//  HHelloCat
//
//  Created by Song Jey on 4/28/12.
//  Copyright (c) 2012 Jey Song. All rights reserved.
//
//    http://www.apache.org/licenses/LICENSE-2.0

#import <UIKit/UIKit.h>


typedef enum _JSGridViewEdge {
    JSGridViewEdgeTop = 0,
    JSGridViewEdgeBottom,
    JSTGridViewEdgeLeft,
    JSGridViewEdgeRight
} JSGridViewEdge;

typedef enum _JSGridViewConstSize {
//    JSGridViewConstSizeNone = 0, // TODO:
    JSGridViewConstSizeWidth,
    JSGridViewConstSizeHeight,
} JSGridViewConstSize;

typedef enum _JSGridViewScrollDirection {
    JSGridViewScrollToTop =     1 << 0,
    JSGridViewScrollToBottom =  1 << 1,
    JSGridViewScrollToLeft =    1 << 2,
    JSGridViewScrollToRight =   1 << 3
} JSGridViewScrollDirection;

#import "JSGridViewCell.h"
@protocol JSGridViewDelegate;
@protocol JSGridViewDataSource;

// TODO: has not implement horizontal
@interface JSGridView : UIScrollView {
  @package
    struct {      
        unsigned int dataSourceWidthForCellAtColumnIndex:1;
        unsigned int dataSourceHeightForCellAtRowAndColumn:1;
        unsigned int dataSourceNumberOfConstColumnsInGridView:1;
        unsigned int dataSourceNumberOfRowsInGridViewForConstColumnWithIndex:1;
        
        unsigned int dataSourceHeightForCellAtRow:1;
        unsigned int dataSourceWidthForCellAtRowAndColumn:1;
        unsigned int dataSourceNumberOfConstRowsInGridView:1;
        unsigned int dataSourceNumberOfColumnsInGridViewForConstRowWithIndex:1;
        
        unsigned int dalegateHeightAtRowAndColumnIndex:1;
        unsigned int delegateWillDisplayCellAtRowIndexColumnIndex:1;
//        unsigned int delegateDidSelectRowIndexAndColumnIndex:1;
        unsigned int delegateScrolledToEdge:1;
        unsigned int delegateFooterOnTableView;
        unsigned int delegateHeightForFooterOnTableView;
        unsigned int delegateWidthForFooterOnTableView;
        
//        unsigned int scrollsToSelection:1;
        unsigned int lastHighlightedRowColumnActive:1;
        unsigned int countStringInsignificantColumnCount:1;
        unsigned int needsReload:1;
        unsigned int updatingVisibleCellsManually:1;
        unsigned int scheduledUpdateVisibleCells:1;
        unsigned int scheduledUpdateVisibleCellsFrames:1;
        unsigned int needToAdjustExtraSeparators:1;
        unsigned int ignoreDragSwipe:1;        
        unsigned int ignoreTouchSelect:1;
        
        unsigned int allowsSelection:1;
        unsigned int allowsMultipleSelection:1;
        unsigned int hideScrollIndicators:1;
        unsigned int sendReloadFinished:1;
    } _gridViewFlags;
    
  @private
    id _dataSource;
    JSGridViewConstSize _constSizeValue;
}

@property (nonatomic, assign) IBOutlet id<JSGridViewDataSource> dataSource;
@property (nonatomic, assign) IBOutlet id/*<JSGridViewDelegate>*/ delegate;

- (JSGridViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (JSGridViewCell *)cellForRow:(NSInteger)rowIndex column:(NSInteger)columnIndex;

- (void)reloadData;
@end



#pragma mark -
@protocol JSGridViewDelegate <UIScrollViewDelegate, NSObject>
@optional
- (UIView *)footerOnTableView:(JSGridView *)gridView; // bottom or right
- (CGFloat)heightForFooterOnTableView:(JSGridView *)gridView;
- (CGFloat)widthForFooterOnTableView:(JSGridView *)gridView;

- (CGFloat)gridView:(JSGridView *)gridView heightAtRow:(NSInteger)index columnIndex:(NSInteger)column;// height
- (void)gridView:(JSGridView *)gridView willDisplayCell:(JSGridViewCell *)cell atRowIndex:(NSInteger)row columnIndex:(NSInteger)column;

//- (void)gridViewDidLoad:(JSGridView *)gridView;
//- (void)gridView:(JSGridView *)gridView didSelectRowIndex:(NSInteger)row columnIndex:(NSInteger)column;
- (void)gridView:(JSGridView *)gridView scrolledToEdge:(JSGridViewEdge)edge;
//- (void)gridView:(JSGridView *)gridView didProgrammaticallyScrollToRow:(NSInteger)rowIndex column:(NSInteger)columnIndex;
@end

#pragma mark -
@protocol JSGridViewDataSource <NSObject>
- (JSGridViewCell *)gridView:(JSGridView *)gridView viewForRow:(NSInteger)row column:(NSInteger)column;
- (JSGridViewConstSize)constSizeForGeidView:(JSGridView *)gridView;

@optional
- (CGFloat)gridView:(JSGridView *)gridView widthForCellAtColumnIndex:(NSInteger)column;
- (NSInteger)numberOfConstColumnsInGridView:(JSGridView *)gridView;
- (CGFloat)gridView:(JSGridView *)gridView heightForCellAtRow:(NSInteger)row column:(NSInteger)column;
- (NSInteger)numberOfRowsInGridView:(JSGridView *)gridView forConstColumnWithIndex:(NSInteger)column;

- (CGFloat)gridView:(JSGridView *)gridView heightForCellAtRow:(NSInteger)row;
- (NSInteger)numberOfConstRowsInGridView:(JSGridView *)gridView;
- (CGFloat)gridView:(JSGridView *)gridView widthForCellAtColumn:(NSInteger)column row:(NSInteger)row;
- (NSInteger)numberOfColumnsInGridView:(JSGridView *)gridView forConstRowWithIndex:(NSInteger)row;
@end



