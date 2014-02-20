/*
THTriggerableProperties.m
Interactex Designer

Created by Juan Haladjian on 05/10/2013.

Interactex Designer is a configuration tool to easily setup, simulate and connect e-Textile hardware with smartphone functionality. Interactex Client is an app to store and replay projects made with Interactex Designer.

www.interactex.org

Copyright (C) 2013 TU Munich, Munich, Germany; DRLab, University of the Arts Berlin, Berlin, Germany; Telekom Innovation Laboratories, Berlin, Germany
	
Contacts:
juan.haladjian@cs.tum.edu
katharina.bredies@udk-berlin.de
opensource@telekom.de

    
The first version of the software was designed and implemented as part of "Wearable M2M", a joint project of UdK Berlin and TU Munich, which was founded by Telekom Innovation Laboratories Berlin. It has been extended with funding from EIT ICT, as part of the activity "Connected Textiles".

Interactex is built using the Tango framework developed by TU Munich.

In the Interactex software, we use the GHUnit (a test framework for iOS developed by Gabriel Handford) and cocos2D libraries (a framework for building 2D games and graphical applications developed by Zynga Inc.). 
www.cocos2d-iphone.org
github.com/gabriel/gh-unit

Interactex also implements the Firmata protocol. Its software serial library is based on the original Arduino Firmata library.
www.firmata.org

All hardware part graphics in Interactex Designer are reproduced with kind permission from Fritzing. Fritzing is an open-source hardware initiative to support designers, artists, researchers and hobbyists to work creatively with interactive electronics.
www.frizting.org

Martijn ten Bhömer from TU Eindhoven contributed PureData support. Contact: m.t.bhomer@tue.nl.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 
You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

#import "THTriggerableProperties.h"
#import "TFEditableObject.h"
#import "TFAction.h"
#import "TFConnectionLine.h"
#import "TFMethodInvokeAction.h"
#import "TFEventActionPair.h"
#import "TFMethod.h"
#import "TFEvent.h"

@implementation THTriggerableProperties
@synthesize tableView;
@synthesize removeButton;

+(id) properties{
    return [[[self class] alloc] init];
}

-(id) init{
    self = [ super init];
    if(self){
        CGRect frame = CGRectMake(0, 0, 230, 310);
        self.view = [[UIView alloc] initWithFrame:frame];
        
        CGRect tableFrame = CGRectMake(0, 0, 230, 250);
        self.tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.view addSubview:self.tableView];
        
        CGRect labelFrame = CGRectMake(5, 260, 150, 30);
        self.connectionCountLabel = [[UILabel alloc] initWithFrame:labelFrame];
        self.connectionCountLabel.backgroundColor = [UIColor clearColor];
        self.connectionCountLabel.textColor = [UIColor whiteColor];
        self.connectionCountLabel.font = [UIFont systemFontOfSize:13];
        [self.view addSubview:self.connectionCountLabel];
        
        self.removeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.removeButton.frame = CGRectMake(90, 260, 110, 50);
        [self.removeButton setTitle:@"Hold to remove" forState:UIControlStateNormal];
        self.removeButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [self.removeButton addTarget:self action:@selector(removeButtonDown:) forControlEvents:UIControlEventTouchDown];
        [self.removeButton addTarget:self action:@selector(removeButtonUp:) forControlEvents:UIControlEventTouchUpInside];
        [self.removeButton addTarget:self action:@selector(removeButtonUp:) forControlEvents:UIControlEventTouchUpOutside];
        [self.view addSubview:self.removeButton];
        
    }
    return self;
}

-(NSString *)title
{
    return @"Events";
}

-(void) changeObjectHighlighting:(TFEditableObject*) object highlighted:(BOOL) highlighted{
    
    object.highlighted = highlighted;
    TFEditableObject * editable = (TFEditableObject*) self.editableObject;
    
    THProject * project = [THDirector sharedDirector].currentProject;
    NSArray * connections = [project invocationConnectionsFrom:editable to: object];
    for (TFConnectionLine * connection in connections) {
        connection.selected = highlighted;
    }
}

-(void) highlightOrDeHighlightForEvent:(TFEvent*) event highlighted:(BOOL) highlighted{
    THProject * project = [THDirector sharedDirector].currentProject;
    NSMutableArray * actions = [project actionsForSource:(TFEditableObject*)self.editableObject];
    for (TFEventActionPair * pair in actions) {
        TFEvent * worldEvent = pair.event;
        TFEditableObject * targetObj = pair.action.target;
        if([worldEvent.name isEqualToString:event.name]){
            if(targetObj.highlighted != highlighted){
                [self changeObjectHighlighting:targetObj highlighted:highlighted];
            }
        }
    }
}

-(void) dehighlightForEvent:(TFEvent*) event{
    
    [self highlightOrDeHighlightForEvent:event highlighted:NO];
}

-(void) highlightForEvent:(TFEvent*) event {
    
    [self highlightOrDeHighlightForEvent:event highlighted:YES];
}

-(void) dehighlightCurrentEvent{
    NSIndexPath * selectedRowIdx = self.tableView.indexPathForSelectedRow;
    if(selectedRowIdx){
        NSInteger idx = selectedRowIdx.row;
        TFEditableObject * editable = (TFEditableObject*) self.editableObject;
        TFEvent * event = [editable.events objectAtIndex:idx];
        [self dehighlightForEvent:event];
    }
}

-(void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger idx = indexPath.row;
    TFEditableObject * editable = (TFEditableObject*) self.editableObject;
    TFEvent * event = [editable.events objectAtIndex:idx];
    
    [self dehighlightForEvent:event];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger idx = indexPath.row;
    TFEditableObject * editable = (TFEditableObject*) self.editableObject;
    TFEvent * event = [editable.events objectAtIndex:idx];
    
    [self highlightForEvent:event];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kEditableObjectTableRowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    TFEditableObject * editable = (TFEditableObject*) self.editableObject;
    return editable.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        
    UITableViewCell * cell = [[UITableViewCell alloc] init];
    UILabel * label = cell.textLabel;
    label.font = [UIFont fontWithName:kEditableObjectTableFont size:kEditableObjectTableFontSize];
    
    TFEditableObject * editable = (TFEditableObject*) self.editableObject;
    TFEvent * event = [editable.events objectAtIndex:indexPath.row];
    label.text = event.description;
    
    THProject * project = [THDirector sharedDirector].currentProject;
    NSMutableArray * actions = [project actionsForSource:editable];
    for (TFEventActionPair * pair in actions) {
        if([pair.event.name isEqualToString:event.name]){
            label.textColor = [UIColor blueColor];
            break;
        }
    }
    
    return cell;
}

-(void) updateConnectionLabel {
    THProject * project = [THDirector sharedDirector].currentProject;
    TFEditableObject * editable = (TFEditableObject*) self.editableObject;
    NSMutableArray * actions = [project actionsForSource:editable];
    self.connectionCountLabel.text = [NSString stringWithFormat:@"%d connections",actions.count];
    
    if(actions.count == 0){
        self.removeButton.enabled = NO;
    } else {
        self.removeButton.enabled = YES;
    }
}

-(void) reloadState{
    
    [self.tableView reloadData];
    [self updateConnectionLabel];
    
    CGRect tableFrame = self.tableView.frame;
    self.tableView.frame = CGRectMake(tableFrame.origin.x, tableFrame.origin.y, tableFrame.size.width, self.tableView.contentSize.height);
    
    CGPoint origin = self.removeButton.frame.origin;
    CGSize size = self.removeButton.frame.size;
    self.removeButton.frame = CGRectMake(origin.x, tableFrame.origin.y + self.tableView.frame.size.height + 10, size.width, size.height);
    
    CGPoint originLabel = self.connectionCountLabel.frame.origin;
    CGSize sizeLabel = self.connectionCountLabel.frame.size;
    self.connectionCountLabel.frame = CGRectMake(originLabel.x, tableFrame.origin.y + self.tableView.frame.size.height + 10, sizeLabel.width, sizeLabel.height);
    
    CGRect frame = self.view.frame;
    self.view.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, self.tableView.contentSize.height + 10 + self.removeButton.frame.size.height);
    
    [self.sizeDelegate properties:self didChangeSize:self.view.frame.size];
}

-(void) updateConnectedObjectHighlights:(BOOL) highlighted{
    
    TFEditableObject * editable = (TFEditableObject*) self.editableObject;
    THProject * project = [THDirector sharedDirector].currentProject;
    NSArray * actions = [project actionsForSource:editable];
    
    for (TFEventActionPair * eventActionPair in actions) {
        
        TFEditableObject * object = eventActionPair.action.target;
        object.highlighted = highlighted;
    }
    
    THEditor * editor = (THEditor*) [THDirector sharedDirector].currentLayer;
    editor.removingConnections = highlighted;
}

-(void)removeButtonDown:(id)sender {
    [self dehighlightCurrentEvent];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [self updateConnectedObjectHighlights:YES];
}

-(void) stopRemovingConnections{
    [self updateConnectedObjectHighlights:NO];
}

-(void)removeButtonUp:(id)sender {
    [self stopRemovingConnections];
    
    /*
    TFEditor * editor = (TFEditor*) [TFDirector sharedDirector].currentLayer;
    editor.removeConnections = NO;*/
}

-(void) connectionMade:(NSNotification*) notification{
    TFConnectionLine * connection = notification.object;
    if(connection.obj1 == self.editableObject){
        [self.tableView reloadData];
    }
}

-(void) objectRemoved:(NSNotification*) notification{
    [self.tableView reloadData];
    [self updateConnectionLabel];
}

-(void) viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionMade:) name:kNotificationConnectionMade object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(objectRemoved:) name:kNotificationObjectRemoved object:nil];
    
    [super viewWillAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated{
    [self dehighlightCurrentEvent];
    if(self.removeButton.isTouchInside){
        [self stopRemovingConnections];
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSNotificationCenter *c = [NSNotificationCenter defaultCenter];
    [c addObserver:self selector:@selector(reloadData) name:kNotificationActionAdded object:nil];
    [c addObserver:self selector:@selector(reloadData) name:kNotificationActionRemoved object:nil];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setRemoveButton:nil];
    [self setConnectionCountLabel:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
