/*
THTabbarView.m
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

#import "THTabbarView.h"
#import "THTabbarSection.h"

@implementation THTabbarView

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        [self setBackgroundColor:[UIColor clearColor]];
        [self setClipsToBounds:YES];
        [self setAutoresizingMask:(UIViewAutoresizingFlexibleWidth)];
        _currentY = 0;
        _sections = [NSMutableArray array];
    }
    return self;
}

- (THPalette*)emptyPalette {
    CGRect containerFrame = CGRectMake(0, 0, kTabWidth, 100);
    THPalette *palette = [[THPalette alloc] initWithFrame:containerFrame];
    return palette;
}

-(void)addPaletteSection:(THTabbarSection*) section {
    
    CGRect containerFrame = CGRectMake(0, _currentY, section.frame.size.width, section.frame.size.height);
    section.frame = containerFrame;
    
    _currentY += section.frame.size.height;

    [self setContentSize:CGSizeMake(self.frame.size.width, _currentY)];
    
    [self addSubview:section];
    [_sections addObject:section];
    
    section.sizeDelegate = self;
    
    [self.tabBarDelegate tabBar:self didAddSection:section];
}

-(void) tabbarSection:(THTabbarSection *)section changedSize:(CGSize)size{
    [self relayoutSections];
}

-(void) reloadData{
    [self removeAllSections];
    
    NSInteger numSections = [self.dataSource numPaletteSectionsForPalette:self];
    
    for (int i = 0; i < numSections; i++) {
        
        THPalette * palette = [self emptyPalette];
        NSInteger numItems = [self.dataSource numPaletteItemsForSection:i palette:self];
        
        for (int j = 0; j < numItems; j++) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForItem:j inSection:i];
            
            THPaletteItem * item = [self.dataSource paletteItemForIndexPath:indexPath palette:self];
            [palette addDragablePaletteItem:item];
            
        }
        
        NSString * title = [self.dataSource titleForSection:i palette:self];
        THTabbarSection * section = [THTabbarSection sectionWithTitle:title];
        [section addPalette:palette];
        
        //section.sizeDelegate = self;
        [self addPaletteSection:section];
    }
    
    [self relayoutSections];
}

-(void) relayoutSections{
    
    _currentY = 0;
    for (THTabbarSection * section in _sections) {
        
        CGRect containerFrame = CGRectMake(0, _currentY, section.frame.size.width, section.frame.size.height);
        section.frame = containerFrame;
        
        _currentY += section.frame.size.height;
    }
    
    //[self recalculateFrame];
    
    [self setContentSize:CGSizeMake(self.frame.size.width, _currentY)];
}

-(void) recalculateFrame{
    
    //float navBarHeight = self.navigationController.navigationBar.frame.size.height;
    float navBarHeight = 0;
    float statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    float maxHeight = 768 - navBarHeight - statusBarHeight;
    float height = MIN(_currentY - self.frame.origin.y, maxHeight - self.frame.origin.y);
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
    //NSLog(@"origin : %f height: %f",self.frame.origin.y, height);
}

-(THTabbarSection*) sectionForPalette:(THPalette*) palette{
    for (THTabbarSection * section in _sections) {
        if(section.palette == palette){
            return section;
        }
    }
    return nil;
}

-(THTabbarSection*) sectionNamed:(NSString*) name {
    for (THTabbarSection * section in _sections) {
        if([section.title isEqualToString:name]){
            return section;
        }
    }
    return nil;
}

-(THTabbarSection*) sectionAtLocation:(CGPoint) location{
    for (THTabbarSection * section in _sections) {
        if(CGRectContainsPoint(section.frame,location)){
            return section;
        }
    }
    return nil;
}

-(void) removeSection:(THTabbarSection*) section{
    if(section != nil){
        [_sections removeObject:section];
        [section removeFromSuperview];
    }
}

-(void)removeAllSections {
    for(UIView *container in _sections){
        [container removeFromSuperview];
    }
    
    _currentY = 0;
    [_sections removeAllObjects];
}

@end