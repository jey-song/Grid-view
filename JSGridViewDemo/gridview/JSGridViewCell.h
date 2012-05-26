//
//  JSGridViewCell.h
//  HHelloCat
//
//  Created by Song Jey on 4/28/12.
//  Copyright (c) 2012 Jey Song. All rights reserved.
//

@class JSGridViewCell;

@protocol JSGridViewCellDelegate
-(void)gridViewCellWasTouched:(JSGridViewCell *)gridViewCell;
@end

@interface JSGridViewCell : UIView {

    NSInteger xPosition, yPosition;
    NSString *identifier;
    
    BOOL selected;
    BOOL highlighted;
    
    id<JSGridViewCellDelegate> delegate;

}
@property (nonatomic, assign) id delegate;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL highlighted;

@property (nonatomic, assign) NSInteger xPosition, yPosition;
@property (nonatomic, assign) CGRect frame;

- (id)initWithReuseIdentifier:(NSString *)identifier;

@end


