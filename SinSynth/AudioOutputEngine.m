//
//  AudioOutpuEngine.m
//  SinSynth
//
//  Created by 吉岡 紘二 on 11/12/17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "AudioOutputEngine.h"

OSStatus MyRender( void                        *inRefCon,
				  AudioUnitRenderActionFlags  *ioActionFlags,
				  const AudioTimeStamp        *inTimeStamp,
				  UInt32                      inBusNumber,
				  UInt32                      inNumberFrames,
				  AudioBufferList             *ioData
				  ){
	
	//calling back to AudioOutputEngine::renderCallback
	AudioOutputEngine *engine = (AudioOutputEngine *)inRefCon;
	return [engine renderCallback:ioActionFlags :inTimeStamp :inBusNumber :inNumberFrames :ioData];
	
}




@implementation AudioOutputEngine
@synthesize delegate = delegate_;


-(id)init{
	self = [super init];
	if (self != nil){
		delegate_ = nil;
	}
	
	return self;
}

-(void)initCoreAudio{
	
	ComponentDescription desc;
	desc.componentType = kAudioUnitType_Output;
	desc.componentSubType = kAudioUnitSubType_DefaultOutput; //ユーザが指定したデフォルトの出力デバイスを使う場合。
	//desc.componentSubType = kAudioUnitSubType_HALOutput;	//AudioDeviceを明示的に指定する場合
	desc.componentManufacturer = kAudioUnitManufacturer_Apple;
	desc.componentFlags = 0;		//Always Zero
	desc.componentFlagsMask = 0;	//Always Zero
	
	Component comp = FindNextComponent(NULL, &desc);
	if (comp == NULL){
		printf("FindNextComponent failed\n");
		return;
	}
	
	OSStatus err = OpenAComponent(comp, &outputUnit_);
	if (outputUnit_ == NULL){
		printf("OpenAComponent failed = %ld\n", (long)err);
		return ;
	}
	
	[self setFormat];
	[self setCallback];
	
	
}

-(void)setFormat{
	AudioStreamBasicDescription streamDescription;
	streamDescription.mSampleRate = 44100.0;
	streamDescription.mFormatID = kAudioFormatLinearPCM;
	//streamDescription.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked    	;
	//streamDescription.mFormatFlags = kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved;
    streamDescription.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved;
	streamDescription.mBytesPerPacket = 2;
	streamDescription.mFramesPerPacket = 1;
	streamDescription.mBytesPerFrame = 2;	//OK
	streamDescription.mChannelsPerFrame = 2;
	streamDescription.mBitsPerChannel = 16;//32;//16;
	streamDescription.mReserved = 0;
	
	OSStatus err = AudioUnitSetProperty(
										outputUnit_,
										kAudioUnitProperty_StreamFormat,
										kAudioUnitScope_Input,
										0,
										&streamDescription,
										sizeof(streamDescription));
	if (err != noErr){
		NSLog(@"failed to set format. err = %d",err);
		return;
	}
}


-(void)setCallback{
	AURenderCallbackStruct callbackInfo;
	callbackInfo.inputProc = MyRender;
	callbackInfo.inputProcRefCon = self;
	
	OSStatus err = AudioUnitSetProperty(outputUnit_,
										kAudioUnitProperty_SetRenderCallback,
										kAudioUnitScope_Input,
										0,	//output bus
										&callbackInfo,
										sizeof(callbackInfo));
	if (err != noErr){
		NSLog(@"failed to set callback. err = %d", err);
		return;
	}
	
	NSLog(@"succeeded to setup callback");
}


-(void)start {
	OSStatus err = AudioUnitInitialize(outputUnit_);
	if (err != noErr){
		NSLog(@"failed to start. AudioUnitInitialize returns %d", err);
		return;
	}
	
	err = AudioOutputUnitStart(outputUnit_);
	if (err != noErr){
		NSLog(@"failed to start. AudioOutputInitStart failed with %d", err);
		return;
	}
	
	return;
}

-(void)stop {
	OSStatus err = AudioOutputUnitStop(outputUnit_);
	if (err != noErr){
		NSLog(@"failed to stop. AudioUnitOutputUnitStop returns %d", err);
		return;
	}
	
	err = AudioUnitUninitialize(outputUnit_);
	if (err != noErr){
		NSLog(@"failed to start. AudioUnitUninitialize failed with %d", err);
		return;
	}
	
	return;
}

- (OSStatus) renderCallback:(AudioUnitRenderActionFlags *)ioActionFlags :(const AudioTimeStamp *) inTimeStamp:
(UInt32) inBusNumber: (UInt32) inNumberFrames :(AudioBufferList *)ioData{
	
	
	//http://www.cocoabuilder.com/archive/cocoa/294771-thread-not-registered-mystery-under-gc.html
	//objc_start_collector_thread();	//no effect??
	//objc_registerThreadWithCollector();// not in 10.5SDK(10.6SDK only)
	
	[NSThread currentThread];	//seems does not work as GC Programming Guide says.????
	//http://osdir.com/ml/cocoa-dev/2009-09/msg00672.html OK, don't care about auto_zone_thread_registration_error() in console log.
	
	static UInt32 count = 0;
	if ((count % 100) == 0){
		
		NSLog(@"MyRender," 
			  "%f bus number = %u, frames = %u,"
			  "ratescalar = %f", 
			  inTimeStamp->mSampleTime, 
			  inBusNumber, 
			  inNumberFrames,
			  inTimeStamp->mRateScalar);
		
		NSLog(@"buffer info: mNumberBuffers = %u,"
			  "channels = %u,"
			  "dataByteSize=%u\n", 
			  ioData->mNumberBuffers,
			  ioData->mBuffers[0].mNumberChannels,
			  ioData->mBuffers[0].mDataByteSize);		//16bit,2chの場合はinNumberFrames*4
		
	}
	count++;
	
	UInt32 sampleNum = inNumberFrames;	//in my case
	SInt16 *left = (SInt16 *)ioData->mBuffers[0].mData;
	SInt16 *right = (SInt16 *)ioData->mBuffers[1].mData;
	
	
	if (delegate_){
		if ([delegate_ respondsToSelector:@selector(audioEngineBufferRequired: left: right:)]){
			[delegate_ audioEngineBufferRequired:sampleNum left:left right:right];
		}
		
	}else{
		NSLog(@"no delegate");
		for (int i = 0 ; i < sampleNum; i++){
			left[i] = 0;
			right[i] = 0;
		}
	}
	
	return noErr;
}


@end
