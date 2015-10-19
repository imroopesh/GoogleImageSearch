//
//  MainViewController.m
//  GoogleImageSearch
//
//  Created by Roopesh Manjunatha on 7/17/14.
//  Copyright (c) 2014 ROOPESH. All rights reserved.
//

#import "MainViewController.h"
#include "SearchResultsViewController.h"

#import "UIImageView+AFNetworking.h"
#import "MBProgressHUD.h"

#import "Image.h"
#import "ImageCell.h"
#import "GoogleClient.h"


@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchbar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *tableData;


@end

@implementation MainViewController
@synthesize tableData;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableData = [[NSMutableArray alloc] init];
    [self readFromFile];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [[self navigationController] setNavigationBarHidden:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)viewWillAppear:(BOOL)animated
{
    self.searchbar.text=@"";
    [self.searchbar setShowsCancelButton:YES animated:NO];
    [super viewWillAppear:animated];

    [[self navigationController] setNavigationBarHidden:YES];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


#pragma mark - Search bar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];

    [self.tableData addObject:searchBar.text];
    [self writeToFile:self.tableData];
    [self startSearch:searchBar.text];
    
}

-(void) startSearch:(NSString*) searchString
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SearchResultsViewController *searchResultsViewController = [storyBoard instantiateViewControllerWithIdentifier:@"SearchResultsViewController"];
    searchResultsViewController.searchString = searchString;
    [self.navigationController pushViewController:searchResultsViewController animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text=@"";
    [searchBar resignFirstResponder];
}

#pragma mark - Table View Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableData count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section

{
    NSString *padding = @"                       ";
    return [NSString stringWithFormat:@"%@%@", padding,@"Search History"];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"SearchResult";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier];
    }
	
    cell.textLabel.text = [self.tableData objectAtIndex:indexPath.row];

    return cell;
}


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self startSearch:tableData[indexPath.row]];

}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.tableData removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self writeToFile:self.tableData];
    }
}

#pragma mark - Persistent Storage

- (void) readFromFile
{
    NSArray *readData = [NSKeyedUnarchiver unarchiveObjectWithFile:[MainViewController getPath]];
    [self.tableData addObjectsFromArray:readData];
}

+(NSString *) getPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"searchHistory.dat"];
}


- (void) writeToFile: (NSMutableArray*) data
{
        [NSKeyedArchiver archiveRootObject:data toFile:[MainViewController getPath]];
}


@end
