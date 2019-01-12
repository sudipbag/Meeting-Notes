//
//  Brush.h
//  Paint
//
//  Created by Andy Finnell on 8/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Canvas;

@interface Brush : NSObject {
	// Information about the brush that's always used
	CGFloat				mRadius;
	CGMutablePathRef	mShape;
	CGColorRef			mColor;
	float				mSoftness; // 0.0 - 1.0, 0.0 being hard, 1.0 be all soft
	BOOL				mHard; // should have a hard edge?
	
	// Cached information that's only used when actually tracking/drawing
	CGImageRef			mMask;
	NSPoint				mLastPoint;
	CGFloat				mLeftOverDistance;
    BOOL                mEraserIsPressed ;
    
    IBOutlet NSColorWell*	drawColor; 
    IBOutlet NSTextField *mBGImg;
    IBOutlet NSSlider *	 thickness;
    
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
    
}
-(IBAction)LoadBrush:(id)sender;
- (void) mouseDown:(NSEvent *)theEvent inView:(NSView *)view onCanvas:(Canvas *)canvas cPoint:(NSPoint)cPoint bFlag:(BOOL)bFlag;
- (void) mouseDragged:(NSEvent *)theEvent inView:(NSView *)view onCanvas:(Canvas *)canvas cPoint:(NSPoint)cPoint bFlag:(BOOL)bFlag;
- (void) mouseUp:(NSEvent *)theEvent inView:(NSView *)view onCanvas:(Canvas *)canvas cPoint:(NSPoint)cPoint bFlag:(BOOL)bFlag;
-(IBAction)setBurshThickness:(id)sender;


- (NSPoint) canvasLocation:(NSEvent *)theEvent view:(NSView *)view;
- (void) stampStart:(NSPoint)startPoint end:(NSPoint)endPoint inView:(NSView *)view onCanvas:(Canvas *)canvas;

//- (CGContextRef) createBitmapContext;
//- (void) disposeBitmapContext:(CGContextRef)bitmapContext;
//- (CGImageRef) createShapeImage;

-(IBAction)setForeGroundColor:(id)sender;
-(IBAction)onEraser:(id)sender;
-(BOOL)getEraseButtonState;

@end
