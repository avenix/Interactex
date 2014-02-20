/*
TFMethodSelectionPopup.m
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

#import "TFMethodSelectionPopup.h"
#import "TFEditableObject.h"
#import "TFProperty.h"
#import "TFMethod.h"
#import "TFMethodInvokeAction.h"
#import "TFEvent.h"

@implementation TFMethodSelectionPopup

-(id) init{
    self = [super init];
    if(self){
        /*
        _acceptedEvents = [NSMutableArray array];
        _acceptedMethods = [NSMutableArray array];*/
        
    }
    return self;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(tableView == self.table1){
        return [NSString stringWithFormat:@"Events (%@)",self.object1];
        //return @"Events";
    } else {
        return [NSString stringWithFormat:@"Methods (%@)",self.object2];
        //return @"Methods";
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSIndexPath * path1 = self.table1.indexPathForSelectedRow;
    NSIndexPath * path2 = self.table2.indexPathForSelectedRow;
    
    if(path1 != nil && path2 != nil){
        
        TFEvent * event = [_acceptedEvents objectAtIndex:path1.row];
        TFMethod * method = [_acceptedMethods objectAtIndex:path2.row];
        
        TFMethodInvokeAction * action = [[TFMethodInvokeAction alloc] initWithTarget:self.object2 method:method];
        action.firstParam = event.param1;
        action.source = self.object1;
        [self.delegate methodSelectionPopup:self didSelectAction:action forEvent:event];
                
        [popOverController dismissPopoverAnimated:YES];
    }
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kMethodSelectionPopupRowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.table1){
        return _acceptedEvents.count;
    } else {
        return _acceptedMethods.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell = [[UITableViewCell alloc] init];
    UILabel * label = cell.textLabel;
    label.font = [UIFont fontWithName:@"Arial" size:13];
    NSInteger idx = indexPath.row;
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:kSelectionPopupsDefaultColor.r green:kSelectionPopupsDefaultColor.g blue:kSelectionPopupsDefaultColor.b alpha:0.5];
    bgColorView.layer.masksToBounds = YES;
    bgColorView.layer.cornerRadius = 5;
    cell.selectedBackgroundView = bgColorView;
    
    NSString * cellText;
    if(tableView == self.table1){
        TFEvent * event = [_acceptedEvents objectAtIndex:idx];
        cellText = [NSString stringWithFormat:@"%@",event];
    } else{
        TFMethod * method = [_acceptedMethods objectAtIndex:idx];
        cellText = method.description;
    }
    
    label.text = cellText;
    return cell;
}

-(void) selectEventsAndMethods{
    _acceptedEvents = self.object1.events;
    _acceptedMethods = self.object2.methods;
}

-(void) loadTables{
    
    CGRect frame = CGRectMake(0, 0, 200, 200);
    self.view = [[UIView alloc] initWithFrame:frame];
    
    CGRect frame1 = CGRectMake(0, 0, 200, 200);
    self.table1 = [[UITableView alloc] initWithFrame:frame1 style:UITableViewStylePlain];
    self.table1.delegate = self;
    self.table1.dataSource = self;
    self.table1.contentMode = UIViewContentModeLeft;
    self.table1.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    CGRect frame2 = CGRectMake(200, 0, 200, 200);
    self.table2 = [[UITableView alloc] initWithFrame:frame2 style:UITableViewStylePlain];
    self.table2.delegate = self;
    self.table2.dataSource = self;
    self.table1.contentMode = UIViewContentModeRight;
    self.table2.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:self.table1];
    [self.view addSubview:self.table2];
    
    [self adaptSizeToContent];
}

-(void) present{
    
    [self selectEventsAndMethods];
    
    if(_acceptedEvents.count > 0 && _acceptedMethods.count > 0){
        
        [self loadTables];
        
        //popover
        CGPoint position = self.object1.center;
        position = [TFHelper ConvertToCocos2dView:position];
        
        CGRect invokableRect = self.object1.boundingBox;
        float invokableWidth = invokableRect.size.width;
        float invokableHeight = invokableRect.size.height;
        
        CGRect rect = CGRectMake(position.x - invokableWidth/2, position.y - invokableHeight/2, invokableWidth, invokableHeight);
        
        UIView * view = [CCDirector sharedDirector].view;
        popOverController = [[UIPopoverController alloc] initWithContentViewController:self];
        
        [popOverController presentPopoverFromRect:rect inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

-(void) adaptSizeToContent{
    
    NSInteger maxItemCount = MAX(_acceptedEvents.count,_acceptedMethods.count);
    float contentHeight = maxItemCount * kMethodSelectionPopupRowHeight + kPopupHeaderHeight;
    self.contentSizeForViewInPopover = CGSizeMake(400, contentHeight);
}

@end
