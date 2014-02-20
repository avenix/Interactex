/*
THClotheObjectProperties.m
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

#import "THClotheObjectProperties.h"
#import "THHardwareComponent.h"
#import "THHardwareComponentEditableObject.h"
#import "THElementPinEditable.h"
#import "THElementPin.h"

@implementation THClotheObjectProperties

#pragma mark TableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kEditableObjectTableRowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    THHardwareComponentEditableObject *clotheObject = (THHardwareComponentEditableObject*)self.editableObject;
    return clotheObject.pins.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    THHardwareComponentEditableObject *clotheObject = (THHardwareComponentEditableObject*)self.editableObject;
    
    UITableViewCell * cell = [[UITableViewCell alloc] init];
    UILabel * label = cell.textLabel;
    label.font = [UIFont fontWithName:kEditableObjectTableFont size:kEditableObjectTableFontSize];
    NSInteger idx = indexPath.row;
    
    NSString * cellText;
    THElementPinEditable * pinEditable = [clotheObject.pins objectAtIndex:idx];
    cellText = [NSString stringWithFormat:@"%@",pinEditable.description];
    
    if(!pinEditable.connected){
        label.textColor = [UIColor redColor];
    }
    
    label.text = cellText;
    return cell;
}

-(void) reloadState {
    [self.tableView reloadData];
    
    CGRect tableFrame = self.tableView.frame;
    self.tableView.frame = CGRectMake(tableFrame.origin.x, tableFrame.origin.y, tableFrame.size.width, self.tableView.contentSize.height);
    
    CGRect frame = self.view.frame;
    
    self.view.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, self.tableView.contentSize.height);
        
    [self.sizeDelegate properties:self didChangeSize:self.view.frame.size];
}

-(NSString*) title {
    return @"Pins";
}

-(void) viewWillAppear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadState) name:kNotificationPinAttached object:nil];
}

-(void) viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadState) name:kNotificationPinAttached object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
