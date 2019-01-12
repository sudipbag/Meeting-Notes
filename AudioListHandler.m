//
//  AudioListHandler.m
//  ToolbarSample
//
//  Created by Judhajit2 on 8/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AudioListHandler.h"
#import "AppDelegate.h"

#define DISPLAYNAME @"DisplayName"
#define FULLPATH @"FullPath"
#define CDATE @"cDate"

#define ALARMTIME @"AlarmTime"
#define ALARMDURATION @"AlarmDuration"

#define NOALARM @"No Alarm"

#define VOICE_DURATION @"VoiceDuration"

#define BUTTON_PLAY @"PlayButton"
#define BUTTON_SETALARM @"SetAlarmButton"
#define BUTTON_DELETEALARM @"DeleteAlarmButton"

#define MAX_RECORD_DURATION_LENGTH 9*60*60

@implementation AudioListHandler

@synthesize nsMutaryOfDataObject;
@synthesize idTableView;

NSButton *currentlyInvokedPlayButton;
NSString *audioFolderPath;

//NSString *tempAudioSavePath = @"tempAudioFile.aac";


// ****************************** SQLite Implementation START ******************** //

+(Sqlite *)openDb
{
	if(sqlite != nil)
		return sqlite;
	sqlite = [[Sqlite alloc] init];
    NSArray *paths =   NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    
	//NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);//for document directory
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *folder = [documentsDirectory stringByAppendingPathComponent:@"/MeetingNotesDetails"];
    folder = [folder stringByExpandingTildeInPath];
    
    if ([fileManager fileExistsAtPath: folder] == NO)
    {
        //[fileManager createDirectoryAtPath: folder attributes: nil];
        [fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
    }   
    
    NSString *writableDBPath = [folder stringByAppendingPathComponent:@"/audioandTextData.db"];
	if (![sqlite open:writableDBPath])
	{
		[sqlite release];
		sqlite =nil;
		return nil;
	}
	else 
		return sqlite;
}



+(void) deleteAudioData:(NSDictionary *)dictMemo 
{
	NSMutableString *ms = [[NSMutableString alloc] initWithString:@"DELETE FROM audioandTextData where voiceFileFullPath='"];
	[ms appendString:[dictMemo objectForKey:FULLPATH]];
	[ms appendString:@"';"];
	[sqlite executeNonQuery:ms];
	[ms release];
	
}

+(void) insertIntoDb:(NSDictionary *)dictMemo
{
	[self openDb];
    NSMutableString *strAlarmDate = [[NSMutableString alloc] initWithString:NOALARM];
    if([dictMemo objectForKey:ALARMTIME] != nil)
    {
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [strAlarmDate setString:[dateFormatter stringFromDate:[dictMemo objectForKey:ALARMTIME]]];
    }
	BOOL bStatus = [sqlite executeNonQuery:@"INSERT INTO audioandTextData VALUES (?, ?, ?, ?, ?);", [Sqlite createUuid], [dictMemo objectForKey:FULLPATH], strAlarmDate, [dictMemo objectForKey:ALARMDURATION], [dictMemo objectForKey:DISPLAYNAME] ];
	if(bStatus == NO)
	{
		[sqlite executeNonQuery:@"DROP TABLE audioandTextData"];
		[sqlite executeNonQuery:@"CREATE TABLE audioandTextData (key TEXT NOT NULL, voiceFileFullPath TEXT, alarmTime TEXT, alarmDuration TEXT, displayName TEXT );"];
		[sqlite executeNonQuery:@"DELETE FROM audioandTextData;"];
		[sqlite executeNonQuery:@"INSERT INTO audioandTextData VALUES (?, ?, ?, ?, ?);", [Sqlite createUuid], [dictMemo objectForKey:FULLPATH], strAlarmDate, [dictMemo objectForKey:ALARMDURATION], [dictMemo objectForKey:DISPLAYNAME] ];
	}
    [strAlarmDate release];
	
}

+(void) updateAudioData:(NSDictionary *)dictMemo
{
    [self openDb];
    NSMutableString *strAlarmDate = [[NSMutableString alloc] initWithString:NOALARM];
    if([dictMemo objectForKey:ALARMTIME] != nil)
    {
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [strAlarmDate setString:[dateFormatter stringFromDate:[dictMemo objectForKey:ALARMTIME]]];
    }
	BOOL bStatus = [sqlite executeNonQuery:@"UPDATE audioandTextData SET alarmtime = ?  WHERE voiceFileFullPath = ? AND displayName = ?;", strAlarmDate, [dictMemo objectForKey:FULLPATH], [dictMemo objectForKey:DISPLAYNAME] ];
	if(bStatus == NO)
	{
		[sqlite executeNonQuery:@"DROP TABLE audioandTextData"];
		[sqlite executeNonQuery:@"CREATE TABLE audioandTextData (key TEXT NOT NULL, voiceFileFullPath TEXT, alarmTime TEXT, displayName TEXT );"];
		[sqlite executeNonQuery:@"DELETE FROM audioandTextData;"];
		[sqlite executeNonQuery:@"UPDATE audioandTextData SET alarmtime = ?  WHERE voiceFileFullPath = ? AND displayName = ?;", strAlarmDate, [dictMemo objectForKey:FULLPATH], [dictMemo objectForKey:DISPLAYNAME] ];
	}
    [strAlarmDate release];
    
}

// ****************************** SQLite Implementation END ******************** //



- (id) init {
    self = [super init];
    if (self) {
        currentPlaySpeed = -1;
    }
    return self;
}


-(void)awakeFromNib
{
    if (self.nsMutaryOfDataObject == nil ){
         self.nsMutaryOfDataObject  = [[NSMutableArray alloc] init];
    }
   
    // Trial
    tempAudioSavePath = @"tempAudioFile.m4a";
    NSArray *paths =   NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    
	//NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);//for document directory
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *tempFolder = [documentsDirectory stringByAppendingPathComponent:@"/MeetingNotesDetails/temp"];
    tempFolder = [tempFolder stringByExpandingTildeInPath];
    
    if ([fileManager fileExistsAtPath: tempFolder] == NO)
    {
        //[fileManager createDirectoryAtPath: folder attributes: nil];
        [fileManager createDirectoryAtPath:tempFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    tempAudioSavePath = [tempFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",tempAudioSavePath]];
    tempAudioSavePath = [tempAudioSavePath mutableCopy];
    
    
    
    tempFolder = [documentsDirectory stringByAppendingPathComponent:@"/MeetingNotesDetails/Voice"];
    tempFolder = [tempFolder stringByExpandingTildeInPath];
    
    if ([fileManager fileExistsAtPath: tempFolder] == NO)
    {
        [fileManager createDirectoryAtPath:tempFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    // End Trial
    
}


-(void)stopAnyRecording
{
    if(audioLevelTimer == nil)
        return;
    
    [playAndAppendView setHidden:NO];
    [recordingView setHidden:YES];
    
    
    //[mCaptureMovieFileOutput pauseRecording];
   // [mCaptureSession stopRunning];
    
    
    [audioLevelTimer invalidate];
    //[audioLevelTimer release];
    audioLevelTimer = nil;
    
    [audioLevelMeter setFloatValue:0.0f];
    
    [lblRecordingDuration setStringValue:@""];

    //[mCaptureMovieFileOutput recordToOutputFileURL:nil];
    
  //  [mCaptureMovieFileOutput setDelegate:nil];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:tempAudioSavePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:tempAudioSavePath error:nil];
    }
    
}


-(void)setControlStatesOnSelection:(BOOL)bState
{
    [btnSave setEnabled:bState];
    [btnPauseEx setEnabled:bState];
    [btnAppend setEnabled:bState];
    [btnPlayEx setEnabled:bState];
    
    [segPlaySpeedControl setEnabled:bState];
    [sliderPlayProgress setEnabled:bState];
    
    
    [lblSave setTextColor:bState ? [NSColor grayColor] : [NSColor blackColor]];
    [lblPlayEx setTextColor:bState ? [NSColor grayColor] : [NSColor blackColor]];
    [lblPauseEx setTextColor:bState ? [NSColor grayColor] : [NSColor blackColor]];
    [lblAppend setTextColor:bState ? [NSColor grayColor] : [NSColor blackColor]];
    
    [lblSpeedControl setTextColor:bState ? [NSColor grayColor] : [NSColor blackColor]];
    
}

-(NSString *) getDuration :(int)duration
{
    //int milliseconds =0;
    NSMutableString *strDuration=[[[NSMutableString alloc] initWithString:@""] autorelease] ;
    
    
    int seconds = duration % 60;
    if(duration <60)
    {
        [strDuration appendFormat:@"%i sec",seconds];
    }
    else
    {
        duration /= 60;
        int minutes = duration % 60;
        if(duration <60)
        {
            [strDuration appendFormat:@"%i min %i sec",minutes,seconds];
        }
        else
        {
            duration /= 60;
            int hours = duration % 24;
            [strDuration appendFormat:@"%i hr %i min %i sec",hours,minutes,seconds];
        }
    }
    return strDuration;    
    
}



- (void)updateRecordingAudioLevels:(NSTimer *)timer
{
    if(audioLevelTimer == nil)
        return;
	// Get the mean audio level from the movie file output's audio connections
//    if(floatRecordingDuration >= MAX_RECORD_DURATION_LENGTH)
//    {
//        [self performSelectorOnMainThread:@selector(onMaxRecordingTimeReached) withObject:nil waitUntilDone:NO];
//        return;
//    }

    floatRecordingDuration = recorder.currentTime;
    [recorder updateMeters];
    float floatVal = [recorder peakPowerForChannel:0];
    audioLevelMeter.floatValue = floatVal;
    [lblRecordingDuration setStringValue:[self getDuration:((int)floatRecordingDuration)]];
    
}


/*
- (void)updateRecordingAudioLevels2:(NSTimer *)timer
{
    [recorder updateMeters];
    float decibel = -[recorder peakPowerForChannel:0];
    [audioLevelMeter setFloatValue:(float)(pow(10., 0.05 * decibel) * 20.0)];
    
    floatRecordingDuration += 0.1f;
    [lblRecordingDuration setStringValue:[self getDuration:((int)floatRecordingDuration)]];
}
*/
-(void)menuWillOpen:(NSMenu *)menu{
    
    NSEvent * event = [NSApp currentEvent];
    if (event == nil) {
        [menu cancelTracking];
        return;
    }
    
    NSPoint pt = [idTableView convertPoint:[event locationInWindow] fromView: NULL];//idTableView.superview
    NSInteger rowToSelect = [idTableView rowAtPoint:pt];
    
    BOOL bValidIndex = false;
    if (rowToSelect != -1 && rowToSelect != NSNotFound) {
        bValidIndex = (rowToSelect >= 0 && rowToSelect < [self.nsMutaryOfDataObject count]);
    }
    
    if (!bValidIndex) {
        [menu cancelTracking];
        return;
    }
    NSDictionary *dict = [self.nsMutaryOfDataObject objectAtIndex:rowToSelect];
    if(dict == nil){
        [menu cancelTracking];
        return;
    }
    
    [idTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:(rowToSelect)] byExtendingSelection:NO];
    
    
}

-(NSString*) getAudioFolderPath
{
    NSArray *paths =   NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	//NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);//for document directory
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    audioFolderPath = [[documentsDirectory stringByAppendingPathComponent:@"/MeetingNotesDetails/Voice"] mutableCopy];
    audioFolderPath = [audioFolderPath stringByExpandingTildeInPath];
    
    if ([fileManager fileExistsAtPath: audioFolderPath] == NO)
    {
        [fileManager createDirectoryAtPath:audioFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    audioFolderPath = [audioFolderPath stringByAppendingString:@"/"];
    return audioFolderPath;
}

- (NSString*)getAudioSavePath
{
    //NSMutableString *basePath = [[NSMutableString alloc] initWithString:[self getAudioFolderPath]];
    NSMutableString *basePath = [[[NSMutableString alloc] initWithString:[self getAudioFolderPath]] autorelease];
    
    [basePath appendString:@"Audio - "];
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"YYYYMMddHHmmss"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    [basePath appendString:strDate];
    
    [basePath appendString:@".m4a"];//mp3
    return basePath;
    
}


- (void)sheetDidEnd:(NSWindow*)sheet returnCode:(int)code contextInfo:(void*)info
{
    [txtAdioFileName setStringValue:@""];
    [sheet orderOut:self];
}


-(void)startRecordingAudio {
    
    NSURL *audioRecordingURL = [[NSURL alloc] initFileURLWithPath:tempAudioSavePath];
    NSError * error = NULL;
    @try{
        recorder = [[AVAudioRecorder alloc] initWithURL:audioRecordingURL settings:[self audioRecordingSettings] error:&error];
    }@catch(NSException *exception){
        
    }
    
    if (recorder != nil ){
        [recorder setDelegate:self];
        if ([recorder prepareToRecord]){
            [recorder record];
            [recorder updateMeters];
            [recorder setMeteringEnabled:YES];
            floatRecordingDuration = recorder.currentTime;
        }
    }
}

-(NSDictionary*)audioRecordingSettings {
    
    NSMutableDictionary *recordingSettings= [[NSMutableDictionary alloc] init];
    [recordingSettings setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordingSettings setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    [recordingSettings setValue:[NSNumber numberWithInt: 80000] forKey:AVEncoderBitRateKey];
    [recordingSettings setValue:[NSNumber numberWithInt: kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordingSettings setValue:[NSNumber numberWithInt: AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
    return recordingSettings;
}


//Trial 2
- (IBAction)startStopRecording:(id)sender
{
    if([sender state] == NSOnState)
    {
        if([[NSFileManager defaultManager] fileExistsAtPath:tempAudioSavePath])
        {
            [[NSFileManager defaultManager] removeItemAtPath:tempAudioSavePath error:nil];
        }
        
        [playAndAppendView setHidden:YES];
        [recordingView setHidden:NO];
        
        floatRecordingDuration = 0.0f;
        [self startRecordingAudio];
        [self updateRecordingAudioLevels:nil];
        audioLevelTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateRecordingAudioLevels:) userInfo:nil repeats:YES];
        
       // [mCaptureSession startRunning];
      //  [mCaptureMovieFileOutput recordToOutputFileURL:[NSURL fileURLWithPath:tempAudioSavePath]];
        //[mCaptureMovieFileOutput resumeRecording];
        
    }
    else
    {
        [playAndAppendView setHidden:NO];
        [recordingView setHidden:YES];

        //[mCaptureMovieFileOutput pauseRecording];
       // [mCaptureSession stopRunning];
        [audioLevelTimer invalidate];
        //[audioLevelTimer release];
        audioLevelTimer = nil;
        [recorder stop];
        [audioLevelMeter setFloatValue:0.0f];
        [lblRecordingDuration setStringValue:@""];
        
        /*
        [NSApp beginSheet:nameAlarmEntryWindow
           modalForWindow:mainWindow
            modalDelegate:self
           didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
              contextInfo:nil];*/
        //[self onDoneOrCancelAddMemo:YES];
       // [mCaptureMovieFileOutput recordToOutputFileURL:nil];
       // [self performSelector:@selector(delaySaveRecorderAudio) withObject:nil afterDelay:(CGFloat)(floatRecordingDuration/1000)];
        
        [NSApp beginSheet:saveWin
           modalForWindow: mainWindow
            modalDelegate:self
           didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
              contextInfo:nil];
    }
}

-(IBAction) closeWindow :(id)sender {
     [NSApp endSheet:saveWin];
    
}


-(IBAction) saveAudio :(id)sender {
    NSURL *outputFileURL = [NSURL fileURLWithPath:tempAudioSavePath];    // Was retained when the sheet was opened

    NSString * strTitle = [[txtAdioFileName stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    strTitle = [strTitle length] > 0 ? [strTitle capitalizedString] : @"UnTitled" ;

    NSString *audioFullPath = [self getAudioSavePath];
    NSString * lastPathComp = [audioFullPath lastPathComponent];
    audioFullPath = [audioFullPath stringByDeletingLastPathComponent];
    if([strTitle length] > 0){
        lastPathComp = [lastPathComp stringByReplacingOccurrencesOfString:@"Audio" withString:strTitle];
    }
    audioFullPath = [audioFullPath stringByAppendingPathComponent:lastPathComp];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:audioFullPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:audioFullPath error:nil];
    }
    
    [[NSFileManager defaultManager] moveItemAtPath:[outputFileURL path] toPath:audioFullPath error:nil];
   
    if(floatRecordingDuration > 0){
        [self addToTable:audioFullPath ofDuration:floatRecordingDuration filePathName:strTitle];
    }
    
    
    [NSApp endSheet:saveWin];
   // [saveWin orderOut:self];
}

-(void)addToTable:(NSString*)audioPathFull ofDuration:(NSInteger)duration filePathName: (NSString*)strDisplayName
{
    NSMutableDictionary *dictMemo = [[[NSMutableDictionary alloc] init] autorelease];
    [dictMemo setValue:audioPathFull forKey:FULLPATH];
    
    [dictMemo setValue:strDisplayName forKey:DISPLAYNAME];
    [dictMemo setValue:[NSDate new] forKey:ALARMTIME];
 
    NSString* filename = [audioPathFull lastPathComponent];
    NSArray* arr1 = [filename componentsSeparatedByString:@"."];
    filename = [arr1 objectAtIndex:0];
    
    NSString* strDuration = [NSString stringWithFormat:@"%i",((int)duration)];
    [dictMemo setValue:strDuration forKey:ALARMDURATION];
    
    [AudioListHandler insertIntoDb:dictMemo];
    
    [self.nsMutaryOfDataObject addObject:dictMemo];
    if( [self.nsMutaryOfDataObject count] == 0) {
        return;
    }
    NSSortDescriptor *alarmTimeDescriptor = [[NSSortDescriptor alloc] initWithKey:ALARMTIME ascending:YES selector:@selector(compare:)];
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:DISPLAYNAME ascending:YES selector:@selector(caseInsensitiveCompare:)];

    NSArray *descriptors = [NSArray arrayWithObjects:alarmTimeDescriptor,nameDescriptor,nil];

    [self.nsMutaryOfDataObject sortUsingDescriptors:descriptors];
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        MyDocument * doc = [(AppDelegate*)[NSApp delegate] getDocument];
        [[[doc rightConstrint] animator] setConstant:404.0];
    }];
    [idTableView reloadData];
    [NSAnimationContext endGrouping];
   
    
}

-(IBAction)onDeleteAudio:(id)sender{
    [self onDelete ];
}

-(IBAction)onRenameAudio:(id)sender{
    
}

-(void)onDelete
{
    NSInteger selectedRow = [idTableView selectedRow];
    
    if( selectedRow < 0 )
        return;
    if([self.nsMutaryOfDataObject count] <= selectedRow)
        return;
    
    [idTableView deselectAll:nil];
    NSIndexSet *idx = [[[NSIndexSet alloc] initWithIndex:selectedRow] autorelease];
    [idTableView selectRowIndexes:idx byExtendingSelection:YES];
    
    NSAlert *alert = [NSAlert alertWithMessageText:@"Do you want to remove this recording?"
                                     defaultButton:@"Yes"
                                   alternateButton:@"No"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    //[alert setIcon:@"icon_question.png"];
    [alert setIcon:[NSImage imageNamed:@""]];
    [[alert window] setTitle:@"Confirm record Deletion"];
    [alert beginSheetModalForWindow:mainWindow modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
    
}

- (void) alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    if(returnCode == 1)
    {
        NSInteger currentIndex = [idTableView selectedRow];
        if( currentIndex < 0 )
            return;
        
        if([self.nsMutaryOfDataObject count] <= currentIndex)
            return;
        
        NSMutableDictionary *dictMemo = [self.nsMutaryOfDataObject objectAtIndex:currentIndex];
        [idTableView reloadData];

    }
}

/*
-(void)addToTable:(NSString*)audioPathFull ofDuration:(NSInteger)duration
{
    NSMutableDictionary *dictMemo = [[[NSMutableDictionary alloc] init] autorelease];
    [dictMemo setValue:audioPathFull forKey:FULLPATH];
    
    
    NSString* filename = [audioPathFull lastPathComponent];
    NSArray* arr1 = [filename componentsSeparatedByString:@"."];
    filename = [arr1 objectAtIndex:0];
    
    NSArray *arr = [filename componentsSeparatedByString:@"_"];
    
    //if([segAlarmOnOff selectedSegment] == 0)
    {
        
        [dictMemo setValue:[[dtAlarmDateAndTime dateValue] copy] forKey:ALARMTIME];
    }
    
    NSUInteger count = [arr count];
    
    if([segAlarmOnOff selectedSegment] == 0)
        count--;
    int i = 0;
    
    NSMutableString *displayName = [[[NSMutableString alloc] init] autorelease];
    
    for(i=0 ; i < count ; i++)
    {
        if([arr objectAtIndex:i] == nil)
            continue;
        if([displayName length] <= 0)
            [displayName appendString:[arr objectAtIndex:i]];
        else
            [displayName appendFormat:@"_%@",[arr objectAtIndex:i]];
    }
    
    [displayName setString:[txtVoiceMemoName stringValue]];
    
    [dictMemo setValue:displayName forKey:DISPLAYNAME];
    
  
    NSString* strDuration = [NSString stringWithFormat:@"%i",((int)duration)];
    [dictMemo setValue:strDuration forKey:ALARMDURATION];
    
    [VoiceMemoApp1Delegate insertIntoDb:dictMemo];
    
    [self.nsMutaryOfDataObject addObject:dictMemo];
    
    [self sortVoiceMemoList];
    
   
    
    [idTableView reloadData];
    [self setSelectedMemo:dictMemo];
    
}
*/

//End Trial 2



-(void)setSelectedMemo:(NSMutableDictionary*)aDict
{
    if(aDict == nil)
        return;
    
    if(self.nsMutaryOfDataObject == nil || [self.nsMutaryOfDataObject count] <= 0)
        return;
    
    NSInteger noOfMemos = [self.nsMutaryOfDataObject count];
    NSInteger count = 0;
    
    for (count = 0; count < noOfMemos; count++) 
    {
        NSMutableDictionary *dict = (NSMutableDictionary*)[self.nsMutaryOfDataObject objectAtIndex:count];
        if(dict == aDict)
        {
            NSInteger selectedRow = [idTableView selectedRow];
            if(selectedRow == count)
                return;
            [idTableView deselectAll:nil];
            
            NSIndexSet *idx = [[[NSIndexSet alloc] initWithIndex:count] autorelease];
            [idTableView selectRowIndexes:idx byExtendingSelection:TRUE];
            [idTableView scrollRowToVisible:count];
            
            return;
        }
    }
    
}


-(void)delayPutSpaceBeforeAudioAttachment
{
    NSString *A2String = @"tell application \"System Events\" \n"
    @"tell process \"Mail\" \n"
    @"keystroke (ASCII character 28) \n"
    @"keystroke space \n"
    @"end tell \n"
    @"end tell \n";
    
    NSAppleScript *appPasteCmd = [[NSAppleScript alloc] initWithSource:A2String]; 
    [appPasteCmd executeAndReturnError:nil];
    [appPasteCmd release];
}



- (IBAction)onNameAlarmEntryDone:(id)sender
{
    [nameAlarmEntryWindow setIsVisible:NO];
    
    [NSApp endSheet:nameAlarmEntryWindow returnCode:NSOKButton];
    
    [self onDoneOrCancelAddMemo:YES];
    
    [[NSApplication sharedApplication] stopModal];
}


- (IBAction)onCancelNameEntry:(id)sender
{
    nameEntryCancelled = YES;
    [nameAlarmEntryWindow setIsVisible:NO];
    
    [NSApp endSheet:nameAlarmEntryWindow returnCode:NSOKButton];
    
    [self onDoneOrCancelAddMemo:NO];
    
    [[NSApplication sharedApplication] stopModal];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)pTableViewObj{
    return (NSInteger)[self.nsMutaryOfDataObject count];
} // end numberOfRowsInTableView

-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    
    NSTableCellView * cellView = (NSTableCellView*)[tableView makeViewWithIdentifier:@"cell" owner:self] ;
    if (cellView == nil ){
        return cellView;
    }
    
    if (row < 0 || row >= self.nsMutaryOfDataObject.count) {
        return cellView;
    }
    
    NSDictionary *dictMemo = (NSDictionary*)[self.nsMutaryOfDataObject objectAtIndex:row];
    if(dictMemo == nil)
        return cellView;
    
    NSButton * btn = (NSButton*)[cellView viewWithTag:0];
    [btn setAction:@selector(onPlay:)];
    [btn setTarget:self];
    NSButton * btnOption = (NSButton*)[cellView viewWithTag:6];
    [btnOption setAction:@selector(onShowMenu:)];
    [btnOption setTarget:self];
    
    NSTextField * lblTitle = (NSTextField*)[cellView viewWithTag:1];
    NSTextField * lblSubTitle = (NSTextField*)[cellView viewWithTag:2];
    NSTextField * lblduration = (NSTextField*)[cellView viewWithTag:3];
    NSSlider * slider = (NSSlider*)[cellView viewWithTag:4];
    [slider setAction:@selector(onChnageSlider:)];
    [slider setTarget:self];
    
    NSString *strDuration = [dictMemo valueForKey:ALARMDURATION];
    [lblduration setStringValue:[self getDuration_Prev2:[strDuration intValue]]];
    
    NSDate * strTime = [dictMemo valueForKey:ALARMTIME];
    NSDateFormatter * formatt = lblSubTitle.cell.formatter;
    NSString  *strDt = [formatt stringFromDate:strTime];
    [lblSubTitle setStringValue:strDt];

    [lblTitle setStringValue:[dictMemo valueForKey:DISPLAYNAME]];
    return cellView;
}


-(NSString *) getDuration_Prev2 :(int)duration
{
    NSMutableString *strDuration=[[[NSMutableString alloc] initWithString:@""] autorelease] ;
    int seconds = duration % 60;
    
    NSString *strSec = nil;
    if(seconds < 10)
        strSec = [NSString stringWithFormat:@"0%i",seconds];
    else
        strSec = [NSString stringWithFormat:@"%i",seconds];
    
    if(duration <60)
    {
        [strDuration appendFormat:@"00:%@",strSec];
    }
    else
    {
        duration /= 60;
        int minutes = duration % 60;
        
        NSString *strMin = nil;
        if(minutes < 10)
            strMin = [NSString stringWithFormat:@"0%i",minutes];
        else
            strMin = [NSString stringWithFormat:@"%i",minutes];
        
        if(duration <60)
        {
            [strDuration appendFormat:@"%@:%@",strMin,strSec];
        }
        else
        {
            duration /= 60;
            int hours = duration % 24;
            
            NSString *strHr = nil;
            if(hours < 10)
                strHr = [NSString stringWithFormat:@"0%i",hours];
            else
                strHr = [NSString stringWithFormat:@"%i",hours];
            
            [strDuration appendFormat:@"%@:%@:%@",strHr,strMin,strSec];
        }
    }
    return strDuration;
    
}


- (IBAction)onPlay:(id)sender
{
    NSButton * playBtn = (NSButton*)sender;
    NSInteger currentIndex = [idTableView rowForView:playBtn];
    if( currentIndex < 0  && currentIndex > self.nsMutaryOfDataObject.count)
        return;
    if([self.nsMutaryOfDataObject count] <= currentIndex)
        return;
    
    [idTableView selectRowIndexes:[[NSIndexSet alloc] initWithIndex:currentIndex] byExtendingSelection:false];
    NSDictionary *dict = (NSDictionary*)[self.nsMutaryOfDataObject objectAtIndex:currentIndex];
    if(dict == nil)
        return;
    
    NSString *filepath = (NSString*)[dict objectForKey:FULLPATH];
    if( filepath == NULL || [filepath length] <= 0 )
        return;
    
    NSButton *playButton = (NSButton *)sender;
    NSTableCellView * cell = [idTableView viewAtColumn:0 row:currentIndex makeIfNecessary:false];
   /* if (prevCell != nil && cell != prevCell){
        //stop Slider
        [prevSlider setDoubleValue:0.0];
        [prevSlider setHidden:YES];
        NSButton * btn = [prevCell viewWithTag:0];
        [btn setState:NSControlStateValueOff];
        NSTextField * txt1 = [prevCell viewWithTag:3];
        [txt1 setStringValue:[NSString stringWithFormat:@"%@", [self getDuration_Prev2:player.duration]]];
        if(player != NULL){
            [player stop];
            player = nil;
        }
        
    }*/
    
    prevSlider = [cell viewWithTag:4];
    if([playButton state] == NSControlStateValueOn)
    {
        NSURL *url = [[NSURL alloc] initFileURLWithPath:filepath];
        if (url != nil){
            NSData * data = [[NSData alloc] initWithContentsOfURL:url];
            if (player == nil){
                player = [[AVAudioPlayer alloc] initWithData:data error:NULL];
                [player prepareToPlay];
                [player setDelegate:self];
                
                [prevSlider setMinValue:0];
                [prevSlider setMaxValue:player.duration];
                [prevSlider setDoubleValue:0.0];
            }
            [player play];
        }
        [prevSlider setHidden:NO];
    }
    else if([playButton state] == NSControlStateValueOff)
    {
        //[prevSlider setHidden:YES];
        if (player != nil && [player isPlaying]){
            // [self stopAudioPlay];
            [player pause];
        }
    }
//    /prevCell = cell;
    currentlyInvokedPlayButton = playButton;
}

-(void) stopAudioPlay {
    
    if (player != nil ){
        [player stop];
    }
}





@end
