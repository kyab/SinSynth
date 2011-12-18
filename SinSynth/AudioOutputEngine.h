//
//  AudioOutputEngine.h
//  SinSynth
//
//  Created by 吉岡 紘二 on 11/12/17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreAudio/CoreAudio.h>
#include <AudioUnit/AudioUnit.h>
#include <AudioUnit/AUComponent.h>
@interface AudioOutputEngine : NSObject
{
	AudioUnit outputUnit_;
	id delegate_;
}

-(void)start;
-(void)stop;

//privates
-(void)setFormat;
-(void)setCallback;
@property(retain) id delegate;

@end
