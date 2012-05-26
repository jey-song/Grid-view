//
//  HHMasterViewController.m
//  JSGridViewDemo
//
//  Created by Jey on 12-5-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HHMasterViewController.h"

#import "HHDetailViewController.h"
#import "HHDetailView1Controller.h"

@interface HHMasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation HHMasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Master", @"Master");
    }
    return self;
}
							
- (void)dealloc
{
    [_objects release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:@"向下滑" atIndex:0];
    [_objects insertObject:@"向右滑" atIndex:1];
}

#pragma mark - Table View
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    NSDate *object = [_objects objectAtIndex:indexPath.row];
    cell.textLabel.text = [object description];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row%2==0) {
        HHDetailViewController *detailViewController = [[[HHDetailViewController alloc] initWithNibName:@"HHDetailViewController" bundle:nil] autorelease];
        [self.navigationController pushViewController:detailViewController animated:YES];
    } else {
        HHDetailView1Controller *detailView = [[[HHDetailView1Controller alloc] initWithNibName:@"HHDetailView1Controller" bundle:nil] autorelease];
        [self.navigationController pushViewController:detailView animated:YES];
    }
}

@end
