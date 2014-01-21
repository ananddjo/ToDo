//
//  ToDoViewController.m
//  ToDo
//
//  Created by Anand Joshi on 1/20/14.
//  Copyright (c) 2014 Yahoo! Inc. All rights reserved.
//

#import "ToDoViewController.h"
#import "ToDoCell.h"
#import <objc/runtime.h>

@interface ToDoViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBtn;
@property (strong, nonatomic) IBOutlet UITableView *todoListView;

@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (strong, nonatomic) NSMutableArray *todoList;

- (void) storeTodoListToDisk;

@end

@implementation ToDoViewController


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.userDefaults = [NSUserDefaults standardUserDefaults];
        self.todoList = [self.userDefaults objectForKey:@"ToDOContents"];
        if (!self.todoList) {
            self.todoList = [[NSMutableArray alloc] init];
            NSLog(@"initWithCoder: list is empty");
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
    }
    
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    
    return self;
}

- (IBAction)onAddClick:(id)sender
{
    [self.todoList insertObject:@"" atIndex:0];
    [self.tableView reloadData];
    [self storeTodoListToDisk];
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:path];
    ToDoCell *todoCell = (ToDoCell *) cell;
    [todoCell.todoTxt becomeFirstResponder];
}

- (IBAction)onEditClick:(id)sender
{
    if ([self.todoListView isEditing] == YES) {
        [self.todoListView setEditing:NO animated:YES];
        [self.view endEditing:YES];
        self.navigationItem.leftBarButtonItem.title = @"Edit";
    } else {
        [self.todoListView setEditing:YES animated:YES];
        self.navigationItem.leftBarButtonItem.title = @"Done";
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.todoList.count;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.todoList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView reloadData];
        [self storeTodoListToDisk];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ToDoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.showsReorderControl=YES;
    
    ToDoCell *todoCell = (ToDoCell *)cell;
    todoCell.todoTxt.text = [self.todoList objectAtIndex:indexPath.row];
    objc_setAssociatedObject(todoCell.todoTxt, "INDEX_PATH", indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSUInteger sourceRow = sourceIndexPath.row;
    NSUInteger destRow = destinationIndexPath.row;
    
    NSString *tempTodoText = [self.todoList objectAtIndex:sourceRow];
    
    [self.todoList removeObjectAtIndex:sourceRow];
    [self.todoList insertObject:tempTodoText atIndex:destRow];
    [tableView reloadData];
    [self storeTodoListToDisk];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // Get the text from the text field and update the correct location
    // in the NSMutableArray data source
    NSIndexPath *cellPath = objc_getAssociatedObject(textField, "INDEX_PATH"); // TODO: Use static variable for key
    NSUInteger row = cellPath.row;
    [self.todoList setObject:textField.text atIndexedSubscript:row];
    [self.todoListView reloadData];
    [self storeTodoListToDisk];
}


- (void) storeTodoListToDisk {
    [self.userDefaults setObject:self.todoList forKey:@"ToDOContents"]; // TODO: Use static variable for key
    [self.userDefaults synchronize];
}

- (void)onAppTerminate:(NSNotification *)notification
{
    NSLog(@"onAppTerminate");
    [self storeTodoListToDisk];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

@end


