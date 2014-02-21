/*
THProtocolSocket.m
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

#import "THProtocolSocket.h"

#define CHUNK_SIZE 81920
#define INITIAL_HEADER_SIZE 6
#define SUBSEQUENT_HEADER_SIZE 1

@implementation THProtocolSocket

- (id)initWithSession:(GKSession*)aSession
               peerID:(NSString*)aPeerID
{
    self = [super init];
    if(self){
        session = aSession;
        peerID = aPeerID;
        receiving = NO;
        sending = NO;
        objectQueue = [NSMutableArray array];
        identifierQueue = [NSMutableArray array];
    }
    return self;
}

-(BOOL)isBusy
{
    return (sending || receiving);
}

#pragma mark - Control Flow

- (void)receiveData:(NSData*)data
{
    unsigned char *packet = (unsigned char *)[data bytes];
    THProtocolPacketHeader packetType = (THProtocolPacketHeader)packet[0];
    
    switch (packetType) {
        case kProtocolPacketInitial:{
            if(!receiving){
                //NSLog(@"<Socket> Received INITIAL packet");
                [self readInitialPacket:data];
                [self sendAcknowledgePacket];
                [self finishReceivingIfDone];
                
            }else{
                //NSLog(@"<Socket> ERROR: Received INITIAL packet while previous transfer is still in progress");
            }
            break;
        }
        case kProtocolPacketSubsequent:{
            if(receiving){
                //NSLog(@"<Socket> Received SUBSEQUENT packet");
                [self readSubsequentPacket:data];
                [self sendAcknowledgePacket];
                [self finishReceivingIfDone];
            }else{
                //NSLog(@"<Socket> ERROR: Received SUBSEQUENT packet while not or no longer receiving");
            }
            break;
        }
        case kProtocolPacketAcknowledge:{
            if(sending){
                BOOL done = [self finishSendingIfDone];
                //NSLog(@"<Socket> Received ACKNOWLEDGE packet. Done: %i", done);
                if(!done){
                    [_delegate socket:self willSendChunk:sentChunks of:sendChunksTotal];
                    sentBytes = [self sendSubsequentPackageWithBuffer:sendBuffer firstByteIndex:sentBytes];
                    sentChunks++;
                    //NSLog(@"<Socket> Sent chunks = %i", sentChunks);
                }else{
                    [self sendNextObject];
                }
            }else{
                //NSLog(@"<Socket> ERROR: Received ACKNOWLEDGE packet while not sending");
            }
            break;
        }
        case kProtocolPacketAbortReceiving:{
            if(receiving){
                //NSLog(@"<Socket> Received ABORT_RECEIVING package");
                [self abortReceiving];
            }else{
                //NSLog(@"<Socket> ERROR: Received ABORT_RECEIVING package while not receiving");
            }
            break;
        }
        case kProtocolPacketAbortSending:{
            if(sending){
                //NSLog(@"<Socket> Received ABORT_SENDING package");
                [self abortSending];
            }else{
                //NSLog(@"<Socket> ERROR: Received ABORT_SENDING package while not sending");
            }
            break;
        }
    }
}
 
- (BOOL)finishReceivingIfDone {
    BOOL done = (receivedChunks >= receiveChunksTotal);
    if(done){
        id object = [NSKeyedUnarchiver unarchiveObjectWithData:receiveBuffer];
        [_delegate socket:self didFinishReceivingObject:object withIdentifier:receivingIdentifier];
        receiving = NO;
        receiveBuffer = nil;
        //NSLog(@"<Socket> Finished receiving %d",receivingIdentifier);
    }
    return done;
}

- (void)abortReceiving {
    receiving = NO;
    receiveBuffer = nil;
    //NSLog(@"<Socket> ABORTED receiving prematurely");
    if([_delegate respondsToSelector:@selector(socket:didAbortReceivingObjectWithIdentifier:)])
        [_delegate socket:self didAbortReceivingObjectWithIdentifier:receivingIdentifier];
}

- (BOOL)finishSendingIfDone {
    BOOL done = (sentBytes >= [sendBuffer length]);
    if(done){
        sending = NO;
        sendBuffer = nil;
        [_delegate socket:self didFinishSendingObjectWithIdentifier:sendingIdentifier];
        //NSLog(@"<Socket> Finished sending");
    }
    return done;
}

-(void)abortSending {
    sending = NO;
    sendBuffer = nil;
    //NSLog(@"<Socket> ABORTED sending prematurely");
    if([_delegate respondsToSelector:@selector(socket:didAbortSendingObjectWithIdentifier:)])
        [_delegate socket:self didAbortSendingObjectWithIdentifier:sendingIdentifier];
}

#pragma mark - Interface

- (void)sendObject:(id<NSCoding>)object
    withIdentifier:(THProtocolObjectIdentifier)identifier
{
    [objectQueue addObject:object];
    [identifierQueue addObject:[NSNumber numberWithInt:(int)identifier]];
    if([objectQueue count] == 1)
        [self sendNextObject];
}

- (void)cancelSendingAndEmptyQueue
{
    [self sendAbortReceivePacket];
    [self abortSending];
    [objectQueue removeAllObjects];
    [identifierQueue removeAllObjects];
}

- (void)cancelReceivingAndEmptyQueue {
    [self sendAbortSendPacket];
    [self abortReceiving];
}

- (void)sendNextObject {
    if([objectQueue count] == 0)
        return;
    id<NSCoding> object = [objectQueue objectAtIndex:0];
    THProtocolObjectIdentifier identifier = (THProtocolObjectIdentifier)[(NSNumber*)[identifierQueue objectAtIndex:0] integerValue];
    [objectQueue removeObjectAtIndex:0];
    [identifierQueue removeObjectAtIndex:0];
    
    sendBuffer = [[NSMutableData alloc] init];
    [sendBuffer appendData:[NSKeyedArchiver archivedDataWithRootObject:object]];
    
    sending = YES;
    sendingIdentifier = identifier;
    sendChunksTotal = [self numberOfChunksForSize:(unsigned long)[sendBuffer length]];
    sentChunks = 0;
    
    [_delegate socket:self didBeginSendingObjectWithIdentifier:sendingIdentifier];
    [_delegate socket:self willSendChunk:sentChunks of:sendChunksTotal];
    
    //NSLog(@"<Socket> Starting transfer of object with identifier: %i, total size = %i, chunks to send = %i", (int)identifier, [sendBuffer length], sendChunksTotal);
    
    sentBytes = [self sendInitialPackageWithIdentifier:identifier sendBuffer:sendBuffer];
    sentChunks++;
}

#pragma mark - Packet Receiving

-(void)readInitialPacket:(NSData*)data {
    unsigned char *packet = (unsigned char *)[data bytes];
    receiving = YES;
    receivingIdentifier = (THProtocolObjectIdentifier)packet[1];
    unsigned long totalSize = ((packet[2] << 24) + (packet[3] << 16) + (packet[4] << 8) + packet[5]);
    receiveBuffer = [[NSMutableData alloc] initWithCapacity:totalSize];
    receiveChunksTotal = [self numberOfChunksForSize:totalSize];
    receivedChunks = 1;
    [receiveBuffer appendBytes:&(packet[INITIAL_HEADER_SIZE]) length:([data length] - INITIAL_HEADER_SIZE)];
    [_delegate socket:self didBeginReceivingObjectWithIdentifier:receivingIdentifier];
    [_delegate socket:self didReceiveChunk:receivedChunks of:receiveChunksTotal];
}

-(void)readSubsequentPacket:(NSData*)data
{
    unsigned char *packet = (unsigned char *)[data bytes];
    receivedChunks++;
    [receiveBuffer appendBytes:&(packet[SUBSEQUENT_HEADER_SIZE]) length:([data length] - SUBSEQUENT_HEADER_SIZE)];
    [_delegate socket:self didReceiveChunk:receivedChunks of:receiveChunksTotal];
}

#pragma mark - Packet Sending

-(unsigned long)sendInitialPackageWithIdentifier:(THProtocolObjectIdentifier)identifier sendBuffer:(NSData*)buffer {
    unsigned long initialPayloadLength = MIN(CHUNK_SIZE - INITIAL_HEADER_SIZE, [buffer length]);
    [self sendPackageWithHeader:kProtocolPacketInitial
                     identifier:identifier
                       sizeInfo:(unsigned long)[buffer length]
                        payload:(unsigned char *)[sendBuffer bytes]
                  payloadOffset:0
                  payloadLength:initialPayloadLength];
    //NSLog(@"<Socket> Sent INITIAL packet. Buffer range 0 - %li", initialPayloadLength);
    return initialPayloadLength;
}

-(unsigned long)sendSubsequentPackageWithBuffer:(NSData*)buffer firstByteIndex:(unsigned long)offset {
    unsigned long payloadLength = MIN(CHUNK_SIZE - 1, [buffer length] - offset);
    [self sendPackageWithHeader:kProtocolPacketSubsequent
                     identifier:kProtocolObjectUndefined
                       sizeInfo:0
                        payload:(unsigned char *)[sendBuffer bytes]
                  payloadOffset:offset
                  payloadLength:payloadLength];
    //NSLog(@"<Socket> Sent SUBEQUENT packet. Buffer range %li - %li", offset, offset + payloadLength);
    return offset + payloadLength;
}

- (void)sendAcknowledgePacket {
    [self sendPackageWithHeader:kProtocolPacketAcknowledge
                     identifier:kProtocolObjectUndefined
                       sizeInfo:0 payload:NULL
                  payloadOffset:0
                  payloadLength:0];
    //NSLog(@"<Socket> Sent ACKNOWLEDGE packet");
}

- (void)sendAbortReceivePacket {
    [self sendPackageWithHeader:kProtocolPacketAbortReceiving
                     identifier:kProtocolObjectUndefined
                       sizeInfo:0 payload:NULL
                  payloadOffset:0
                  payloadLength:0];
    //NSLog(@"<Socket> Sent ABORT_RECEIVING packet");
}

- (void)sendAbortSendPacket {
    [self sendPackageWithHeader:kProtocolPacketAbortSending
                     identifier:kProtocolObjectUndefined
                       sizeInfo:0 payload:NULL
                  payloadOffset:0
                  payloadLength:0];
    //NSLog(@"<Socket> Sent ABORT_SENDING packet");
}

-(void)sendPackageWithHeader:(THProtocolPacketHeader)type
                  identifier:(THProtocolObjectIdentifier)identifier
                    sizeInfo:(unsigned long)size
                     payload:(unsigned char*)payload
               payloadOffset:(unsigned long)payloadOffset
               payloadLength:(unsigned long)payloadLength
{
    int headerSize = 1; // <- First byte = package type
    if(type == kProtocolPacketInitial)
        // An initial package also contains the type (1 byte) and the total size info (4 bytes)
        headerSize += 5;
    // Allocate memory for the package data
    unsigned char *packet = (unsigned char *)malloc(MIN(CHUNK_SIZE, [sendBuffer length] + headerSize));
    packet[0] = (int)type; // Set the package type byte
    if(type == kProtocolPacketInitial){
        // Set the identifier byte
        packet[1] = (int)identifier;
        // Set the total size bytes
        packet[2] = (int)((size >> 24) & 0xFF);
        packet[3] = (int)((size >> 16) & 0xFF);
        packet[4] = (int)((size >> 8) & 0XFF);
        packet[5] = (int)((size & 0XFF));
    }
    if(payloadLength > 0){
        // Copy data from payloadBuffer (with offset and length) to the packet
        for(unsigned long i = payloadOffset; i < (MIN(CHUNK_SIZE - headerSize, payloadLength) + payloadOffset); i++){
            packet[(i - payloadOffset) + headerSize] = payload[i];
        }
    }
    // Create data object from packet bytes
    NSData *data = [NSData dataWithBytesNoCopy:packet
                                        length:MIN(CHUNK_SIZE, payloadLength + headerSize)
                                  freeWhenDone:YES];
    // Finally send the packet via the gamekit session
    NSError *error;
    BOOL success = [session sendData:data
                             toPeers:[NSArray arrayWithObject:peerID]
                        withDataMode:GKSendDataReliable
                               error:&error];
//    BOOL success = [session sendDataToAllPeers:data
//                                  withDataMode:GKSendDataReliable
//                                         error:&error];
    if(!success){
        NSLog(@"ObjectProtocol could not send package: %@", [error localizedDescription]);
        if([_delegate respondsToSelector:@selector(socket:didFailSendingDataWithError:)])
            [_delegate socket:self didFailSendingDataWithError:error];
    }
}

- (NSUInteger)numberOfChunksForSize:(unsigned long)size
{
    // Calculate the number of chunks required for a data size
    int remainder = (NSUInteger)size - (CHUNK_SIZE - INITIAL_HEADER_SIZE);
    NSUInteger subsequentChunks = (remainder > 0) ? ceil((float)remainder / (float)(CHUNK_SIZE - SUBSEQUENT_HEADER_SIZE)) : 0;
    return (subsequentChunks + 1);
}

@end
