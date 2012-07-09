//
//  ViewController.h
//  DDSimpleRSS
//
//  Created by Dody Wicaksono on 09/07/2012.
//  Copyright (c) 2012 dodyrw.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullToRefreshTableViewController.h"
#import "MWFeedParser.h"
#import "LoadingView.h"
#import "HJObjManager.h"

@interface ViewController : PullToRefreshTableViewController <MWFeedParserDelegate> {
	// Parsing
	MWFeedParser *feedParser;
	NSMutableArray *parsedItems;
	
	// Displaying
	NSArray *itemsToDisplay;
	NSDateFormatter *formatter;    

    LoadingView *loadingView;
    
    HJObjManager* objMan;
}

@property (nonatomic, retain) NSArray *itemsToDisplay;
@property (nonatomic, retain) LoadingView *loadingView;

@end
