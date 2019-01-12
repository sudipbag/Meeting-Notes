//
//  MyViewController.h
//  010-NSView
//
#import <Cocoa/Cocoa.h>
//#import "MyPoint.h"
#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

@class Canvas;
@class Brush;

@interface MyViewController : NSView {
	NSMutableArray	* myMutaryOfBrushStrokes;
	NSMutableArray	* myMutaryOfPoints;
    IBOutlet NSColorWell*	drawColorWell; 
    IBOutlet NSColorWell*	drawColorBG; 
    IBOutlet NSSlider *	 thickness;
    IBOutlet NSView *accessoryView;
    IBOutlet NSView *drawView;
    
    IBOutlet NSView *AdvBtn;
    IBOutlet NSView *AdvTool;
    
    IBOutlet NSView *BscBtn;
    IBOutlet NSView *BscTool;
    
    IBOutlet NSWindow * mWindow;
    IBOutlet NSWindow * mStatusHelp;
    
    IBOutlet NSTextField * TextBG;
    IBOutlet NSTextField * TxtColor;
    IBOutlet NSTextField * TxtBG;
    IBOutlet NSSlider *ExportSlider;
    double isTrans;
    BOOL isClear;
    
    IBOutlet NSImageView *mBG;
    
    NSStatusItem *myStatusItem;
	IBOutlet NSMenu *myStatusMenu;
	IBOutlet NSMenuItem *myMenuStatus1;
    IBOutlet NSButton *btnToggleLoginItem;
    
    IBOutlet NSButton *ChlipBoardSaved;
    
    IBOutlet NSImageView *mPointer;
    IBOutlet NSImageView *mPointerLine;
    IBOutlet NSButton *mToolBG;
    
    
    IBOutlet NSTextField *mBGImg;
    
    
    IBOutlet NSButton *erase;
    IBOutlet NSButton *pen;  
    
    IBOutlet NSButton *BtnClose;
    IBOutlet NSButton *BtnSave;
    IBOutlet NSButton *BtnClip;
    IBOutlet NSButton *BtnClear;
    
    IBOutlet NSButton *BtnHideWhenDone;
    IBOutlet NSButton *BtnExpTranparent;
    bool bflag;
    BOOL TouchOver;
    
    BOOL phaseBegan;
    BOOL phaseEnded;
    
    IBOutlet Canvas		*canvas;
	// The brush that we will pass events to
	IBOutlet  Brush		*brush;
    
    IBOutlet NSButton	*checkforClipboard;
    IBOutlet NSButton	*TouchUnActive;
    IBOutlet NSButton *mouseMove;
  
    
    CGFloat WinX1;
    CGFloat WinY1;
    CGFloat WinX2;
    CGFloat WinY2;
    
    CGPoint LastPoint;
    
    IBOutlet NSTextField *lblGoLive;
    IBOutlet NSButton *btnGoLive;
    
}

@property (assign) NSTextView * txtView;
//Paint

-(IBAction) CloseSignIt:(id)sender;
-(IBAction) OpenSignIt:(id)sender;

- (void)setMouseCenter;
- (void)resetMouse;

-(IBAction) setTouchActive:(id)sender;

-(IBAction) setUndo:(id)sender;

-(IBAction) setExpTranparent:(id)sender;
-(IBAction) setHideWhenDone:(id)sender;

//-(IBAction) saveAsImage:(id)sender;
//-(IBAction) clipBoardAction:(id)sender;
-(IBAction)setBackgroundcolor:(id)sender;
-(IBAction) onClear:(id)sender;

-(IBAction) onToolBar:(id)sender;

-(IBAction)setEraserAndPenStatus:(id)sender;

- (NSData*) resizeImage :(NSImage *) imgToResize size :(CGRect) rect;
- (IBAction)makeCenter:(id)sender;
- (IBAction)toggleLoginItem:(id)sender;
- (CGFloat)randVar;
-(IBAction) setChlipHide:(id)sender;
-(IBAction) setTheme:(id)sender;
//-(IBAction) clear:(id)sender;
-(IBAction) Save:(id)sender;
//-(IBAction) OpenColorPanel:(id)sender;
//- (NSCursor *)ringCursorWithDiameter:(float)diameter;	
//- (NSCursor *)customArrowCursor ;
- (IBAction)setLine:(id)sender;
-(IBAction) setData:(id)sender;
-(IBAction) ClipBoardAction:(id)sender;
-(IBAction) ClipBoard:(id)sender;
- (IBAction)GoLive:(id)sender;
-(IBAction)setExpSlider:(id)sender;
-(CGRect)savingFrameSize;
//- (IBAction)setDrawColor:(id)sender;
//- (void) contextEraseLine:(CGContextRef) ctx from:(CGPoint)startPoint to:(CGPoint) endPoint withThickness:(int)thickness;
//- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar;
///- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar;
//- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag;  

-(IBAction)onUndo:(id)sender;
-(IBAction)onRedo:(id)sender;


-(void)openAdvancedPaintwithSize:(CGSize)size;
-(NSImage*)captureImage;

@end
@interface MyViewController (PrivateMethods)
- (void)enableLoginItemWithLoginItemsReference:(LSSharedFileListRef )theLoginItemsRefs ForPath:(NSString *)appPath;
- (void)disableLoginItemWithLoginItemsReference:(LSSharedFileListRef )theLoginItemsRefs ForPath:(NSString *)appPath;
- (BOOL)loginItemExistsWithLoginItemReference:(LSSharedFileListRef)theLoginItemsRefs ForPath:(NSString *)appPath;
@end
