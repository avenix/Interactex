/*
THPaletteViewController.m
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

#import "THPaletteViewController.h"
#import "THTabbarView.h"
#import "THPalette.h"
#import "THDraggedPaletteItem.h"
#import "THCustomPaletteItem.h"

#import "THLipoBatteryPaletteItem.h"

#import "THBLELilyPadPaletteItem.h"
#import "THLilypadPaletteItem.h"
#import "THSimpleLilypadPaletteItem.h"
#import "THJennicPaletteItem.h"

#import "THLedPaletteItem.h"
#import "THButtonPaletteItem.h"
#import "THBuzzerPaletteItem.h"
#import "THLSMCompassPaletteItem.h"
#import "THLightSensorPaletteItem.h"
#import "THPotentiometerPaletteItem.h"
#import "THSwitchPaletteItem.h"
#import "THThreeColorLedPaletteItem.h"
#import "THVibrationBoardPaletteItem.h"
#import "THTemperatureSensorPaletteItem.h"
#import "THAccelerometerPaletteItem.h"

#import "THiPhonePaletteItem.h"
#import "THiPhoneButtonPaletteItem.h"
#import "THLabelPaletteItem.h"
#import "THiSwitchPaletteItem.h"
#import "THMusicPlayerPaletteItem.h"
#import "THTouchpadPaletteItem.h"
#import "THImageViewPaletteItem.h"
#import "THSliderPaletteItem.h"
#import "THContactBookPaletteItem.h"
#import "THMonitorPaletteItem.h"

#import "THClothePaletteItem.h"

#import "THComparatorPaletteItem.h"
#import "THGrouperPaletteItem.h"
#import "THValuePaletteItem.h"
#import "THMapperPaletteItem.h"
#import "THProjectViewController.h"
#import "THTimerPaletteItem.h"
#import "THSoundPaletteItem.h"
#import "THTabbarViewController.h"
#import "THBoolValuePaletteItem.h"
#import "THStringValuePaletteItem.h"
#import "THPureDataPaletteItem.h"
#import "THFlexSensorPaletteItem.h"
#import "THSignalSourcePaletteItem.h"

@implementation THPaletteViewController

-(id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - Populate

-(NSInteger) indexOfSectionNamed:(NSString*) name{
    NSInteger idx = 0;
    
    for (NSString* sectionName in self.sectionNames) {
        if([sectionName isEqualToString:name]){
            return idx;
        }
        idx++;
    }
    return -1;
}

-(void) addCustomPaletteItems{
    
    for (THCustomPaletteItem * paletteItem in _customPaletteItems) {
        //THTabbarSection * section = [((THTabbarView*) self.view) sectionNamed:paletteItem.paletteName];
        //[section.palette addDragablePaletteItem:paletteItem];
        
        NSInteger idx = [self indexOfSectionNamed:paletteItem.paletteName];
        if(idx >= 0){
            NSMutableArray * array = [self.sections objectAtIndex:idx];
            [array addObject:paletteItem];
        }
    }
}

-(void)reloadPalettes {
    [self.tabView reloadData];
}

#pragma mark - Palette Drag Delegate

-(void) palette:(THPalette*)palette didStartDraggingItem:(THPaletteItem*)item withRecognizer:(UIPanGestureRecognizer*)recognizer {
    
    if(_dragView == nil){
        _dragView = [[THDraggedPaletteItem alloc] initWithPaletteItem:item];
        CGPoint location = [recognizer locationInView:self.view];
        _dragView.center = location;
        [self.view addSubview:_dragView];
        
        CGPoint locationEditor = [recognizer locationInView: [CCDirector sharedDirector].view];
        
        _editorDragView = [[THDraggedPaletteItem alloc] initWithPaletteItem:item];
        
        [self.delegate paletteItem:_editorDragView beganDragAt:locationEditor];
    }
}

-(void)palette:(THPalette*)palette didDragItem:(THPaletteItem*)item withRecognizer:(UIPanGestureRecognizer*)recognizer
{
    if(_dragView != nil){
        _dragView.center = [recognizer locationInView:self.view];
        CGPoint locationEditor = [recognizer locationInView: [CCDirector sharedDirector].view];
        [self.delegate paletteItem:_editorDragView movedTo:locationEditor];
    }
}

-(void)palette:(THPalette*)container didDropItem:(THPaletteItem*)item withRecognizer:(UIPanGestureRecognizer*)recognizer
{
    if(_dragView != nil){
        CGPoint location = [recognizer locationInView:self.view];
        if(![self.view pointInside:location withEvent:nil]){
             
            CGPoint editorLocation = [recognizer locationInView:self.view.superview];
            editorLocation = [[CCDirector sharedDirector] convertToGL: editorLocation];
            
            //CGPoint editorLocation = [recognizer locationInView: [[CCDirector sharedDirector] openGLView]];
            
            if([item canBeDroppedAt:editorLocation])
                [item dropAt:editorLocation];
        }
        [_dragView removeFromSuperview];
        [_editorDragView removeFromSuperview];
        _dragView = nil;
        _editorDragView = nil;
        [self.delegate paletteItem:_editorDragView endedAt:location];
    }
}

-(void) palette:(THPalette*)palette didLongPressItem:(THPaletteItem*)item withRecognizer:(UILongPressGestureRecognizer*)recognizer{
    if(item.isEditable){
        [self deselectCurrentObject];
        
        THTabbarSection * section = [((THTabbarView*) self.view) sectionForPalette:palette];
        section.editing = YES;
        self.isEditing = YES;
    }
}

-(void) didTapPalette:(THPalette*) palette{
    if(self.isEditing){
        for (THTabbarSection * section in self.tabView.sections) {
            section.editing = NO;
        }
        self.isEditing = NO;
    }
    [self deselectCurrentObject];
}

#pragma mark Palette Edition Delegate

-(void) palette:(THCustomPaletteItem*)palette didRemoveItem:(THCustomPaletteItem*)item{
    [item deleteArchive];
    [_customPaletteItems removeObject:item];
}

-(void) palette:(THPalette*)palette didSelectItem:(THPaletteItem*)item{
    if(!self.isEditing){
        [self deselectCurrentObject];
        [self selectObject:item];
    }
}

-(void) deselectCurrentObject{
    if(_currentPaletteItem){
        _currentPaletteItem.selected = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPaletteItemDeselected object:_currentPaletteItem];
        _currentPaletteItem = nil;
    }
}

-(void) selectObject:(THPaletteItem*) item{
    item.selected = YES;
    _currentPaletteItem = item;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPaletteItemSelected object:item];
}

#pragma mark TFEditorDragDelegate

-(void) removeCurrentDragView{
    
    [_dragView removeFromSuperview];
    _dragView = nil;
}

-(void) paletteItem:(THPaletteItem*) paletteItem didEnterPaletteAtLocation:(CGPoint) location{
    if(!self.isEditing){
        _dragView = [[THDraggedPaletteItem alloc] initWithPaletteItem:paletteItem];
        location = [TFHelper ConvertFromCocosToUI:location];
        
        UIScrollView * scrollView = (UIScrollView*) self.view;
        location = [self.view.superview convertPoint:location fromView:self.view];
        location = ccpSub(location,scrollView.contentOffset);
        
        _dragView.center = location;
        [self.view addSubview:_dragView];
    }
}

-(void) checkDeselectCurrentSection {
    
    if(_selectedSection){
        [_selectedSection.palette removeTemporaryPaletteItem];
        _selectedSection = nil;
    }
}

-(void) selectSection:(THTabbarSection*) section {
    
    [self checkDeselectCurrentSection];
    _selectedSection = section;
}
 
-(void) paletteItem:(THPaletteItem*) paletteItem didMoveToLocation:(CGPoint) location{
    if(!self.isEditing){
        
        UIScrollView * scrollView = (UIScrollView*) self.view;
        location = [TFHelper ConvertFromCocosToUI:location];
        location = ccpAdd(location,scrollView.contentOffset);
        
        _dragView.center = location;
        
        THTabbarView * tabView = (THTabbarView*) self.view;
        THTabbarSection * section = [tabView sectionAtLocation:location];
        if(section){
            _dragView.state = kPaletteItemStateDroppable;
            if(section != _selectedSection){
                [self selectSection:section];
                THCustomPaletteItem * customPaletteItem = [THCustomPaletteItem paletteItemWithName:paletteItem.name];
                [_selectedSection.palette temporaryAddPaletteItem:customPaletteItem];
            }
        } else {
            _dragView.state = kPaletteItemStateNormal;
            [self checkDeselectCurrentSection];
        }
    }
}

-(void) paletteItem:(THCustomPaletteItem*) paletteItem didDropAtLocation:(CGPoint) location{
    if(!self.isEditing){
        location = [TFHelper ConvertFromCocosToUI:location];
        
        [self removeCurrentDragView];
        
        THTabbarView * tabView = (THTabbarView*) self.view;
        THTabbarSection * section = [tabView sectionAtLocation:location];
        [section.palette addDragablePaletteItem:paletteItem];
        
        paletteItem.paletteName = section.title;
        paletteItem.name = [TFFileUtils resolvePaletteNameConflictFor:paletteItem.name];
        [_customPaletteItems addObject:paletteItem];
        [paletteItem save];
        
        [self checkDeselectCurrentSection];
    }
}

-(void) paletteItemDidExitPalette:(THPaletteItem *)paletteItem{
    if(!self.isEditing){
        [self removeCurrentDragView];
        [self checkDeselectCurrentSection];
    }
}

#pragma mark View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tabView = (THTabbarView*) self.view;
    
    [self.tabView setDelaysContentTouches:NO];
    
    self.tabView.dataSource = self;
    self.tabView.tabBarDelegate = self;
    
    [self loadPaletteData];
    [self useDefaultPaletteSections];
    [self.tabView reloadData];
    
    [self loadCustomPaletteItems];
    [self addCustomPaletteItems];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSelectionLost) name:kNotificationObjectSelected object:nil];
}

-(void) viewWillDisappear:(BOOL)animated{
    [self deselectCurrentObject];
}

-(void) handleSelectionLost{
    _currentPaletteItem.selected = NO;
    _currentPaletteItem = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIDeviceOrientationLandscapeRight);
}

-(void) loadCustomPaletteItems{
    _customPaletteItems = [NSMutableArray array];
    NSArray * files = [TFFileUtils filesInDirectory:kPaletteItemsDirectory];
    for (NSString * file in files) {
        NSString * filePath = [TFFileUtils dataFile:file
                                        inDirectory:kPaletteItemsDirectory];
        THCustomPaletteItem * paletteItem = [THCustomPaletteItem customPaletteItemWithArchiveName:filePath];
        [_customPaletteItems addObject:paletteItem];
    }
}

-(void) save{
    for (THCustomPaletteItem * paletteItem in _customPaletteItems) {
        [paletteItem save];
    }
}

#pragma  mark - Palette Data Source

-(NSInteger) numPaletteSectionsForPalette:(THTabbarView*) tabBar{
    return self.sections.count;
}

-(NSString*) titleForSection:(NSInteger) section palette:(THTabbarView*) tabBar{
    return [self.sectionNames objectAtIndex:section];
}

-(NSInteger) numPaletteItemsForSection:(NSInteger) section palette:(THTabbarView*) tabBar{
    NSArray * items = [self.sections objectAtIndex:section];
    return items.count;
}

-(THPaletteItem*) paletteItemForIndexPath:(NSIndexPath*) indexPath palette:(THTabbarView*) tabBar{
    NSArray * items = [self.sections objectAtIndex:indexPath.section];
    return [items objectAtIndex:indexPath.row];
}


#pragma  mark - Other

-(void) useDefaultPaletteSections{
    
    self.sections = [NSMutableArray arrayWithObjects:self.clothesSectionArray, self.uiSectionArray, self.hardwareSectionArray, self.programmingSectionArray, nil];
    self.sectionNames = [NSMutableArray arrayWithObjects: self.clothesSectionName, self.uiSectionArrayName, self.hardwareSectionName, self.programmingSectionName, nil];
}

-(void) loadPaletteData {
    
    self.clothesSectionArray  = [NSMutableArray arrayWithObjects:[[THClothePaletteItem alloc] initWithName:@"tshirt"], nil];
    
    self.uiSectionArray = [NSMutableArray arrayWithObjects:[[THiPhonePaletteItem alloc] initWithName:@"iphone"],
                           [[THiPhoneButtonPaletteItem alloc] initWithName:@"ibutton"],
                           [[THLabelPaletteItem alloc] initWithName:@"label"],
                           [[THiSwitchPaletteItem alloc] initWithName:@"iswitch"],
                           [[THSliderPaletteItem alloc] initWithName:@"slider"],
                           [[THTouchpadPaletteItem alloc] initWithName:@"touchpad"],
                           [[THMusicPlayerPaletteItem alloc] initWithName:@"musicplayer"],
                           [[THImageViewPaletteItem alloc] initWithName:@"imageview"],
                           [[THContactBookPaletteItem alloc] initWithName:@"contactBook"],
                           [[THMonitorPaletteItem alloc] initWithName:@"monitor"],
                           nil];
    
    
    self.boardsSectionArray  = [NSMutableArray arrayWithObjects:
                                [[THBLELilyPadPaletteItem alloc] initWithName:@"BLE-LilyPad"],
                                [[THLilypadPaletteItem alloc] initWithName:@"lilypadBig"],
                                [[THSimpleLilypadPaletteItem alloc] initWithName:@"lilypadSmall"],
                                [[THJennicPaletteItem alloc] initWithName:@"jennic"],nil];
    
    self.hardwareSectionArray = [NSMutableArray arrayWithObjects:
                                 [[THLedPaletteItem alloc] initWithName:@"led"],
                                 [[THButtonPaletteItem alloc] initWithName:@"button"],
                                 [[THSwitchPaletteItem alloc] initWithName:@"switch"],
                                 [[THBuzzerPaletteItem alloc] initWithName:@"buzzer"],
                                 [[THLSMCompassPaletteItem alloc] initWithName:@"LSMCompass"],
                                 [[THLightSensorPaletteItem alloc] initWithName:@"lightSensor"],
                                 [[THPotentiometerPaletteItem alloc] initWithName:@"potentiometer"],
                                 [[THThreeColorLedPaletteItem alloc] initWithName:@"threeColorLed"],
                                 [[THVibrationBoardPaletteItem alloc] initWithName:@"vibeBoard"],
                                 [[THTemperatureSensorPaletteItem alloc] initWithName:@"temperatureSensor"],
                                 [[THAccelerometerPaletteItem alloc] initWithName:@"accelerometer"],
                                 [[THFlexSensorPaletteItem alloc] initWithName:@"flexsensor"],
                                 nil];
    
    
    self.programmingSectionArray  = [NSMutableArray arrayWithObjects:
                                     [[THComparatorPaletteItem alloc] initWithName:@"comparator"],
                                     [[THGrouperPaletteItem alloc] initWithName:@"grouper"],
                                     [[THMapperPaletteItem alloc] initWithName:@"mapper"],
                                     [[THTimerPaletteItem alloc] initWithName:@"timer"],
                                     [[THSoundPaletteItem alloc] initWithName:@"sound"],
                                     [[THValuePaletteItem alloc] initWithName:@"number"],
                                     [[THBoolValuePaletteItem alloc] initWithName:@"boolean"],
                                     [[THStringValuePaletteItem alloc] initWithName:@"string"],
                                     [[THPureDataPaletteItem alloc] initWithName:@"puredata"],
                                     [[THSignalSourcePaletteItem alloc] initWithName:@"signalsource"],
                                     nil];
    
    self.otherHardwareSectionArray  = [NSMutableArray arrayWithObjects:
                                       [[THLipoBatteryPaletteItem alloc] initWithName:@"lipoBattery"],
                                       nil
                                       ];
                                     
    self.clothesSectionName = @"Textiles";
    self.uiSectionArrayName = @"UI Elements";
    self.boardsSectionName = @"Boards";
    self.hardwareSectionName = @"Hardware Elements";
    self.programmingSectionName = @"Visual Programming";
    self.otherHardwareSectionName = @"Other Hardware";
}

-(void) tabBar:(THTabbarView*) tabBar didAddSection:(THTabbarSection*) section{
    section.palette.dragDelegate = self;
    section.palette.editionDelegate = self;
}

-(void) prepareToDie{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
