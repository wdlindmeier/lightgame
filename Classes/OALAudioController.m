//
//  OALAudioController.m
//  LightGame
//
//  Created by William Lindmeier on 11/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "OALAudioController.h"

#define kAudioInfoBufferId @"bufferId"

@interface OALAudioController(private)

- (AudioFileID)openAudioFile:(NSString*)filePath;
- (UInt32)audioFileSize:(AudioFileID)fileDescriptor;

@end


// http://benbritten.com/2008/11/06/openal-sound-on-the-iphone/comment-page-1/#comment-258

@implementation OALAudioController

#pragma mark Initialization

- (id)init
{
	if(self = [super init]){
		soundDictionary = [[NSMutableDictionary alloc] init];
		//bufferStorageArray = [[NSMutableArray alloc] init];
		[self initOpenAL];
		// load audios?		
	}
	return self;
}

// start up openAL
-(void)initOpenAL
{
	// Initialization
	oalDevice = alcOpenDevice(NULL); // select the "preferred device"
	if (oalDevice) {
		// use the device to make a context
		oalContext=alcCreateContext(oalDevice,NULL);
		// set my context to the currently active one
		alcMakeContextCurrent(oalContext);
	}	
}

#pragma mark Load audio 

//- (void)loadAudioNamed:(NSString *)aFile loops:(BOOL)loops{ // or something

// Returns a source ID that allows the player to keep track of the audio
- (NSUInteger)loadAudioNamed:(NSString *)aFile loops:(BOOL)loops
{
	
	// If the audio is loaded already, just create a new source
	NSMutableDictionary *audioInfo = [soundDictionary objectForKey:aFile];
	NSUInteger bufferID;

	// If it already has a player attached, we'll assume the file's been loaded
	if(!audioInfo){
		
		audioInfo = [NSMutableDictionary dictionary];
		[soundDictionary setObject:audioInfo forKey:aFile];
		
		// get the full path of the file
		NSString* fileName = [[NSBundle mainBundle] pathForResource:aFile ofType:@"caf" inDirectory:@"Audio"];
		// first, open the file
		AudioFileID fileID = [self openAudioFile:fileName];
		UInt32 fileSize = [self audioFileSize:fileID];
		unsigned char * outData = malloc(fileSize);	
		
		// this where we actually get the bytes from the file and put them
		// into the data buffer
		OSStatus result = noErr;
		result = AudioFileReadBytes(fileID, false, 0, &fileSize, outData);
		AudioFileClose(fileID); //close the file
		if (result != 0) NSLog(@"cannot load effect: %@",fileName);
		
		// grab a buffer ID from openAL
		alGenBuffers(1, &bufferID);
		
		// jam the audio data into the new buffer
		// We know the bitrate, but if we didn't,
		// use kAudioFilePropertyDataFormat to get the format, then convert it to the proper AL_FORMAT
		alBufferData(bufferID, AL_FORMAT_STEREO16, outData, fileSize, 44100); 
		
		// save the buffer so I can release it later
		// [bufferStorageArray addObject:[NSNumber numberWithUnsignedInteger:bufferID]];
		[audioInfo setObject:[NSNumber numberWithUnsignedInteger:bufferID] forKey:kAudioInfoBufferId];
		
		// clean up the buffer
		if (outData)
		{
			free(outData);
			outData = NULL;
		}		
	
	}else{

		NSNumber *bufferIDNumber = [audioInfo objectForKey:kAudioInfoBufferId];
		bufferID = [bufferIDNumber unsignedIntValue];
		
	}
	
	// Create the source
	
	/*
	 One note: in a real implementation you will probably have more than one source 
	 (I have a source for each buffer, but I only have about 8 sounds, so this is not a problem). 
	 There is an upper limit on the number of sources you can have. I dont know the actual number 
	 on the iphone, but it is probably something like 16 or 32. The way to deal with this is to 
	 load all your buffers, then dynamically assign those buffers the the next available source 
	 that isnt already playing something else.
	*/
	NSUInteger sourceID;
	
	// grab a source ID from openAL
	alGenSources(1, &sourceID); 
	
	// attach the buffer to the source
	alSourcei(sourceID, AL_BUFFER, bufferID);

	// set some basic source prefs
	alSourcef(sourceID, AL_PITCH, 1.0f);
	alSourcef(sourceID, AL_GAIN, 1.0f);
	
	if (loops) alSourcei(sourceID, AL_LOOPING, AL_TRUE);
	
	// NOTE: How do we unload audio without iterating over each number?
		
	return sourceID;	
}

#pragma mark Start / Stop Audio 

- (void)playAudioWithId:(NSUInteger)sourceID
{
	alSourcePlay(sourceID);
}

- (void)stopAudioWithId:(NSUInteger)sourceID
{
	alSourceStop(sourceID);
}

- (void)adjustPitch:(float)aPitch forSoundId:(NSUInteger)soundId
{
	alSourcef(soundId, AL_PITCH, aPitch);
}

#pragma mark Audio Util 

// open the audio file
// returns a big audio ID struct
- (AudioFileID)openAudioFile:(NSString*)filePath
{
	AudioFileID outAFID;
	// use the NSURl instead of a cfurlref cuz it is easier
	NSURL * afUrl = [NSURL fileURLWithPath:filePath];
	
	// do some platform specific stuff..
#if TARGET_OS_IPHONE
	OSStatus result = AudioFileOpenURL((CFURLRef)afUrl, kAudioFileReadPermission, 0, &outAFID);
#else
	OSStatus result = AudioFileOpenURL((CFURLRef)afUrl, fsRdPerm, 0, &outAFID);
#endif
	if (result != 0) NSLog(@"cannot openf file: %@",filePath);
	return outAFID;
}

// find the audio portion of the file
// return the size in bytes
-(UInt32)audioFileSize:(AudioFileID)fileDescriptor
{
	UInt64 outDataSize = 0;
	UInt32 thePropSize = sizeof(UInt64);
	OSStatus result = AudioFileGetProperty(fileDescriptor, kAudioFilePropertyAudioDataByteCount, &thePropSize, &outDataSize);
	if(result != 0) NSLog(@"cannot find file size");
	return (UInt32)outDataSize;
}

#pragma mark Cleanup 

-(void)cleanUpOpenAL:(id)sender
{
	// delete the sources
	for (NSNumber * sourceNumber in [soundDictionary allValues]) {
		NSUInteger sourceID = [sourceNumber unsignedIntegerValue];
		alDeleteSources(1, &sourceID);
	}
	[soundDictionary removeAllObjects];
	
	// delete the buffers
	for(NSString *audioName in soundDictionary){
		NSMutableDictionary *audioInfo = [soundDictionary objectForKey:audioName];
		NSNumber *bufferNumber = [audioInfo objectForKey:kAudioInfoBufferId];
		NSUInteger bufferID = [bufferNumber unsignedIntegerValue];
		alDeleteBuffers(1, &bufferID);
	}
	//[bufferStorageArray removeAllObjects];
	
	// destroy the context
	alcDestroyContext(oalContext);
	// close the device
	alcCloseDevice(oalDevice);
}

#pragma mark Memory 

- (void)dealloc
{
	//[oalContext release];
	//[oalDevice release];	
	[self cleanUpOpenAL:nil];
	//[bufferStorageArray release];
	[soundDictionary release];
	[super dealloc];
}

+ (OALAudioController *)sharedAudioController
{
	static OALAudioController *sharedController;
	if(sharedController == nil){
		sharedController = [[OALAudioController alloc] init];
	}
	return sharedController;
}

@end
