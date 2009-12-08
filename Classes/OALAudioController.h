//
//  OALAudioController.h
//  LightGame
//
//  Created by William Lindmeier on 11/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <AudioToolbox/AudioToolbox.h>


@interface OALAudioController : NSObject {
	
	ALCcontext* oalContext;
	ALCdevice* oalDevice;	
	NSMutableDictionary *soundDictionary;
	//NSMutableArray *bufferStorageArray;	

}

- (void)initOpenAL;
- (void)cleanUpOpenAL:(id)sender;
- (NSUInteger)loadAudioNamed:(NSString *)aFile loops:(BOOL)loops;
- (void)playAudioWithId:(NSUInteger)soundId;
- (void)stopAudioWithId:(NSUInteger)soundId;
- (void)adjustPitch:(float)aPitch forSoundId:(NSUInteger)soundId;

+ (OALAudioController *)sharedAudioController;


@end
