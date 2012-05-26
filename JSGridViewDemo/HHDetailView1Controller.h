//
//  HHDetailView1Controller.h
//  JSGridViewDemo
//
//  Created by Jey on 12-5-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JSGridView.h"

@interface HHDetailView1Controller : UIViewController {
  @private
    JSGridView *_gridView;
    
    NSInteger _topWidth;
    NSInteger _middleWidth;
    NSInteger _bottomWidth;
    
    NSMutableArray *_leftArray;
    NSMutableArray *_middleArray;
    NSMutableArray *_rightArray;
    NSInteger _loadCount;
    BOOL _isLoading;
}

@property (retain, nonatomic) IBOutlet JSGridView *gridView;


@end