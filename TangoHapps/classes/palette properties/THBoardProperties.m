/*
THLilypadProperties.m
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

#import "THBoardProperties.h"
#import "THBoardPinEditable.h"
#import "THLilypadEditable.h"
#import "THLilypadPropertiesPinView.h"
#import "THEditor.h"
#import "THProject.h"
#import "THBoardPropertiesPinCell.h"
#import "THElementPinEditable.h"
#import "THWire.h"

@implementation THBoardProperties

float const kBoardPropertiesContainerHeight = 40;
float const kBoardPropertiesPadding = 10;
float const kBoardPropertiesMaxHeight = 400;
float const kBoardPropertiesMinHeight = 300;


-(NSString *)title {
    return @"Board";
}


#pragma  mark - Table Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.pinsArray.count;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    THBoardPropertiesPinCell * cell = [[THBoardPropertiesPinCell alloc] init];
    
    cell.delegate = self;
    cell.boardPin = [self.pinsArray  objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma  mark - Table Delegate

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        THBoardPinEditable * boardPin = [self.pinsArray objectAtIndex:indexPath.row];
        [boardPin deattachAllPins];
        [self.pinsArray removeObjectAtIndex:indexPath.row];
        
        NSArray * indexPaths = [NSArray arrayWithObject:indexPath];
        [self.pinsTable deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

-(void) generatePinsArray{
    
    self.pinsArray = [NSMutableArray array];
    
    THBoardEditable * board = (THBoardEditable*) self.editableObject;
    
    for (THBoardPinEditable * pin in board.pins) {
        if(pin.attachedPins.count > 0 && pin.type != kPintypeMinus && pin.type != kPintypePlus){
            [self.pinsArray addObject:pin];
        }
    }
}

-(void) updateShowsWires{
    
    THBoardEditable * board = (THBoardEditable*) self.editableObject;
    self.showWiresSwitch.on = board.showsWires;
}

-(void) reloadState{
    [self generatePinsArray];
    [self updateShowsWires];
}

-(void) handleConnectionChanged{
    THDirector * director = [THDirector sharedDirector];
    THEditor * editor = (THEditor*) director.currentLayer;
    
    if(editor.isLilypadMode){
       [self reloadState]; 
    }
}

-(void) handleObjectRemoved:(NSNotification*) notification{
    TFEditableObject * object = notification.object;
    if([object isKindOfClass:[THWire class]]){
        [self reloadState];
        [self.pinsTable reloadData];
    }
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleConnectionChanged) name:kNotificationConnectionMade object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleConnectionChanged) name:kNotificationObjectRemoved object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleObjectRemoved:) name:kNotificationObjectRemoved object:nil];
    
}

-(void) viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void) pinViewCell:(THBoardPropertiesPinCell*) pinViewCell didChangePwmStateTo:(BOOL) pwm{
    
    if(pwm){
        pinViewCell.boardPin.mode = kPinModePWM;
    } else {
        pinViewCell.boardPin.mode = kPinModeDigitalOutput;
    }
}

- (IBAction)editTapped:(id)sender {
    
    if(self.pinsTable.editing){
        
        [self.pinsTable setEditing:NO animated:YES];
        [self.editButton setTitle:@"Edit" forState:UIControlStateNormal];
        
    } else {
        [self.pinsTable setEditing:YES animated:YES];
        [self.editButton setTitle:@"Done" forState:UIControlStateNormal];
    }
}

- (IBAction)showWiresChanged:(id)sender {
    
    THBoardEditable * board = (THBoardEditable*) self.editableObject;
    board.showsWires = self.showWiresSwitch.on;
    THEditor * editor = (THEditor*) [THDirector sharedDirector].currentLayer;
    [editor updateWiresVisibility];
}

@end
