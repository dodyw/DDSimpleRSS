//
//  PullToRefreshTableViewController.h
//  TableViewPull
//
//  Created by Dody Wicaksono on 09/07/2012.
//  Copyright (c) 2012 dodyrw.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface PullToRefreshTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{
	EGORefreshTableHeaderView *refreshHeaderView;

	BOOL _reloading;
}

@property(assign,getter=isReloading) BOOL reloading;
@property(nonatomic,readonly) EGORefreshTableHeaderView *refreshHeaderView;
@property(nonatomic, retain) UITableView* tableView;

- (void)reloadTableViewDataSource;
- (void)dataSourceDidFinishLoadingNewData;


@end
