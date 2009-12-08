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
//- (void)loadAudioNamed:(NSString *)filename loops:(BOOL)loops;
//- (NSString *)loadAudioNamed:(NSString *)fileName loops:(BOOL)loops;
- (NSUInteger)loadAudioNamed:(NSString *)aFile loops:(BOOL)loops;
//- (void)playAudioNamed:(NSString*)soundKey;
- (void)playAudioWithId:(NSUInteger)soundId;
//- (void)stopAudioNamed:(NSString*)soundKey;
- (void)stopAudioWithId:(NSUInteger)soundId;

+ (OALAudioController *)sharedAudioController;


@end
