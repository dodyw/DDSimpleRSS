//
//  ViewController.m
//  DDSimpleRSS
//
//  Created by Dody Wicaksono on 09/07/2012.
//  Copyright (c) 2012 dodyrw.com. All rights reserved.
//

#import "ViewController.h"
#import "NSString+HTML.h"
#import "MWFeedParser.h"
#import "config.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize itemsToDisplay;
@synthesize loadingView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    // set tableview rect
    self.tableView.frame = CGRectMake(0, 45, 320, 300);
    
    // loading view
    loadingView = [LoadingView loadingViewInView:self.view];
    
    // Setup
	formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterShortStyle];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	parsedItems = [[NSMutableArray alloc] init];
	self.itemsToDisplay = [NSArray array];
    
    // Parse
	NSURL *feedURL = [NSURL URLWithString:RSSFEEDURL];
	feedParser = [[MWFeedParser alloc] initWithFeedURL:feedURL];
	feedParser.delegate = self;
	feedParser.feedParseType = ParseTypeFull; // Parse feed info and all items
	feedParser.connectionType = ConnectionTypeAsynchronously;
	[feedParser parse];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark -
#pragma mark Parsing

// Reset and reparse

//- (void) refreshFinish
//{
//    self.tableView.userInteractionEnabled = YES;
//    [self.tableView reloadData];    
//    
//    [super performSelector:@selector(dataSourceDidFinishLoadingNewData) withObject:nil afterDelay:2.0];
//}

- (void) refresh
{
    // do something here

	[parsedItems removeAllObjects];
	[feedParser stopParsing];
	[feedParser parse];
	self.tableView.userInteractionEnabled = NO;
}

- (void)updateTableWithParsedItems {
	self.itemsToDisplay = [parsedItems sortedArrayUsingDescriptors:
						   [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"date" 
																				 ascending:NO]]];
    
    [super performSelector:@selector(dataSourceDidFinishLoadingNewData) withObject:nil afterDelay:0.2];
    
	self.tableView.userInteractionEnabled = YES;
	self.tableView.alpha = 1;
	[self.tableView reloadData];
}

- (void)reloadTableViewDataSource
{
	//  should be calling your tableviews model to reload
	[super performSelector:@selector(refresh) withObject:nil afterDelay:0.2];
	
}

- (void)dataSourceDidFinishLoadingNewData
{
	[refreshHeaderView setCurrentDate];  //  should check if data reload was successful 
	
	[super dataSourceDidFinishLoadingNewData];
}

#pragma mark -
#pragma mark MWFeedParserDelegate

- (void)feedParserDidStart:(MWFeedParser *)parser {
	NSLog(@"Started Parsing: %@", parser.url);
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info {
	NSLog(@"Parsed Feed Info: “%@”", info.title);
	self.title = info.title;
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item {
	NSLog(@"Parsed Feed Item: “%@”", item.title);
	if (item) [parsedItems addObject:item];	
}

- (void)feedParserDidFinish:(MWFeedParser *)parser {
	NSLog(@"Finished Parsing%@", (parser.stopped ? @" (Stopped)" : @""));
    
    // stop loading view
    [loadingView removeFromSuperview];
    
    [self updateTableWithParsedItems];
}

- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error {
	NSLog(@"Finished Parsing With Error: %@", error);
    if (parsedItems.count == 0) {

    } else {
        // Failed but some items parsed, so show and inform of error
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Parsing Incomplete"
                                                         message:@"There was an error during the parsing of this feed. Not all of the feed items could parsed."
                                                        delegate:nil
                                               cancelButtonTitle:@"Dismiss"
                                               otherButtonTitles:nil];
        [alert show];
    }
    [self updateTableWithParsedItems];
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return itemsToDisplay.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
        
	// Configure the cell.
	MWFeedItem *item = [itemsToDisplay objectAtIndex:indexPath.row];
	if (item) {
        
		// Process
		NSString *itemTitle = item.title ? [item.title stringByConvertingHTMLToPlainText] : @"[No Title]";
		NSString *itemSummary = item.summary ? [item.summary stringByConvertingHTMLToPlainText] : @"[No Summary]";
        
		// Set
		cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
		cell.textLabel.text = itemTitle;
		NSMutableString *subtitle = [NSMutableString string];
		if (item.date) [subtitle appendFormat:@"%@: ", [formatter stringFromDate:item.date]];
		[subtitle appendString:itemSummary];
		cell.detailTextLabel.text = subtitle;
        
	}
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// Show detail
//	DetailTableViewController *detail = [[DetailTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
//	detail.item = (MWFeedItem *)[itemsToDisplay objectAtIndex:indexPath.row];
//	[self.navigationController pushViewController:detail animated:YES];
//	[detail release];
    
	// Deselect
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end
