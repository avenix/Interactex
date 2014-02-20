/*
THClientSceneSelectionViewController.m
Interactex Client

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

#import "THClientSceneSelectionViewController.h"
#import "THClientCollectionProjectCell.h"
#import "THClientProjectDraggableCell.h"
#import "THClientProject.h"
#import "THTableProjectCell.h"
#import "THClientAppDelegate.h"
#import "THClientProjectProxy.h"
#import "THClientDownloadViewController.h"
#import "THClientAppViewController.h"
#import "THClientPresetsGenerator.h"
#import "THClientScene.h"

@implementation THClientSceneSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    THClientAppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    self.projectProxies = appDelegate.projectProxies;
    
    THClientPresetsGenerator * fakeScenesSource = [[THClientPresetsGenerator alloc] init];
    [fakeScenesSource generatePresets];
    self.presetProxies = fakeScenesSource.presets;
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonTapped:)];
    
    self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped:)];
    
    self.navigationItem.leftBarButtonItem = self.editButton;
    
}

-(void) viewWillAppear:(BOOL)animated{
    if(self.showingIcons){
        [self addGestureRecognizers];
    }
    
    [self.collectionView reloadData];
    [self.tableView reloadData];
    
    [self updateEditButtonEnabledState];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources  that can be recreated.
}

-(NSString*) title{
    return @"Projects";
}

-(void) addGestureRecognizers{
    ///tap
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    tapRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapRecognizer];
    
    //move
    panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moved:)];
    panRecognizer.delegate = self;
    [self.view addGestureRecognizer:panRecognizer];
    
    //long Press
    longpressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressedLong:)];
    longpressRecognizer.delegate = self;
    [self.view addGestureRecognizer:longpressRecognizer];
}

-(void) removeGestureRecognizers{
    [self.view removeGestureRecognizer: tapRecognizer];
    [self.view removeGestureRecognizer: panRecognizer];
    [self.view removeGestureRecognizer: longpressRecognizer];
    
    tapRecognizer = nil;
    panRecognizer = nil;
    longpressRecognizer = nil;
}

-(void) viewWillDisappear:(BOOL)animated{
    
    [self stopEditingScenes];
    [self removeGestureRecognizers];
    
    THClientAppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate saveProjectProxies];
}

#pragma mark - Private

- (void)proceedToProjectAtIndex:(NSInteger) index{
    
    THClientProjectProxy * proxy = [self.currentProxiesArray objectAtIndex:index];
    
    THClientProject * project;
    
    if(self.showingCustomApps){
        
        project = (THClientProject*) [THClientProject projectSavedWithName:proxy.name];
        
    } else {
        
        project = (THClientProject*) [THClientProject projectSavedWithName:proxy.name inDirectory:kPresetsDirectory];
    }
    
    //update its name since it could have been renamed while it was not loaded
    project.name = proxy.name;
    
    [THSimulableWorldController sharedInstance].currentProject = project;
    [THSimulableWorldController sharedInstance].currentProjectProxy = proxy;
    
    [self performSegueWithIdentifier:@"segueToProjectView" sender:self];
}

-(void) deleteProjectAtIndex:(NSInteger) index{
    
    THClientProjectProxy * projectProxy = [self.currentProxiesArray objectAtIndex:index];
    [self.currentProxiesArray removeObjectAtIndex:index];
    
    [TFFileUtils deleteDataFile:projectProxy.name fromDirectory:kProjectsDirectory];
    
    THClientAppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate saveProjectProxies];
}

#pragma mark - Collection DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.currentProxiesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    THClientProjectProxy * proxy = [self.currentProxiesArray objectAtIndex:indexPath.row];
    
    THClientCollectionProjectCell * cell = (THClientCollectionProjectCell*) [collectionView dequeueReusableCellWithReuseIdentifier:@"projectCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.nameTextField.text = proxy.name;
    
    if(!self.showingCustomApps){
        cell.imageView.image = proxy.image;
    } else {
        cell.imageView.image = [UIImage imageNamed:@"projectIcon"];
    }
    
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    cell.editing = NO;
    cell.nameTextField.hidden = NO;
    
    return cell;
}

#pragma mark - Collection View Delegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void) collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if(self.editingScenes){
        
        for(int i = 0 ; i < self.currentProxiesArray.count ; i++){
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            THClientCollectionProjectCell * cell =  (THClientCollectionProjectCell*) [self.collectionView cellForItemAtIndexPath:indexPath];
            [cell startShaking];
        }
    }
}


- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(self.editingScenes || self.editingOneScene) return NO;
    
    THClientCollectionProjectCell * cell = (THClientCollectionProjectCell*) [self.collectionView cellForItemAtIndexPath:indexPath];
    [self showDuplicateMenuForCell:cell];
    
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    
    return YES;
}

-(void) collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
}

#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.currentProxiesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    THClientProjectProxy * proxy = [self.currentProxiesArray objectAtIndex:indexPath.row];
    
    THClientTableProjectCell * cell = (THClientTableProjectCell*) [tableView dequeueReusableCellWithIdentifier:@"projectTableCell"];
    cell.nameLabel.text = proxy.name;
    
    cell.delegate = self;
    
    return cell;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self proceedToProjectAtIndex:indexPath.row];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        THTableProjectCell * cell = (THTableProjectCell*) [self.tableView cellForRowAtIndexPath:indexPath];
        [cell.textField resignFirstResponder];
        
        [self deleteProjectAtIndex:indexPath.row];
        [self.tableView reloadData];
        if(self.currentProxiesArray.count == 0){
            [self stopEditingScenes];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
    id object = [self.currentProxiesArray objectAtIndex:sourceIndexPath.row];
    [self.currentProxiesArray removeObjectAtIndex:sourceIndexPath.row];
    [self.currentProxiesArray insertObject:object atIndex:destinationIndexPath.row];
    
    [self.collectionView reloadData];
}

//
-(BOOL) tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath{
    UIMenuItem * menuItem = [[UIMenuItem alloc] initWithTitle:@"Duplicate" action:@selector(duplicate:)];
    [[UIMenuController sharedMenuController] setMenuItems: @[menuItem]];
    [[UIMenuController sharedMenuController] update];
    
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    return YES;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    
}

#pragma mark - Table Project Cell Delegate

-(void) tableProjectCell:(THClientTableProjectCell*) cell didChangeNameTo:(NSString*) name{
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    if(indexPath){
        THClientProjectProxy * proxy = [self.currentProxiesArray objectAtIndex:indexPath.row];
        //NSString * oldName = proxy.name;
        BOOL success = [THClientProject renameProjectNamed:proxy.name toName:name];
        if(success){
            //[TFFileUtils renameDataFile:oldName to:name inDirectory:kProjectImagesDirectory];
            
            cell.nameLabel.text = name;
            proxy.name = name;
            
            NSArray * indexPaths = [NSArray arrayWithObject:indexPath];
            [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

-(void) didDuplicateTableProjectCell:(THTableProjectCell*) cell{
    
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    if(indexPath){
        
        [self duplicateProjectAtIndex:indexPath.row];
        
        NSIndexPath * newIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Editing

-(void) startEditingScenes{
    
    if(self.showingIcons){
        for(int i = 0 ; i < self.currentProxiesArray.count ; i++){
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            THClientCollectionProjectCell * cell =  (THClientCollectionProjectCell*) [self.collectionView cellForItemAtIndexPath:indexPath];
            cell.editing = YES;
        }
    } else {
        [self.tableView setEditing:YES animated:YES];
    }
    
    self.editButton.title = @"Done";
    self.editingScenes = YES;
    self.editingOneScene = NO;
    
    self.navigationItem.leftBarButtonItem = self.doneButton;
}

-(void) stopEditingScenes{
    
    //if(self.showingIcons){
    for(int i = 0 ; i < self.currentProxiesArray.count ; i++){
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        THClientCollectionProjectCell * cell =  (THClientCollectionProjectCell*) [self.collectionView cellForItemAtIndexPath:indexPath];
        cell.editing = NO;
    }
    //} else {
    [self.tableView setEditing:NO animated:YES];
    //}
    
    self.editButton.title = @"Edit";
    self.editingScenes = NO;
    self.editingOneScene = NO;
    
    self.navigationItem.leftBarButtonItem = self.editButton;
}

#pragma mark - Gestures

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if([touch.view isKindOfClass:[UIControl class]]){
        return NO;
    }
    return YES;
}

-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if((self.editingScenes || self.editingOneScene) && currentProject && (gestureRecognizer == panRecognizer || otherGestureRecognizer == panRecognizer)) {
        
        return NO;
    }
    
    if((gestureRecognizer == tapRecognizer && otherGestureRecognizer == longpressRecognizer) || (gestureRecognizer == longpressRecognizer && otherGestureRecognizer == tapRecognizer)){
        return (self.editingScenes || self.editingOneScene);
    }
    
    return YES;
}

-(void) handleStartedMoving:(CGPoint) position{
    
    NSIndexPath * indexPath = [self.collectionView indexPathForItemAtPoint:position];
    
    if(indexPath){
        
        currentProjectCell = (THClientCollectionProjectCell*) [self.collectionView cellForItemAtIndexPath:indexPath];
        currentProject = [self.currentProxiesArray objectAtIndex:indexPath.row];
        
        if(currentProjectCell.editing){
            
            currentDraggableCell = [[THClientProjectDraggableCell alloc] initWithFrame:currentProjectCell.frame];
            currentDraggableCell.imageView.image = currentProjectCell.imageView.image;
            currentDraggableCell.imageView.frame = currentProjectCell.imageView.frame;
            
            [self.currentProxiesArray removeObject:currentProject];
            NSArray * indexPaths = [NSArray arrayWithObjects:indexPath, nil];
            [self.collectionView deleteItemsAtIndexPaths:indexPaths];
            
            [self.view addSubview:currentDraggableCell];
            
        }
    }
}

-(void) handleStoppedMoving{
    
    if(currentDraggableCell){
        
        NSIndexPath * indexPath = [self.collectionView indexPathForItemAtPoint:currentDraggableCell.center];
        
        if(!indexPath){
            indexPath = [NSIndexPath indexPathForRow:self.currentProxiesArray.count inSection:0];
        }
        
        [self.currentProxiesArray insertObject:currentProject atIndex:indexPath.row];
        [currentDraggableCell removeFromSuperview];
        
        NSArray * indexPaths = [NSArray arrayWithObject:indexPath];
        [self.collectionView insertItemsAtIndexPaths:indexPaths];
        
        currentProject = nil;
        currentProjectCell = nil;
        currentDraggableCell = nil;
        
        THClientCollectionProjectCell * cell = (THClientCollectionProjectCell*) [self.collectionView cellForItemAtIndexPath:indexPath];
        cell.editing = YES;
        //[cell startShaking];
        
        //[self stopEditingScenes];
    }
}

-(void) moved:(UIPanGestureRecognizer*) recognizer{
    
    if(self.editingScenes || self.editingOneScene){
        
        CGPoint position = [recognizer locationInView:self.collectionView];
        
        if(recognizer.state == UIGestureRecognizerStateBegan){
            
            [self handleStartedMoving:position];
            
        } else if(recognizer.state == UIGestureRecognizerStateChanged){
            
            currentDraggableCell.center = position;
            
        } else if(recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateEnded){
            
            [self handleStoppedMoving];
        }
    }
}

-(void) startEditingScene{
    
    self.editingOneScene = YES;
    currentProjectCell.editing = YES;
}

-(void) duplicateProjectAtIndex:(NSInteger) index{
    
    THClientProjectProxy * proxy = [self.projectProxies objectAtIndex:index];
    
    //project
    THClientProject * project = [THClientProject projectSavedWithName:proxy.name];
    project.name = [THClientProject nextProjectNameForName:project.name];
    [project save];
    
    
    //proxy array
    THClientProjectProxy * proxyCopy = [proxy copy];
    proxyCopy.name = project.name;
    [self.projectProxies insertObject:proxyCopy atIndex:index+1];
}

-(void) showDuplicateMenuForCell:(THClientCollectionProjectCell*) cell{
    
    //[cell becomeFirstResponder];
    
    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"Duplicate" action:@selector(duplicate:)];
    UIMenuController *menuCont = [UIMenuController sharedMenuController];
    [menuCont setTargetRect:cell.frame inView:self.collectionView];
    menuCont.arrowDirection = UIMenuControllerArrowUp;
    menuCont.menuItems = @[menuItem];
}

-(void) pressedLong:(UILongPressGestureRecognizer*) recognizer{

    if(recognizer.state == UIGestureRecognizerStateBegan){
        if(self.showingIcons &&  !(self.editingScenes || self.editingOneScene)){
            
            CGPoint position = [recognizer locationInView:self.collectionView];
            NSIndexPath * indexPath = [self.collectionView indexPathForItemAtPoint:position];
            THClientCollectionProjectCell * cell = (THClientCollectionProjectCell*) [self.collectionView cellForItemAtIndexPath: indexPath];
            
            if(cell){
                [cell scaleEffect];
                currentProjectCell = cell;
                [NSTimer scheduledTimerWithTimeInterval:kProjectCellScaleEffectDuration target:self selector:@selector(startEditingScene) userInfo:nil repeats:NO];
                
                //[self showDuplicateMenuForCell:cell];
            }
        }
    }
}

-(void) tapped:(UITapGestureRecognizer*) recognizer{
    
    if(self.editingScenes || self.editingOneScene){
        
        [self stopEditingScenes];
        
    } else {
        
        CGPoint position = [recognizer locationInView:self.collectionView];
        NSIndexPath * indexPath = [self.collectionView indexPathForItemAtPoint:position];
        
        if(indexPath){
            [self proceedToProjectAtIndex:indexPath.row];
        }
    }
}

#pragma mark - Segue

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:@"segueToDownloadApp"]){
        
        THClientDownloadViewController * controller = segue.destinationViewController;
        controller.delegate = self;
        
    } else if([segue.identifier isEqualToString:@"segueToProjectView"]){
        
        THClientAppViewController * controller = segue.destinationViewController;
        controller.showingPreset = !self.showingCustomApps;
    }
}

#pragma mark - GridItem Delegate

-(void) resignAllCellFirstResponders{
    
    for (int i = 0 ; i < self.currentProxiesArray.count; i++) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        THClientCollectionProjectCell * aCell = (THClientCollectionProjectCell*) [self.collectionView cellForItemAtIndexPath:indexPath];
        [aCell.nameTextField resignFirstResponder];
    }
}

-(void) didDeleteProjectCell:(THClientCollectionProjectCell*) cell {
    
    NSIndexPath * indexPath = [self.collectionView indexPathForCell:cell];
    if(indexPath){
        //[self resignFirstResponder];
        
        [self deleteProjectAtIndex:indexPath.row];
        [self resignAllCellFirstResponders];
        
        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
        
        if(self.editingOneScene){
            self.editingOneScene = NO;
        }
        
        if(self.currentProxiesArray.count == 0){
            [self stopEditingScenes];
            [self updateEditButtonEnabledState];
        }
    }
}

-(void) didDuplicateProjectCell:(THClientCollectionProjectCell*) cell {
    
    NSIndexPath * indexPath = [self.collectionView indexPathForCell:cell];
    if(indexPath){
        
        [self duplicateProjectAtIndex:indexPath.row];
        
        //collection view
        NSIndexPath * newIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:0];
        [self.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
    }
}

-(void) didRenameProjectCell:(THClientCollectionProjectCell *)cell toName:(NSString *)name{
    NSIndexPath * indexPath = [self.collectionView indexPathForCell:cell];
    if(indexPath){
        
        THClientProjectProxy * proxy = [self.currentProxiesArray objectAtIndex:indexPath.row];
        //NSString * oldName = [proxy.name stringByAppendingString:@".png"];
        BOOL success = [THClientProject renameProjectNamed:proxy.name toName:name];
        
        if(success){
            /*
             NSString * imageName = [name stringByAppendingString:@".png"];
             [TFFileUtils renameDataFile:oldName to:imageName inDirectory:kProjectImagesDirectory];*/
            
            cell.nameTextField.text = name;
            proxy.name = name;
            
            //[self.collectionView reloadData];
            //[self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        }
        
        THClientAppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate saveProjectProxies];
    }
}

#pragma mark - UI Interaction

-(BOOL) showingIcons{
    return (self.viewControl.selectedSegmentIndex == 0);
}

-(void) updateEditButtonEnabledState{
    if(self.currentProxiesArray.count == 0){
        self.editButton.enabled = NO;
    } else{
        self.editButton.enabled = YES;
    }
}

- (IBAction)addButtonTapped:(id)sender {
    
}

- (IBAction)viewControlChanged:(id)sender {
    
    if(self.editingScenes){
        [self stopEditingScenes];
    }
    
    if(self.showingIcons){
        [self.collectionView reloadData];
        
        self.tableView.hidden = YES;
        self.collectionView.hidden = NO;
        [self addGestureRecognizers];
        
        
        
    } else {
        [self.tableView reloadData];
        
        self.tableView.hidden = NO;
        self.collectionView.hidden = YES;
        
        [self removeGestureRecognizers];
    }
    
}

- (IBAction)projectTypeControlChanged:(id)sender {
    
    [self reloadCurrentView];
}

- (void) editButtonTapped:(id)sender {
    [self startEditingScenes];
}

- (void) doneButtonTapped:(id)sender {
    
    [self stopEditingScenes];
}

#pragma mark - DownloadDelegate

-(NSInteger) indexOfProjectNamed:(NSString*) name{
    for (int i = 0; i < self.projectProxies.count; i++) {
        THClientProjectProxy * proxy = [self.projectProxies objectAtIndex:i];
        if([name isEqualToString:proxy.name]){
            return i;
        }
    }
    return -1;
}

-(void) removeProxyNamed:(NSString*) name{
    
    NSInteger indexOfProjectWithSameName = [self indexOfProjectNamed:name];
    if(indexOfProjectWithSameName != -1){
        [self.projectProxies removeObjectAtIndex:indexOfProjectWithSameName];
    }
}

-(void) didFinishReceivingProject:(THClientProject*) project{
    
    [project save];
    
    [self removeProxyNamed:project.name];
    
    THClientProjectProxy * proxy = [[THClientProjectProxy alloc] initWithName:project.name];
    [self.projectProxies addObject:proxy];
    
    THClientAppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate saveProjectProxies];
    
    [self.collectionView reloadData];
    [self.tableView reloadData];
}

#pragma mark - Other
/*
- (void)reloadData {
    if([self showingCustomApps]){
        [self.currentCollectionView reloadData];
    } else {
        
    }
}*/

-(void) reloadCurrentView{
    
    if(self.editingScenes){
        [self stopEditingScenes];
    }
    
    if(self.showingIcons){
        [self.collectionView reloadData];
    } else {
        [self.tableView reloadData];
    }
}

-(BOOL) showingCustomApps{
    
    return (self.projectTypeControl.selectedSegmentIndex == 0);
}

-(NSMutableArray*) currentProxiesArray{
    return self.showingCustomApps ? self.projectProxies : self.presetProxies;
}

@end
