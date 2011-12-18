//
//  MIDIServer.m
//  SinSynth
//
//  Created by 吉岡 紘二 on 11/12/17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "MIDIServer.h"

static void MIDIInputProc(const MIDIPacketList *packetList,
						  void *readProcRefCon, void *srcConnRefCon){
	//replay it back to MIDIServer
	MIDIServer *midiServer = (MIDIServer *)readProcRefCon;
	[midiServer onMIDIInput:packetList];
}

@implementation MIDIServer
@synthesize delegate = delegate_;
-(id)init{
	self = [super init];
	if (self != nil){
		NSLog(@"MIDIServer initialized");
		delegate_ = nil;
	}
	
	return self;
}

-(void)start{
	NSString *clientName = @"client";
	OSStatus err = MIDIClientCreate(
									(CFStringRef)clientName,
									NULL,
									NULL,
									&clientRef_);
	
	if (err != noErr){
		NSLog(@"can't create MIDIClient.err = %d", err);
	}
	
	NSString *inputPortName = @"inputPort";
	err = MIDIInputPortCreate(clientRef_, 
							  (CFStringRef)inputPortName,
							  MIDIInputProc,
							  self,
							  &inputPortRef_);

	if (err != noErr){
		NSLog(@"can't create MIDI Input Port for Listen. err=%d", err);
	}
	
	err = MIDIPortConnectSource(inputPortRef_, MIDIGetSource(0), NULL);
	if (err != noErr){
		NSLog(@"can't connect Source. err = %d", err);
	}
	
}

-(void)onMIDIInput:(const MIDIPacketList *)packetList{
	
	//send it to delegate!
	if (delegate_){
		if ([delegate_ respondsToSelector:@selector(midiReceived:)]){

			[delegate_ midiReceived:packetList];
			//NSLog(@"sent delegation");
		}
	}
	
}




@end
