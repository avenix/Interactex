/*
THServerController.m
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

#import "THServerController.h"
#import "THClientProject.h"
#import "THLilypadEditable.h"
#import "THLilyPad.h"
#import "THBoardPin.h"
#import "THPinValue.h"
#import "THClientProject.h"
#import "THAssetCollection.h"

@implementation THServerController

@dynamic serverIsRunning;

-(id) init {
    self = [super init];
    if(self){
        _peers = [NSMutableDictionary dictionary];
        _agents = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Properties

-(BOOL)serverIsRunning {
    return (session != nil);
}

#pragma mark - Server Control

-(void)startServer {
    if(session) 
        [self stopServer];
    session = [[GKSession alloc] initWithSessionID:kGameKitSessionId displayName:nil sessionMode:GKSessionModeServer];
    [session setDelegate:self];
    session.available = YES;
    [session setDataReceiveHandler:self withContext:nil];
    [_delegate server:self isRunning:YES];
}

-(void)stopServer {
    if(!session)
        return;
    [_delegate server:self isRunning:NO];
    [_delegate server:self isReadyForSceneTransfer:NO];
    [session disconnectFromAllPeers];
    session.available = NO;
    [session setDataReceiveHandler: nil withContext: nil];
    [session setDelegate:nil];
    session = nil;
    [_peers removeAllObjects];
}

#pragma mark- Transfer Agent Hub

-(void) startPushingLilypadStateToAllClients{
    /*
    _transferTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(pushLilypadStateToAllClients) userInfo:nil repeats:YES];*/
}

-(void) stopPushingLilypadState{/*
    [_transferTimer invalidate];
    _transferTimer = nil;*/
}
/*
-(void) pushLilypadStateToAllClients{
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    THLilyPadEditable * lilypadEditable = project.lilypad;
    THLilyPad * lilypad = (THLilyPad*) lilypadEditable.simulableObject;
    
    NSArray * lilypins = lilypad.pins;
    NSMutableArray * pins = [NSMutableArray array];
    
    for (THBoardPin * pin in lilypins) {
        if(pin.mode == kPinModeDigitalInput && pin.hasChanged){
            THPinValue * pinValue = [[THPinValue alloc] init];
            pinValue.type = pin.type;
            pinValue.value = pin.currentValue;
            pinValue.number = pin.number;
            [pins addObject:pinValue];
            
            pin.hasChanged = NO;
        }
    }
 
    //NSLog(@"transferring: %d pins",pins.count);
    
    [self queueTransferAgentActionOnAllClients:kTransferActionInputPinState withObject:pins];
}*/

-(void) pushProjectToAllClients:(THProject*)project {
    
    NSString * projectName = project.name;
    [self queueTransferActionOnAllClients:kTransferActionSceneName withObject:projectName];
    
    THAssetCollection * assetCollection = project.assetCollection;
    [self queueTransferActionOnAllClients:kTransferActionAssets withObject:assetCollection.assetDescriptions];
    
    THClientProject * clientProject = [project nonEditableProject];
    [self queueTransferActionOnAllClients:kTransferActionScene withObject:clientProject];
}

-(void) queueTransferActionOnAllClients:(THTransferAgentAction)action withObject:(id)object {
    for(NSString *peerID in _agents.allKeys){
        [self queueTransferAgentAction:action onClient:peerID withObject:object];
    }
}

-(void) queueTransferAgentAction:(THTransferAgentAction)action onClient:(NSString*)peerID withObject:(id) object {
    THTransferAgent *agent = (THTransferAgent*)[_agents objectForKey:peerID];
    [agent queueAction:action withObject:object];
}

#pragma mark - Session Delegate

-(void) session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error{
    NSLog(@"connection failed: %@",error);
}

-(void) session:(GKSession *)session didFailWithError:(NSError *)error{
    NSLog(@"connection failed :%@",error);
}

-(void)session:(GKSession *)aSession didReceiveConnectionRequestFromPeer:(NSString *)peerID {
    NSError *error;
    [session acceptConnectionFromPeer:peerID error:&error];
}

-(void)session:(GKSession *)aSession peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    if(state == GKPeerStateDisconnected){

        [_peers removeObjectForKey:peerID];
        [_agents removeObjectForKey:peerID];
        [_delegate server:self peerDisconnected:[session displayNameForPeer:peerID]];
        
    } else if(state == GKPeerStateConnecting){
        
    } else if(state == GKPeerStateConnected){

        NSString *peerName = [session displayNameForPeer:peerID];
        NSMutableDictionary *peer = [NSMutableDictionary dictionary];
        [peer setObject:peerName forKey:@"name"];
        [peer setObject:[NSNumber numberWithInt:state] forKey:@"state"];
        [peer setObject:[NSNumber numberWithInt:0] forKey:@"queued_actions"];
        [_peers setValue:peer forKey:peerID];
        
        // Create an agent for the peer
        THTransferAgent *agent = [THTransferAgent masterAgentForClientPeerID:peerID session:session];
        [agent setDelegate:self];
        [_agents setObject:agent forKey:peerID];
        
        [_delegate server:self peerConnected:peerName];
        //[_delegate server:self isReadyForSceneTransfer:([_agents count] > 0)];
    }
    [self updateBusyState];
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void*)context {
    THTransferAgent *agent = (THTransferAgent*)[_agents objectForKey:peer];
    if(agent){
        [agent receiveData:data];
    }
}

#pragma mark - Transfer Agent Delegate

-  (void)agent:(THTransferAgent*)agent willBeginAction:(THTransferAgentAction)action {
    NSString *label = [agent labelForAction:action];
    NSMutableDictionary *peer = (NSMutableDictionary*)[_peers objectForKey:[agent peerID]];
    if(label){
        [peer setObject:[NSNumber numberWithFloat:0.0f] forKey:@"progress"];
        [peer setObject:label forKey:@"action"];
    }else{
        [peer removeObjectForKey:@"action"];
    }
    [self updateBusyState];
}

- (void)agent:(THTransferAgent*)agent madeProgressForCurrentAction:(float)progress {
    NSMutableDictionary *peer = (NSMutableDictionary*)[_peers objectForKey:[agent peerID]];
    [peer setObject:[NSNumber numberWithFloat:progress] forKey:@"progress"];
}

- (void)agent:(THTransferAgent*)agent didFinishAction:(THTransferAgentAction)action withObject:(id)object {
    NSMutableDictionary *peer = (NSMutableDictionary*)[_peers objectForKey:[agent peerID]];
    [peer removeObjectForKey:@"action"];
    [self updateBusyState];
}

- (void)agent:(THTransferAgent*)agent didChangeQueueLengthTo:(NSUInteger)items {
    NSMutableDictionary *peer = (NSMutableDictionary*)[_peers objectForKey:[agent peerID]];
    [peer setObject:[NSNumber numberWithInt:items] forKey:@"queued_actions"];
}

- (void)updateBusyState {
    int busyAgents = 0;
    for(NSString* peerID in _agents){
        THTransferAgent *agent = [_agents objectForKey:peerID];
        if(![agent isIdle]) busyAgents++;
    }
    [_delegate server:self isTransferring:(busyAgents > 0)];
}

@end
