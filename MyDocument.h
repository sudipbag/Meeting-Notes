

#import <Cocoa/Cocoa.h>

#import "MyViewController.h"
#import "AudioListHandler.h"
#import "VEStyle.h"

@interface MyDocument : NSDocument <NSToolbarDelegate> {
@private
    IBOutlet NSTextView 	*documentTextView;	// The textview part of our document.
    IBOutlet NSTextField	*searchFieldOutlet;	// "Template" textfield needed to create our toolbar searchfield item.
    IBOutlet NSToolbarItem	*activeSearchItem;	// A reference to the search field in the toolbar, null if the toolbar doesn't have one!
    IBOutlet NSWindow		*documentWindow;
    IBOutlet NSView		*contentView;

    NSData	*dataFromFile;
    
    NSMutableString *strFileDisplaying;
    IBOutlet NSColorWell *bgColorSelect;
    
    IBOutlet MyViewController *myViewController;
    IBOutlet NSWindow *paintWindow;
    
    IBOutlet NSView *audioPlayToolbarView;
    IBOutlet NSView *audioRecordToolbarView;
    
    BOOL bIsSaving;
    IBOutlet AudioListHandler *audioListHandler;
    IBOutlet NSLayoutConstraint *mainTopLayoutConstraints;
    IBOutlet VEStyle *mainVEStyle;
 
}

@property (assign)  IBOutlet NSLayoutConstraint *rightConstrint;
-(void)setTextViewColors;

-(void)setTextView;
-(IBAction)setTextViewBackColor:(id)sender;

-(IBAction)onDrawCall:(id)sender;
-(IBAction)onDrawDone:(id)sender;
-(IBAction)onCancelDraw:(id)sender;

-(IBAction) openPanel:(id)sender;
- (IBAction)doSearch:(id) sender;
-(IBAction)doSendMail:(id)sender;
-(IBAction)onSetFont:(id)sender;

@end
