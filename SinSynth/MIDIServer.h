//
//  MIDIServer.h
//  SinSynth
//
//  Created by 吉岡 紘二 on 11/12/17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreMIDI/CoreMIDI.h>

@interface MIDIServer : NSObject{
	MIDIClientRef clientRef_;
	MIDIPortRef inputPortRef_;
	id delegate_;
	
}

-(id)init;
-(void)start;
-(void)onMIDIInput:(const MIDIPacketList *)packetList;
@property(retain) id delegate;
@end
