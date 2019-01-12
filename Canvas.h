//
//  Canvas.h
//  Paint
//
//  Created by Andy Finnell on 8/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Canvas : NSObject {
	// The canvas is simply backed by a bitmap context. A CGLayerRef would be
	//	better, but you have to know your destination context before you create
	//	it (which we don't).
	IBOutlet CGContextRef	mBitmapContext;
    IBOutlet CGContextRef	mBitmapC;
    CGContextRef	lBitmapContext;
    
    IBOutlet NSTextField *mBGImg;
    IBOutlet NSColorWell*	drawColorBG;
    
    IBOutlet NSButton *erase;
    IBOutlet NSButton *pen;  
    
    IBOutlet NSButton *BtnClose;
    IBOutlet NSButton *BtnSave;
    IBOutlet NSButton *BtnClip;
    IBOutlet NSButton *BtnClear;
    
    IBOutlet NSButton *BscBtnClear;
    IBOutlet NSButton *BscBtnClose;
    IBOutlet NSButton *BscBtnAdv;
    IBOutlet NSButton *BscBtnSave;
    
    BOOL mEraserIsPressed ;
    
}
-(IBAction) setErase:(id)sender;
-(IBAction) setPen:(id)sender;
-(void)setSaveUndo; 
-(void)resetGraphicsContext:(NSGraphicsContext*)context;
// Constructor that creates a canvas at the specified size. Canvas cannot be resized.
- (id) initWithSize:(NSSize)size;
-(IBAction)setClear;
// Draws the contents of the canvas into the specified context. Handy for views
//	that host a canvas.
- (void)drawRect:(NSRect)rect inContext:(NSGraphicsContext*)context;

// Graphics privimites for the canvas. The first draws a line given the brush
//	image, and the second, draws a point given the brush image.
- (CGFloat)stampMask:(CGImageRef)mask from:(NSPoint)startPoint to:(NSPoint)endPoint leftOverDistance:(CGFloat)leftOverDistance;
- (void)stampMask:(CGImageRef)mask at:(NSPoint)point;

-(IBAction)setBackgroundcolor;

-(void)drawRectWhenUndo;
-(void)drawRectWhenRedo;

-(void)setBackupBeforeResize;
-(void)drawRectAfterResize;

-(void)clearUndoRedoData;


@end
