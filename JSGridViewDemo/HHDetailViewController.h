//
//  HHDetailViewController.h
//  JSGridViewDemo
//
//  Created by Jey on 12-5-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JSGridView.h"

@interface HHDetailViewController : UIViewController {
  @private
    JSGridView *_gridView;
    
    NSInteger _lefeHeight;
    NSInteger _middleHeight;
    NSInteger _rightHeight;
    
    NSMutableArray *_leftArray;
    NSMutableArray *_middleArray;
    NSMutableArray *_rightArray;
    NSInteger _loadCount;
    BOOL _isLoading;
}

//@property (strong, nonatomic) id detailItem;

@property (retain, nonatomic) IBOutlet JSGridView *gridView;


@end
