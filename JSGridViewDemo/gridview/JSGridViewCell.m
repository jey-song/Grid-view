//
//  JSGridViewCell.m
//  HHelloCat
//
//  Created by Song Jey on 4/28/12.
//  Copyright (c) 2012 Jey Song. All rights reserved.
//
//    http://www.apache.org/licenses/LICENSE-2.0


#import "JSGridView.h"
#import "JSGridViewCell.h"

@interface JSGridViewCell ()
- (JSGridView *)gridView;
@end

@implementation JSGridViewCell

@synthesize row, column, identifier, delegate, selected;
@synthesize highlighted;

@dynamic frame;

- (id)initWithReuseIdentifier:(NSString *)anIdentifier {
    
    if (![super initWithFrame:CGRectZero])
        return nil;
    
    identifier = [anIdentifier copy];
    
    return self;
}

- (void)dealloc {
    [identifier release];
    [super dealloc];
}

- (void)awakeFromNib {
    identifier = nil;
}

- (void)prepareForReuse {
    self.selected = NO;
    self.highlighted = NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.highlighted = YES;
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.highlighted = NO;
    [super touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.highlighted = NO;
    [self.delegate gridViewCellWasTouched:self];
    [super touchesEnded:touches withEvent:event];
}

#pragma mark -
#pragma mark Private Methods

- (JSGridView *)gridView {    
    UIResponder *r = [self nextResponder];
    if (![r isKindOfClass:[JSGridView class]]) return nil;
    return (JSGridView *)r;
}

@end