/*
THLabel.m
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

#import "THLabel.h"

@implementation THLabel

@dynamic numLines;
@dynamic text;

-(void) loadLabelView{
    
    UILabel * label = [[UILabel alloc] init];
    label.bounds = CGRectMake(0, 0, self.width, self.height);
    label.textAlignment = NSTextAlignmentCenter;
    self.view = label;
    
    self.view.layer.cornerRadius = 5;
    self.view.layer.borderColor = [UIColor blackColor].CGColor;
    self.view.layer.borderWidth = 1.0f;
    
    TFMethod * method1 =[TFMethod methodWithName:@"setText"];
    method1.firstParamType = kDataTypeAny;
    method1.numParams = 1;
    
    TFMethod * method2 =[TFMethod methodWithName:@"appendText"];
    method2.firstParamType = kDataTypeAny;
    method2.numParams = 1;
    
    self.methods = [NSMutableArray arrayWithObjects:method1,method2,nil];
}

-(id) init{
    self = [super init];
    if(self){
        
        self.width = 100;
        self.height = 50;
        
        [self loadLabelView];
        
        self.backgroundColor = [UIColor colorWithRed:0.71 green:0.93 blue:0.93 alpha:1];
        
        self.text = @"Label";
    }
    return self;
}

#pragma mark - Archiving

-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    
    [self loadLabelView];
    
    self.text = [decoder decodeObjectForKey:@"text"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
    [coder encodeObject:self.text forKey:@"text"];
}

-(id)copyWithZone:(NSZone *)zone
{
    THLabel * copy = [super copyWithZone:zone];
    copy.text = self.text;
    
    return copy;
}

#pragma mark - Properties

-(void) setNumLines:(NSInteger)numLines{
    
    UILabel * label = (UILabel*) self.view;
    label.numberOfLines = numLines;
}

-(NSInteger) numLines{
    UILabel * label = (UILabel*) self.view;
    return label.numberOfLines;
}

-(NSString*) convertToString:(id) text{
    NSString * string = @"";
    if([text isKindOfClass:[NSString class]]){
        string = (NSString*) text;
    } else if([text isKindOfClass:[NSNumber class]]){
        NSNumber * number = text;
        string = [number stringValue];
    }
    return string;
}

-(void) appendText:(id) text{
    
    UILabel * label = (UILabel*) self.view;
    
    NSString * string = [self convertToString:text];
    label.text = [label.text stringByAppendingString:string];
}

-(void) setText:(id)text{
    UILabel * label = (UILabel*) self.view;
   
    NSString * string = [self convertToString:text];
    label.text = string;
}

-(NSString*) text{
    UILabel * label = (UILabel*) self.view;
    return label.text;
}

-(NSString*) description{
    return @"label";
}

@end
