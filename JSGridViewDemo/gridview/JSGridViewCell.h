//
//  JSGridViewCell.h
//  HHelloCat
//
//  Created by Song Jey on 4/28/12.
//  Copyright (c) 2012 Jey Song. All rights reserved.
//
//    http://www.apache.org/licenses/LICENSE-2.0

@class JSGridViewCell;

@protocol JSGridViewCellDelegate
- (void)gridViewCellWasTouched:(JSGridViewCell *)gridViewCell;
@end

@interface JSGridViewCell : UIView {

    NSInteger row, column;
    NSString *identifier;
    
    BOOL selected;
    BOOL highlighted;
    
    id<JSGridViewCellDelegate> delegate;

}
@property (nonatomic, assign) id delegate;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, assign) BOOL selected; // no using
@property (nonatomic, assign) BOOL highlighted;

@property (nonatomic, assign) NSInteger row, column;
@property (nonatomic, assign) CGRect frame;

- (id)initWithReuseIdentifier:(NSString *)identifier;

@end


