//
//  TableViewController.m
//  Colors
//
//  Created by Ignacio Romero Z. on 6/29/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//

#import "TableViewController.h"
#import "SearchViewController.h"
#import "Palette.h"

#import "UIScrollView+EmptyDataSet.h"

@interface TableViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@end

@implementation TableViewController

#pragma mark - View lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.title = @"Table";
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:self.title image:[UIImage imageNamed:@"tab_table"] tag:self.title.hash];
}

- (void)loadView
{
    [super loadView];
    
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView = [UIView new];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}


#pragma mark - Actions

- (IBAction)refreshColors:(id)sender
{
    [[Palette sharedPalette] reloadAll];
    
    [self.tableView reloadData];
}

- (IBAction)removeColors:(id)sender
{
    [[Palette sharedPalette] removeAll];
    
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"table_push_detail"]) {
        SearchViewController *controller = [segue destinationViewController];
        controller.selectedColor = sender;
	}
}


#pragma mark - DZNEmptyDataSetSource Methods

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"No colors loaded";
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0],
                                 NSForegroundColorAttributeName: [UIColor colorWithRed:170/255.0 green:171/255.0 blue:179/255.0 alpha:1.0],
                                 NSParagraphStyleAttributeName: paragraphStyle};
    
    return [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"To show a list of random colors, tap on the refresh icon in the right top corner.\n\nTo clean the list, tap on the trash icon.";
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:15.0],
                                 NSForegroundColorAttributeName: [UIColor colorWithRed:170/255.0 green:171/255.0 blue:179/255.0 alpha:1.0],
                                 NSParagraphStyleAttributeName: paragraphStyle};
    
    return [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state
{
    NSString *text = @"Refresh Colors";
    UIColor *color = nil;
    
    if (state == UIControlStateNormal) color = [UIColor colorWithRed:44/255.0 green:137/255.0 blue:202/255.0 alpha:1.0];
    if (state == UIControlStateHighlighted) color = [UIColor colorWithRed:106/255.0 green:187/255.0 blue:227/255.0 alpha:1.0];
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:14.0],
                                 NSForegroundColorAttributeName: color,
                                 NSParagraphStyleAttributeName: paragraphStyle};
    
    return [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"empty_placeholder"];
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIColor whiteColor];
}

- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView
{
    return nil;
}

- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView
{
    return 0;
}


#pragma mark - DZNEmptyDataSetSource Methods

- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView
{
    return YES;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return NO;
}

- (void)emptyDataSetDidTapView:(UIScrollView *)scrollView
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)emptyDataSetDidTapButton:(UIScrollView *)scrollView
{
    NSLog(@"%s",__FUNCTION__);
	
	[self refreshColors:nil];
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	
	NSInteger rowCount = [[Palette sharedPalette] colors].count;
	
	if (rowCount < 1) {
		if (self.searchDisplayController.searchBar.superview) {
			[self.searchDisplayController.searchBar removeFromSuperview];
		}
	}
	
	else {
		if (!self.searchDisplayController.searchBar.superview) {
			[self.tableView addSubview:self.searchDisplayController.searchBar];
		}
	}
	
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.selectedBackgroundView = [UIView new];
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        cell.textLabel.textColor = [UIColor colorWithWhite:0.125 alpha:1.0];
        cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    }
    
    Color *color = [[Palette sharedPalette] colors][indexPath.row];
    
    cell.textLabel.text = color.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"#%@", color.hex];
	
    cell.imageView.image = [Color roundThumbWithColor:color.color];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56.0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Color *color = [[Palette sharedPalette] colors][indexPath.row];
        [[Palette sharedPalette] removeColor:color];
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
	}
}


#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Color *color = [[Palette sharedPalette] colors][indexPath.row];
    
    if ([self shouldPerformSegueWithIdentifier:@"table_push_detail" sender:color]) {
        [self performSegueWithIdentifier:@"table_push_detail" sender:color];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if ([NSStringFromSelector(action) isEqualToString:@"copy:"]) {
        return YES;
    }
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        if ([NSStringFromSelector(action) isEqualToString:@"copy:"]) {
            Color *color = [[Palette sharedPalette] colors][indexPath.row];
            if (color.hex.length > 0) [[UIPasteboard generalPasteboard] setString:color.hex];
        }
    });
}

@end
