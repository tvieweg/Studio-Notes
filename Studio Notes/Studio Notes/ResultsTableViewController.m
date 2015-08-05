//
//  ResultsTableViewController.m
//  Studio Notes
//
//  Created by Trevor Vieweg on 8/3/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import "ResultsTableViewController.h"
#import "StudioNotesSongTableViewCell.h"
#import "DetailViewController.h"
#import <CoreData/CoreData.h>

@interface ResultsTableViewController ()

@end

@implementation ResultsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView registerClass:[StudioNotesSongTableViewCell class] forCellReuseIdentifier:@"SongCell"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredResults.count;
    }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"SongCell"];

    [self configureCell:cell atIndex:indexPath.row];
    return cell;

}

- (void)configureCell:(UITableViewCell *)cell atIndex:(NSInteger)index {
    NSManagedObject *object = [self.filteredResults objectAtIndex:index];
    cell.textLabel.text = [[object valueForKey:@"title"] description];
}

@end
