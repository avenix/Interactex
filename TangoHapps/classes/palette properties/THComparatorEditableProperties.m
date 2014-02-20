/*
THComparatorEditableProperties.m
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

#import "THComparatorEditableProperties.h"
#import "THComparisonConditionEditable.h"
#import "THComparisonCondition.h"
#import "TFMethodInvokeAction.h"

@implementation THComparatorEditableProperties
@synthesize operatorTypeLabel;
@synthesize object1Button;
@synthesize object2Button;
@synthesize operatorTypeControl;

-(NSString *)title {
    return @"Comparator";
}

-(void) updateInfoLabel{
    
    THComparisonConditionEditable * condition = (THComparisonConditionEditable*) self.editableObject;
    NSString * text = @"";
    
    
    if(condition.action1 == nil && condition.action2 == nil){

        text = @"Set comparator values for comparator to work. You can do this by dragging connections from other objects to the comparator";
        
    } else if(condition.action1 == nil){
        
        text = @"Set first value for comparator to work";
        
    } else if(condition.action2 == nil){
        
        text = @"Set second value for comparator to work";
        
    } else {
        
        if(condition.action1.firstParam == nil || condition.action2.firstParam == nil){
            
            text = @"The comparator requires numeric input values. Either connect an object's event which has a numeric parameter (such as LED's intensity changed event), or connect a property to the connection between the input objet and the comparator";
            
        } else {
            
            TFEditableObject * object1 = condition.action1.firstParam.target;
            TFEditableObject * object2 = condition.action2.firstParam.target;
            
            //if it was a simulable object, then the event source is the same as the parameter source
            if([object1 isKindOfClass:[TFSimulableObject class]]){
                object1 = condition.action1.source;
            }
            
            if([object2 isKindOfClass:[TFSimulableObject class]]){
                object2 = condition.action2.source;
            }
            
            NSString * conditionStr = condition.conditionTypeString;
            text = [NSString stringWithFormat:@"When the %@'s %@ property is %@ than the %@'s %@ property, the comparator will trigger the conditionIsTrue event. Otherwise it will trigger the conditionIsFalse event", object1, condition.action1.firstParam.property.name, conditionStr, object2, condition.action2.firstParam.property.name];
        }
    }
    
    self.label.text = text;
}

-(NSArray*) selectedConnections {
    NSMutableArray * selectedConnections = [NSMutableArray array];
    if(button1Down){
        [selectedConnections addObject:[NSNumber numberWithInt:0]];
    }
    if(button2Down){
        [selectedConnections addObject:[NSNumber numberWithInt:1]];
    }
    return selectedConnections;
}

-(void) updateOperatorLabel {
    THComparisonConditionEditable * condition = (THComparisonConditionEditable*) self.editableObject;
    
    NSInteger idx = condition.type;
    NSString * conditionString = kConditionTypeStrings[idx];
    self.operatorTypeLabel.text = conditionString;
}

-(void) updateButtons {
    
    THComparisonConditionEditable * conditionEditable = (THComparisonConditionEditable*) self.editableObject;
    
    NSString * title = @"";
    
    if(conditionEditable.action1.firstParam == nil){
        
        self.object1Button.enabled = NO;
        
    } else {
        
        title = [NSString stringWithFormat:@"%@ (%@)",conditionEditable.action1.firstParam.target,conditionEditable.action1.firstParam.property.name];
        self.object1Button.enabled = YES;
    }
    
    [self.object1Button setTitle:title forState:UIControlStateNormal];
    
    if(conditionEditable.action2.firstParam == nil){
        
        title = @"";
        self.object2Button.enabled = NO;
        
    } else {
        
        title = [NSString stringWithFormat:@"%@ (%@)",conditionEditable.action2.firstParam.target,conditionEditable.action2.firstParam.property.name];
        self.object2Button.enabled = YES;
        
    }
    
    [self.object2Button setTitle:title forState:UIControlStateNormal];
}

-(void) updateOperatorType{
    
    THComparisonConditionEditable * condition = (THComparisonConditionEditable*) self.editableObject;
    self.operatorTypeControl.selectedSegmentIndex = condition.type;
}

-(TFConnectionLine*) createConnectionLineFor:(TFEditableObject*) object{
    
    TFConnectionLine * connection = [TFConnectionLine connectionLine];
    connection.obj1 = (TFEditableObject*)self.editableObject;
    connection.obj2 = object;
    connection.selected = YES;
    
    return connection;
}

-(void) addConnection:(TFConnectionLine*) connection{
    THEditor * editor = (THEditor*) [THDirector sharedDirector].currentLayer;
    [editor addConnectionLine:connection];
}

-(void) removeConnection:(TFConnectionLine*) connection{
    
    THEditor * editor = (THEditor*) [THDirector sharedDirector].currentLayer;
    [editor removeConnectionLine:connection];
}

-(void) selectionChanged{
    
    THComparisonConditionEditable * condition = (THComparisonConditionEditable*) self.editableObject;
    
    TFEditableObject * object1 = condition.action1.firstParam.target;
    TFEditableObject * object2 = condition.action2.firstParam.target;
    
    //if it was a simulable object, then the event source is the same as the parameter source
    if([object1 isKindOfClass:[TFSimulableObject class]]){
        object1 = condition.action1.source;
    }
    
    if([object2 isKindOfClass:[TFSimulableObject class]]){
        object2 = condition.action2.source;
    }
    
    if(button1Down){
        
        object1.highlighted = YES;
        self.connection1 = [self createConnectionLineFor:object1];
        [self addConnection:_connection1];
        
    } else {
        
        object1.highlighted = NO;
        [self removeConnection:_connection1];
    }
    
    if(button2Down){
        
        object2.highlighted = YES;
        self.connection2 = [self createConnectionLineFor:object2];
        [self addConnection:_connection2];
        
    } else {
        
        object2.highlighted = NO;
        [self removeConnection:_connection2];
    }
}

- (IBAction)button1Up:(id)sender {
    button1Down = NO;
    [self selectionChanged];
}

- (IBAction)button1Down:(id)sender {
    
    button1Down = YES;
    [self selectionChanged];
}

- (IBAction)button2Up:(id)sender {
    button2Down = NO;
    [self selectionChanged];
}

- (IBAction)button2Down:(id)sender {
    button2Down = YES;
    [self selectionChanged];
}

- (IBAction)operationTypeChanged:(id)sender {
    
    THComparisonConditionEditable * condition = (THComparisonConditionEditable*) self.editableObject;
    condition.type = self.operatorTypeControl.selectedSegmentIndex;
    
    [self updateOperatorLabel];
    [self updateInfoLabel];
}

-(void) reloadState{
    [self updateOperatorLabel];
    [self updateButtons];
    [self updateOperatorType];
    [self updateInfoLabel];
}

-(void) handleInvocationFilled:(NSNotification*) notification{
    
    THComparisonConditionEditable * condition = (THComparisonConditionEditable*) self.editableObject;
    
    TFPropertyInvocation * propertyInvocation1 = condition.action1.firstParam;
    TFPropertyInvocation * propertyInvocation2 = condition.action2.firstParam;
    
    id invocation = notification.object;
    if(invocation == propertyInvocation1 || invocation == propertyInvocation2){
        [self updateButtons];
        [self updateInfoLabel];
    }
}

-(void) viewWillAppear:(BOOL)animated{
    
    id c = [NSNotificationCenter defaultCenter];
    [c addObserver:self selector:@selector(handleInvocationFilled:) name:kNotificationInvocationCompleted object:nil];
}

-(void) viewWillDisappear:(BOOL)animated{
    
    id c = [NSNotificationCenter defaultCenter];
    [c removeObserver:self];
}

- (void)viewDidUnload
{
    [self setOperatorTypeLabel:nil];
    [self setObject1Button:nil];
    [self setObject2Button:nil];
    [self setOperatorTypeControl:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
