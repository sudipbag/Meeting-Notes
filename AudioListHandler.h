//
//  AudioListHandler.h
//  ToolbarSample
//
//  Created by Judhajit2 on 8/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import <QTKit/QTkit.h>
#import <AVFoundation/AVFoundation.h>

//#import "ImageDisplayCell.h"
//#import "MemoInfoDisplayCell.h"

#import "Sqlite.h"

static Sqlite *sqlite;

@interface AudioListHandler : NSObject <NSTableViewDelegate,NSSoundDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate, NSMenuDelegate>
{
    NSMutableArray * nsMutaryOfDataObject;
	IBOutlet NSTableView * idTableView;
    
    IBOutlet NSWindow *mainWindow;
    
    IBOutlet NSLevelIndicator	*audioLevelMeter;
    IBOutlet NSImageView	*audioLevelMeterBG;
    //QTCaptureMovieFileOutput	*movieFileOutput;
    //QTCaptureSession			*session;
    
    NSTimer						*audioLevelTimer;

    AVAudioRecorder * recorder;
    AVAudioPlayer * player;
    
    NSSlider * prevSlider;

    IBOutlet NSBox *previewBox;
    
    IBOutlet NSWindow *nameAlarmEntryWindow;
    BOOL nameEntryCancelled;
    
    
    IBOutlet NSTextField *lblPreviewName;
    IBOutlet NSTextField *lblPreviewAlarmTime;
    IBOutlet NSTextField *lblPreviewDuration;
    
    IBOutlet NSTextField *lblSave;
    IBOutlet NSTextField *lblPlayEx;
    IBOutlet NSTextField *lblPauseEx;
    IBOutlet NSTextField *lblAppend;
    
    IBOutlet NSTextField *lblSpeedControl;
    
    IBOutlet NSButton *btnSave;
    IBOutlet NSButton *btnPlayEx;
    IBOutlet NSButton *btnPauseEx;
    IBOutlet NSButton *btnAppend;
    
    IBOutlet NSButton *btnPlayPrev;
    IBOutlet NSButton *btnPlayNext;
    
    IBOutlet NSSlider *sliderPlayProgress;
    NSTimer *playMonitorTimer;
  
    IBOutlet NSTextField *elapsedTime;
    IBOutlet NSTextField *remainingTime;
    
    IBOutlet NSSegmentedControl *segPlaySpeedControl;
    NSInteger currentPlaySpeed;
    float currentPlayRate;
    
    IBOutlet NSView *recordingView;
    
    IBOutlet NSTextField *lblRecordingDuration;
    CGFloat floatRecordingDuration;
   // NSTimeInterval timeInterVal;

    IBOutlet NSView *playAndAppendView;
    
    IBOutlet NSTextView *documentTextView;
    IBOutlet NSWindow *saveWin;
    IBOutlet NSTextField *txtAdioFileName;
    IBOutlet NSMenu *editMenu;
    NSString *tempAudioSavePath;
    
}

@property (assign) NSMutableArray * nsMutaryOfDataObject;
@property (assign) NSTableView * idTableView;



- (IBAction)startStopRecording:(id)sender;

-(void)stopAnyRecording;


+(Sqlite *)openDb;
+(void) deleteAudioData:(NSDictionary *)dictMemo ;
+(void) insertIntoDb:(NSDictionary *)dictMemo;
+(void) updateAudioData:(NSDictionary *)dictMemo ;



@end
