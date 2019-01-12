
#import "MyDocument.h"
  
static NSString* 	MyDocToolbarIdentifier 		= @"My Document Toolbar Identifier";
static NSString*	SaveDocToolbarItemIdentifier 	= @"Save Document Item Identifier";
static NSString*	SearchDocToolbarItemIdentifier 	= @"Search Document Item Identifier";

static NSString*	AudioPlayToolbarItems = @"AudioToolbars";
static NSString*	AudioRecordToolbarItem = @"AudioRecordToolbarItem";

static NSInteger    countNewDoc = 0;
static NSInteger    indexUntitledLast = 0;

static NSString     *strInitialTitle = nil;

// This class knows how to validate "most" custom views.  Useful for view items we need to validate.
@interface ValidatedViewToolbarItem : NSToolbarItem
@end

@interface MyDocument (Private)
- (void)loadTextViewWithInitialData:(NSData *)data;
- (void)setupToolbar;
- (NSRange)rangeOfEntireDocument;
@end

@implementation MyDocument

- (id)init
{
    return [super init];
}

- (id)initWithType:(NSString *)typeName error:(NSError **)outError
{
    
    NSLog(@"initWithType called");
    //return [super initWithType:typeName error:outError];
    id idSelf = [super initWithType:typeName error:outError];
    [[NSApp delegate] setReadyDocument:idSelf];
    return idSelf;
}

-(id)initWithContentsOfURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError
{
    NSLog(@"initWithContentsOfURL called");
    //return [super initWithType:typeName error:outError];
    id idSelf = [super initWithContentsOfURL:url ofType:typeName error:outError];
    [[NSApp delegate] setReadyDocument:idSelf];
    return idSelf;
}

- (void)dealloc {
    [[NSApp delegate] setReadyDocument:nil];
    [activeSearchItem release];
    activeSearchItem = nil;
    [searchFieldOutlet release];
    searchFieldOutlet = nil;
    [dataFromFile release];
    dataFromFile = nil;
    [strFileDisplaying release];
    strFileDisplaying = nil;
    [super dealloc];
}

-(void)close
{
    [audioListHandler stopAnyRecording];
    if(strFileDisplaying == nil || [strFileDisplaying length] <= 0)
    {
        countNewDoc--;
        if(countNewDoc < 1)
            indexUntitledLast = 0;
    }
    [super close];
}

// ==========================================================
// Standard NSDocument methods
// ==========================================================

- (NSString *)windowNibName {
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController {
    [super windowControllerDidLoadNib:aController];
    
    if (&NSAppearanceNameVibrantDark!=0) {
        
        [mainVEStyle setHidden:NO];
        [mainTopLayoutConstraints setConstant:15];
         aController.window.styleMask =  aController.window.styleMask | NSFullSizeContentViewWindowMask;
         aController.window.titlebarAppearsTransparent = true;
    }else
    {
       [mainVEStyle setHidden:NO];
       [mainTopLayoutConstraints setConstant:0];
        [aController.window setBackgroundColor:[NSColor whiteColor]];
    }
    // The search field outlet may eventually end up in the toolbar hierarchy.  If it does, it will be removed from it's current view hierarchy.
    // We need to retain it ourself to make sure it doesn't go away if it is removed from the toolbar view hierarchy.
    [searchFieldOutlet retain];
    [searchFieldOutlet removeFromSuperview];
    
    [documentWindow makeFirstResponder: documentTextView];
    [documentWindow setFrameUsingName: @"MyDocumentWindow"];
    [documentWindow setFrameAutosaveName: @"MyDocumentWindow"];

    // Do the standard thing of loading in data we may have gotten if loadDataRepresentation: was used.
    if (dataFromFile!=nil) {
        [self loadTextViewWithInitialData: dataFromFile];
        [dataFromFile autorelease];
        dataFromFile = nil;
    }
   
    // Set up the toolbar after the document nib has been loaded 
    //[self setupToolbar];
    [self setTextViewColors];
    [myViewController setTxtView:documentTextView];
    
}


-(void)setTextViewColors
{
    
    //if([[self displayName] isEqualToString:@"Meeting Notes - Untitled"])
    if([self fileURL] == nil)
    {
        if(bgColorSelect != nil)
        {
            //NSColor *colorToSet = [NSColor colorWithCalibratedRed:(254/255) green:(252/255) blue:(191/255) alpha:1.0f];
            //NSColor *colorToSet = [NSColor colorWithCalibratedRed:(0/255) green:(255/255) blue:(0/255) alpha:1.0f];
            //1 0.957593 0.62963 1
            NSColor *colorToSet = [NSColor colorWithCalibratedRed:1.0f green:0.95759f blue:0.62963f alpha:1.0f];
            [bgColorSelect setColor:colorToSet];
            [documentTextView setBackgroundColor:colorToSet];
            [documentTextView setDrawsBackground:YES];
        }
        return;
    }
    
    //NSData *theData = [[NSUserDefaults standardUserDefaults] dataForKey:@"textBackColor"];
    NSData *theData = [[NSUserDefaults standardUserDefaults] dataForKey:[NSString stringWithFormat:@"Meeting Notes - %@",[[self fileURL] path]]];
    if(theData == nil)
    {
        theData = [[NSUserDefaults standardUserDefaults] dataForKey:@"textBackColor"];
    }
    
    NSColor *bgColor = nil;
    if (theData != nil)
        bgColor = (NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
    if(bgColor != nil)
    {
        [bgColorSelect setColor:bgColor];
        [documentTextView setBackgroundColor:bgColor];
    }
    [documentTextView setDrawsBackground:YES];
}



- (NSString *)displayName
{
    if(strInitialTitle == nil)
    {
        strInitialTitle = [[documentWindow title] retain];
    }
    //return @"Sticky Note 1";
    NSString *strDisplay = [strFileDisplaying description];
    if(strDisplay == nil || [strDisplay length] <= 0)
    {
        if([[documentWindow title] isEqualToString:strInitialTitle])
        {
            strDisplay = @"Untitled";
            countNewDoc++;
            indexUntitledLast++;
            
            if(indexUntitledLast > 1)
            {
                strDisplay = [NSString stringWithFormat:@"%@%ld",strDisplay,indexUntitledLast];
            }
        }
        else
        {
            //return [documentWindow title];
            NSString *str = [documentWindow title];
            //if(bIsSaving)
            {
                NSRange r = [str rangeOfString:@"Meeting Notes - "];
                str = [str substringFromIndex:r.length];
            }
            return str;
        }
    }
    return [NSString stringWithFormat:@"Meeting Notes - %@",strDisplay];
}

- (NSData *)dataRepresentationOfType:(NSString *)aType {
    // Archive data in the format loadDocumentWithInitialData expects.
    NSData *dataRepresentation = nil;
    if ([aType isEqual: @"My Document Type"]) {
	dataRepresentation = [documentTextView RTFDFromRange: [self rangeOfEntireDocument]];
    }
    return dataRepresentation;
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType {
    BOOL success = NO;
    if ([aType isEqual: @"My Document Type"]) {
	if (documentTextView!=nil) {
	    [self loadTextViewWithInitialData: data];
	} else {
	    dataFromFile = [data retain];
	}
	success = YES;
    }
    return success;
}

- (void) loadTextViewWithInitialData: (NSData *) data {
    [documentTextView replaceCharactersInRange: [self rangeOfEntireDocument] withRTFD: data];
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
    if(strFileDisplaying == nil)
        strFileDisplaying = [[NSMutableString alloc] init];
    NSString *str = [absoluteURL lastPathComponent];
    NSArray *arr = [str componentsSeparatedByString:@"."];
    [strFileDisplaying setString:[arr objectAtIndex:0]];
    return [super readFromURL:absoluteURL ofType:typeName error:outError];
}

// ============================================================
// NSToolbar Related Methods
// ============================================================

- (void) setupToolbar {
    // Create a new toolbar instance, and attach it to our document window 
    NSToolbar *toolbar = [[[NSToolbar alloc] initWithIdentifier: MyDocToolbarIdentifier] autorelease];
    
    // Set up toolbar properties: Allow customization, give a default display mode, and remember state in user defaults 
    [toolbar setAllowsUserCustomization: YES];
    [toolbar setAutosavesConfiguration: YES];
    [toolbar setDisplayMode: NSToolbarDisplayModeIconOnly];
    
    // We are the delegate
    [toolbar setDelegate: self];
    
    // Attach the toolbar to the document window 
    [documentWindow setToolbar: toolbar];
}


//--------------------------------------------------------------------------------------------------
// Factory method to create autoreleased NSToolbarItems.
//
// All NSToolbarItems have a unique identifer associated with them, used to tell your delegate/controller
// what toolbar items to initialize and return at various points.  Typically, for a given identifier,
// you need to generate a copy of your "master" toolbar item, and return it autoreleased.  The function
// creates an NSToolbarItem with a bunch of NSToolbarItem paramenters.
//
// It's easy to call this function repeatedly to generate lots of NSToolbarItems for your toolbar.
// 
// The label, palettelabel, toolTip, action, and menu can all be nil, depending upon what you want
// the item to do.
//--------------------------------------------------------------------------------------------------
- (NSToolbarItem *)toolbarItemWithIdentifier:(NSString *)identifier
                                       label:(NSString *)label
                                 paleteLabel:(NSString *)paletteLabel
                                     toolTip:(NSString *)toolTip
                                      target:(id)target
                                 itemContent:(id)imageOrView
                                      action:(SEL)action
                                        menu:(NSMenu *)menu
{
    // here we create the NSToolbarItem and setup its attributes in line with the parameters
    NSToolbarItem *item = [[[NSToolbarItem alloc] initWithItemIdentifier:identifier] autorelease];
    
    [item setLabel:label];
    [item setPaletteLabel:paletteLabel];
    [item setToolTip:toolTip];
    [item setTarget:target];
    [item setAction:action];
    
    // Set the right attribute, depending on if we were given an image or a view
    if([imageOrView isKindOfClass:[NSImage class]]){
        [item setImage:imageOrView];
    } else if ([imageOrView isKindOfClass:[NSView class]]){
        [item setView:imageOrView];
    }else {
        assert(!"Invalid itemContent: object");
    }
    
    
    // If this NSToolbarItem is supposed to have a menu "form representation" associated with it
    // (for text-only mode), we set it up here.  Actually, you have to hand an NSMenuItem
    // (not a complete NSMenu) to the toolbar item, so we create a dummy NSMenuItem that has our real
    // menu as a submenu.
    //
    if (menu != nil)
    {
        // we actually need an NSMenuItem here, so we construct one
        NSMenuItem *mItem = [[[NSMenuItem alloc] init] autorelease];
        [mItem setSubmenu:menu];
        [mItem setTitle:label];
        [item setMenuFormRepresentation:mItem];
    }
    
    return item;
}


- (NSToolbarItem *) toolbar: (NSToolbar *)toolbar itemForItemIdentifier: (NSString *) itemIdent willBeInsertedIntoToolbar:(BOOL) willBeInserted {
    
    if ([itemIdent isEqualToString:AudioPlayToolbarItems])
    {
        // 1) Font style toolbar item
        return [self toolbarItemWithIdentifier:AudioPlayToolbarItems
                                                label:@"Font Style"
                                          paleteLabel:@"Font Style"
                                              toolTip:nil
                                               target:self
                                          itemContent:audioPlayToolbarView
                                               action:nil
                                                 menu:nil];
    }  
    else if ([itemIdent isEqualToString:AudioRecordToolbarItem])
    {   
        // 2) Font size toolbar item
        return [self toolbarItemWithIdentifier:AudioRecordToolbarItem
                                                label:@"Font Size"
                                          paleteLabel:@"Font Size"
                                              toolTip:nil
                                               target:self
                                          itemContent:audioRecordToolbarView
                                               action:nil
                                                 menu:nil];
    }
    
    
    // Required delegate method:  Given an item identifier, this method returns an item 
    // The toolbar will use this method to obtain toolbar items that can be displayed in the customization sheet, or in the toolbar itself 
    NSToolbarItem *toolbarItem = nil;
    
    if ([itemIdent isEqual: SaveDocToolbarItemIdentifier]) {
        toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent] autorelease];
	
        // Set the text label to be displayed in the toolbar and customization palette 
	[toolbarItem setLabel: @"Save"];
	[toolbarItem setPaletteLabel: @"Save"];
	
	// Set up a reasonable tooltip, and image   Note, these aren't localized, but you will likely want to localize many of the item's properties 
	[toolbarItem setToolTip: @"Save Your Document"];
	[toolbarItem setImage: [NSImage imageNamed: @"SaveDocumentItemImage"]];
	
	// Tell the item what message to send when it is clicked 
	[toolbarItem setTarget: self];
	[toolbarItem setAction: @selector(saveDocument:)];
    } else if([itemIdent isEqual: SearchDocToolbarItemIdentifier]) {
        // NSToolbarItem doens't normally autovalidate items that hold custom views, but we want this guy to be disabled when there is no text to search.
        toolbarItem = [[[ValidatedViewToolbarItem alloc] initWithItemIdentifier: itemIdent] autorelease];

	NSMenu *submenu = nil;
	NSMenuItem *submenuItem = nil, *menuFormRep = nil;
	
	// Set up the standard properties 
	[toolbarItem setLabel: @"Search"];
	[toolbarItem setPaletteLabel: @"Search"];
	[toolbarItem setToolTip: @"Search Your Document"];
	
        //searchFieldOutlet = [[NSSearchField alloc] initWithFrame:[searchFieldOutlet frame]];
	// Use a custom view, a text field, for the search item 
	[toolbarItem setView: searchFieldOutlet];
	[toolbarItem setMinSize:NSMakeSize(100, NSHeight([searchFieldOutlet frame]))];
	[toolbarItem setMaxSize:NSMakeSize(400,NSHeight([searchFieldOutlet frame]))];

	// By default, in text only mode, a custom items label will be shown as disabled text, but you can provide a 
	// custom menu of your own by using <item> setMenuFormRepresentation] 
	submenu = [[[NSMenu alloc] init] autorelease];
	submenuItem = [[[NSMenuItem alloc] initWithTitle: @"Search Panel" action: @selector(searchUsingSearchPanel:) keyEquivalent: @""] autorelease];
	menuFormRep = [[[NSMenuItem alloc] init] autorelease];

	[submenu addItem: submenuItem];
	[submenuItem setTarget: self];
	[menuFormRep setSubmenu: submenu];
	[menuFormRep setTitle: [toolbarItem label]];

        // Normally, a menuFormRep with a submenu should just act like a pull down.  However, in 10.4 and later, the menuFormRep can have its own target / action.  If it does, on click and hold (or if the user clicks and drags down), the submenu will appear.  However, on just a click, the menuFormRep will fire its own action.
        [menuFormRep setTarget: self];
        [menuFormRep setAction: @selector(searchMenuFormRepresentationClicked:)];

        // Please note, from a user experience perspective, you wouldn't set up your search field and menuFormRep like we do here.  This is simply an example which shows you all of the features you could use.
	[toolbarItem setMenuFormRepresentation: menuFormRep];
    } else {
	// itemIdent refered to a toolbar item that is not provide or supported by us or cocoa 
	// Returning nil will inform the toolbar this kind of item is not supported 
	toolbarItem = nil;
    }
    return toolbarItem;
}

- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar {
    // Required delegate method:  Returns the ordered list of items to be shown in the toolbar by default    
    // If during the toolbar's initialization, no overriding values are found in the user defaults, or if the
    // user chooses to revert to the default items this set will be used 
    return [NSArray arrayWithObjects:	SaveDocToolbarItemIdentifier, NSToolbarPrintItemIdentifier, NSToolbarSeparatorItemIdentifier, 
					NSToolbarShowColorsItemIdentifier, NSToolbarShowFontsItemIdentifier, NSToolbarFlexibleSpaceItemIdentifier, 
					NSToolbarSpaceItemIdentifier,AudioRecordToolbarItem,AudioPlayToolbarItems, SearchDocToolbarItemIdentifier, nil];
}

- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar {
    // Required delegate method:  Returns the list of all allowed items by identifier.  By default, the toolbar 
    // does not assume any items are allowed, even the separator.  So, every allowed item must be explicitly listed   
    // The set of allowed items is used to construct the customization palette 
    return [NSArray arrayWithObjects: 	SearchDocToolbarItemIdentifier, SaveDocToolbarItemIdentifier,AudioPlayToolbarItems,
                    AudioRecordToolbarItem, NSToolbarPrintItemIdentifier, 
					NSToolbarShowColorsItemIdentifier, NSToolbarShowFontsItemIdentifier, NSToolbarCustomizeToolbarItemIdentifier,
					NSToolbarFlexibleSpaceItemIdentifier, NSToolbarSpaceItemIdentifier, NSToolbarSeparatorItemIdentifier, nil];
}

- (void) toolbarWillAddItem: (NSNotification *) notif {
    // Optional delegate method:  Before an new item is added to the toolbar, this notification is posted.
    // This is the best place to notice a new item is going into the toolbar.  For instance, if you need to 
    // cache a reference to the toolbar item or need to set up some initial state, this is the best place 
    // to do it.  The notification object is the toolbar to which the item is being added.  The item being 
    // added is found by referencing the @"item" key in the userInfo 
    NSToolbarItem *addedItem = [[notif userInfo] objectForKey: @"item"];
    if([[addedItem itemIdentifier] isEqual: SearchDocToolbarItemIdentifier]) {
	activeSearchItem = [addedItem retain];
	[activeSearchItem setTarget: self];
	[activeSearchItem setAction: @selector(searchUsingToolbarSearchField:)];
    } else if ([[addedItem itemIdentifier] isEqual: NSToolbarPrintItemIdentifier]) {
	[addedItem setToolTip: @"Print Your Document"];
	[addedItem setTarget: self];
    }
}  

- (void) toolbarDidRemoveItem: (NSNotification *) notif {
    // Optional delegate method:  After an item is removed from a toolbar, this notification is sent.   This allows 
    // the chance to tear down information related to the item that may have been cached.   The notification object
    // is the toolbar from which the item is being removed.  The item being added is found by referencing the @"item"
    // key in the userInfo 
    NSToolbarItem *removedItem = [[notif userInfo] objectForKey: @"item"];
    if (removedItem==activeSearchItem) {
	[activeSearchItem autorelease];
	activeSearchItem = nil;    
    }
}

- (BOOL) validateToolbarItem: (NSToolbarItem *) toolbarItem {
    // Optional method:  This message is sent to us since we are the target of some toolbar item actions 
    // (for example:  of the save items action) 
    BOOL enable = NO;
    if ([[toolbarItem itemIdentifier] isEqual: SaveDocToolbarItemIdentifier]) {
	// We will return YES (ie  the button is enabled) only when the document is dirty and needs saving 
	enable = [self isDocumentEdited];
    } else if ([[toolbarItem itemIdentifier] isEqual: NSToolbarPrintItemIdentifier]) {
	enable = YES;
    } else if ([[toolbarItem itemIdentifier] isEqual: SearchDocToolbarItemIdentifier]) {
	enable = [[[documentTextView textStorage] string] length]>0;
    }	
    return enable;
}

- (BOOL) validateMenuItem: (NSMenuItem *) item {
    BOOL enabled = YES;
    
    if ([item action]==@selector(searchMenuFormRepresentationClicked:) || [item action]==@selector(searchUsingSearchPanel:)) {
        enabled = [self validateToolbarItem: activeSearchItem];
    }

    return enabled;
}

// ============================================================
// Utility Methods : Misc, and Target/Actions Methods
// ============================================================

- (NSRange) rangeOfEntireDocument {
    // Convenience method: Compute and return the range that encompasses the entire document 
    NSInteger length = 0;
    if ([documentTextView string]!=nil) {
	length = [[documentTextView string] length];
    }
    return NSMakeRange(0,length);
}

- (void) printDocument:(id) sender {
    // This message is send by the print toolbar item 
    NSPrintOperation *printOperation = [NSPrintOperation printOperationWithView: documentTextView];
    [printOperation runOperationModalForWindow: documentWindow delegate: nil didRunSelector: NULL contextInfo: NULL];
}

- (NSArray *)rangesOfStringInDocument:(NSString *)searchString {
    NSString *string = [[documentTextView textStorage] string];
    NSMutableArray *ranges = [NSMutableArray array];
    
    NSRange thisCharRange, searchCharRange;
    searchCharRange = NSMakeRange(0, [string length]);
    while (searchCharRange.length>0) {
        thisCharRange = [string rangeOfString:searchString options:0 range:searchCharRange];
        if (thisCharRange.length>0) {
            searchCharRange.location = NSMaxRange(thisCharRange);
            searchCharRange.length = [string length] - NSMaxRange(thisCharRange);
            [ranges addObject: [NSValue valueWithRange:thisCharRange]];
        } else {
            searchCharRange = NSMakeRange(NSNotFound, 0);
        }
    }
    return ranges;
}

- (void) searchUsingToolbarSearchField:(id) sender {
    // This message is sent when the user strikes return in the search field in the toolbar 
    NSString *searchString = [(NSTextField *)[activeSearchItem view] stringValue];
    NSArray *rangesOfString = [self rangesOfStringInDocument:searchString];
    if ([rangesOfString count]) {
        if ([documentTextView respondsToSelector:@selector(setSelectedRanges:)]) {
            // NSTextView can handle multiple selections in 10.4 and later.
            [documentTextView setSelectedRanges: rangesOfString];
        } else {
            // If we can't do multiple selection, just select the first range.
            [documentTextView setSelectedRange: [[rangesOfString objectAtIndex:0] rangeValue]];
        }
    }
}

- (IBAction)doSearch:(id) sender {
    // This message is sent when the user strikes return in the search field in the toolbar 
    NSString *searchString = [(NSTextField *)sender stringValue];
    NSArray *rangesOfString = [self rangesOfStringInDocument:searchString];
    if ([rangesOfString count]) {
        if ([documentTextView respondsToSelector:@selector(setSelectedRanges:)]) {
            // NSTextView can handle multiple selections in 10.4 and later.
            [documentTextView setSelectedRanges: rangesOfString];
        } else {
            // If we can't do multiple selection, just select the first range.
            [documentTextView setSelectedRange: [[rangesOfString objectAtIndex:0] rangeValue]];
        }
    }
}


- (void) searchMenuFormRepresentationClicked:(id) sender {
    [[documentWindow toolbar] setDisplayMode: NSToolbarDisplayModeIconOnly];
    [documentWindow makeFirstResponder:[activeSearchItem view]];
}

- (void) searchUsingSearchPanel:(id) sender {
    // This message is sent from the search items custom menu representation 
    NSBeginInformationalAlertSheet ( @"searchUsingSearchPanel is not implemented (left as an exercise to the reader   )",@"",@"",@"",documentWindow,nil,nil,nil,nil,@"");
}





-(IBAction)setTextViewFontColor:(id)sender
{
    
    NSLog(@"setTextViewFontColor");
    NSColorPanel *panel = [NSColorPanel sharedColorPanel ] ;
    [ panel setColor: [[documentTextView typingAttributes] objectForKey:NSForegroundColorAttributeName] ];
    [ panel setContinuous: YES ];
    [ panel setTarget: self ]; //myColor
    [ panel setAction: @selector( changeTextColor:) ];
    [ panel makeKeyAndOrderFront: nil ];
    [documentTextView setUsesFontPanel:YES];
    
}

-(void)changeTextColor:(NSColorPanel*)panel
{
    NSColor  *color = [panel color];
    [documentTextView setTypingAttributes:[NSDictionary dictionaryWithObjectsAndKeys:color,NSForegroundColorAttributeName, nil]];
}


-(IBAction)setTextViewBackColor:(id)sender
{
    /*
     NSColor  *color = [bgColorSelect color];
     
     [documentTextView setBackgroundColor:color];
     [documentTextView setDrawsBackground:YES];
     NSData *theData=[NSArchiver archivedDataWithRootObject:color];
     [[NSUserDefaults standardUserDefaults] setObject:theData forKey:@"textBackColor"];
     [[NSUserDefaults standardUserDefaults] synchronize];
     */
    
    [documentTextView setUsesFontPanel:NO];
    NSLog(@"setTextViewBackColor");
    
    NSColorPanel *panel = [NSColorPanel sharedColorPanel ] ;
    [ panel setColor: [bgColorSelect color] ];
    [ panel setContinuous: YES ];
    [ panel setTarget: self ]; //myColor
    [ panel setAction: @selector( changeBackGroundColor:) ];
    [ panel makeKeyAndOrderFront: nil ];
}

-(void)changeBackGroundColor:(NSColorPanel*)panel
{
    NSColor  *color = [panel color];
    
    [documentTextView setBackgroundColor:color];
    [documentTextView setDrawsBackground:YES];
    [bgColorSelect setColor:color];
    NSData *theData=[NSArchiver archivedDataWithRootObject:color];
    [[NSUserDefaults standardUserDefaults] setObject:theData forKey:@"textBackColor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


-(IBAction)onSetFont:(id)sender
{
    [documentTextView setUsesFontPanel:YES];
    [[NSFontManager sharedFontManager] orderFrontFontPanel:sender];
}



-(void)sheetdidend:(NSWindow*)sheet returnCode:(int)code contextInfo:(void*)info
{
    [sheet orderOut:self];
}

// Draw and paste in TextArea

-(IBAction)onDrawCall:(id)sender
{
    //[myViewController openAdvancedPaintwithSize:[documentTextView frame].size];
    CGSize size = CGSizeMake([documentTextView frame].size.width, [documentTextView frame].size.height);
    size.height = size.height <= 400 ? size.height : 400; 
    [myViewController openAdvancedPaintwithSize:size];
    [NSApp beginSheet:paintWindow modalForWindow:documentWindow modalDelegate:self didEndSelector:@selector(sheetdidend:returnCode:contextInfo:) contextInfo:nil];
    //[myViewController openAdvancedPaintwithSize:[contentView frame].size];
}

-(IBAction)onDrawDone:(id)sender
{
    //[myViewController ClipBoardAction:nil];
    [myViewController ClipBoard:nil];
    [NSApp endSheet:paintWindow];
    CGAssociateMouseAndMouseCursorPosition(true);
}

-(IBAction)onCancelDraw:(id)sender
{
    [myViewController onClear:nil];
    [NSApp endSheet:paintWindow];
    CGAssociateMouseAndMouseCursorPosition(true);
}

// End draw and paste in TextArea

// Inserting Image into TextArea from browsing

- (BOOL)application12:(NSApplication *)app openFile:(NSString *)filename{
    
    if(!filename){ 
        NSLog(@"No path selected, return..."); 
    }
    
    NSImage *img =[[NSImage alloc] initWithContentsOfFile:filename];
    if(img == nil)
        return NO;
    if(img != nil)
    {
        NSData * representation = [img TIFFRepresentation];
        
        NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];// dataForType:NSPNGFileType];
        [pasteBoard declareTypes:[NSArray arrayWithObjects:NSTIFFPboardType, nil] owner:nil];
        [pasteBoard setData:representation forType:NSTIFFPboardType]; 
    }
    
    NSAppleScript *start1 = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to set frontApp to name of application processes whose frontmost is true"];
    
	NSAppleEventDescriptor *count = [start1 executeAndReturnError:nil];
    
    NSString * PasteDoc = [count description];
    NSLog(@"NSAppleEventDescriptor  %@", PasteDoc);
    
    
    if(PasteDoc != NULL)
    {
        NSArray *iArr = [PasteDoc componentsSeparatedByString:@"'(\""];
        
        NSLog(@"City Name - %@",[iArr objectAtIndex:1]);
        
        NSArray *iArr1 = [[iArr objectAtIndex:1] componentsSeparatedByString:@"\")"];
        
        
        NSLog(@"City Name - %@",[iArr1 objectAtIndex:0]);
        
        //NSString *AString = [NSString stringWithFormat:@"tell application \"%@\" delay 0.2 \n keystroke \"v\" using (command down) \n end tell", [iArr1 objectAtIndex:0]];
        
        //activate application "TextEdit"
        //tell application "System Events"
        // keystroke "v" using {command down}
        //end tell
        NSString *AString = [NSString stringWithFormat:@"activate application \"%@\" \n tell application \"System Events\" \n keystroke \"v\" using (command down) \n end tell", [iArr1 objectAtIndex:0]];
        
        //delay 0.2 
        
        NSAppleScript *start = [[NSAppleScript alloc] initWithSource:AString]; 
        
        [start executeAndReturnError:nil];
        [start release];
    }
    
    [start1 release];
    
    [img release];
    
    [[[documentTextView window] windowController] setDocumentEdited:YES];
    
    return NO;
}

- (BOOL)application:(NSApplication *)app openFile:(NSString *)filename
{
    if(!filename){ 
        NSLog(@"No path selected, return..."); 
    }
    
    NSImage *img =[[NSImage alloc] initWithContentsOfFile:filename];
    if(img == nil)
        return NO;
    if(img != nil)
    {
        NSData * representation = [img TIFFRepresentation];
        
        NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];// dataForType:NSPNGFileType];
        [pasteBoard declareTypes:[NSArray arrayWithObjects:NSTIFFPboardType, nil] owner:nil];
        [pasteBoard setData:representation forType:NSTIFFPboardType];
        NSString *AString = @"activate application \"Meeting Notes\" \n tell application \"System Events\" \n keystroke \"v\" using (command down) \n end tell";
        NSAppleScript *start = [[NSAppleScript alloc] initWithSource:AString]; 
        
        [start executeAndReturnError:nil];
        [start release];
    }
    [img release];
    return NO;
}


-(IBAction) openPanel:(id)sender
{
    
    NSOpenPanel *panel;
    // [self delaySetPaintBG];
    panel = [NSOpenPanel openPanel];        
    [panel setFloatingPanel:YES];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:YES];
    
    [panel beginSheetModalForWindow:documentWindow completionHandler:^(NSInteger result) {
        if (result == NSOKButton) {
            [panel orderOut:self]; // close panel before we might present an error
            [self application:NSApp openFile:[[panel URL] path]];
            
        }
    }];
    
    return ;
    
}


-(NSString*)getAppleScriptCmdForAttahment
{
    NSAttributedString *strAttr = [documentTextView textStorage];
    NSRange range = NSMakeRange(0, [[documentTextView textStorage] length]);
    NSFileWrapper *fwr = [strAttr fileWrapperFromRange:range documentAttributes:[NSDictionary dictionaryWithObjectsAndKeys:NSRTFDTextDocumentType,NSDocumentTypeDocumentAttribute, nil] error:nil];
    //NSLog(@"File wrappers :: %@",[[fwr fileWrappers] description]);
    NSDictionary *dict = [fwr fileWrappers];
    
    //Voice Memo - 20110928190900.mp3;
    NSEnumerator *enumerator = [dict keyEnumerator];
    id key;
    
    NSMutableString *strAttachmentCmds = nil;
    
    NSArray *paths =   NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    
	//NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);//for document directory
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *audioFolderPath = [documentsDirectory stringByAppendingPathComponent:@"/MeetingNotesDetails/Voice"];
    audioFolderPath = [audioFolderPath stringByExpandingTildeInPath];
    
    
    while ((key = [enumerator nextObject])) {
        if(key == nil)
            continue;
        
        if([key hasSuffix:@".mp3"])
        {
            //NSFileWrapper *fwr1 = [dict objectForKey:key];
            
            NSString *strAttachFileCmd = [NSString stringWithFormat:@" tell content of theMessage\n"
                                          @" make new attachment with properties {file name:\"%@\"} at after last paragraph \n"
                                          @"end tell\n",[NSString stringWithFormat:@"%@/%@",audioFolderPath,key]];
            
            if(strAttachmentCmds == nil)
                strAttachmentCmds = [[[NSMutableString alloc] init] autorelease];
            
            [strAttachmentCmds appendString:strAttachFileCmd];
        }
    }
    
    return strAttachmentCmds;
}


-(void)delayIssuePasteCommand
{
    //NSString *A2String = @"activate application \"Mail\" \n tell application \"System Events\" \n keystroke \"v\" using (command down) \n end tell";
    //NSString *A2String = @"tell application \"System Events\" \n keystroke \"v\" using (command down) \n end tell";
    
    NSString *A2String = @"tell application \"System Events\" \n"
    @"tell process \"Mail\" \n"
    @"keystroke tab \n"
    @"keystroke tab \n"
    @"keystroke tab \n"
    @"keystroke tab \n"
    @"keystroke (ASCII character 31) using (command down) \n"
    @"keystroke return \n"
    @"keystroke \"v\" using (command down) \n end tell \n"
    @" end tell \n";
    
    NSAppleScript *appPasteCmd = [[NSAppleScript alloc] initWithSource:A2String]; 
    [appPasteCmd executeAndReturnError:nil];
    [appPasteCmd release];
}



-(void)issuePasteCommandNew
{
    //NSString *A2String = @"activate application \"Mail\" \n tell application \"System Events\" \n keystroke \"v\" using (command down) \n end tell";
    //NSString *A2String = @"tell application \"System Events\" \n keystroke \"v\" using (command down) \n end tell";
    
    NSString *A2String = @"activate application \"Mail\" \n tell application \"System Events\" \n"
    @"tell process \"Mail\" \n"
    @"keystroke tab \n"
    @"keystroke tab \n"
    @"keystroke tab \n"
    @"keystroke tab \n"
    @"keystroke \"v\" using (command down) \n end tell \n"
    @" end tell \n";
    
    NSAppleScript *appPasteCmd = [[NSAppleScript alloc] initWithSource:A2String]; 
    [appPasteCmd executeAndReturnError:nil];
    [appPasteCmd release];
}




-(IBAction)doSendMail1:(id)sender
{
    
    /*
    [documentTextView setSelectedRange: NSMakeRange(0, [[documentTextView textStorage] length]) ];
    NSString *AString = @"activate application \"Meeting Notes\" \n tell application \"System Events\" \n keystroke \"c\" using (command down) \n end tell";
    NSAppleScript *appCopyCmd = [[NSAppleScript alloc] initWithSource:AString]; 
    [appCopyCmd executeAndReturnError:nil];
    [appCopyCmd release];
     */
    
    NSRange range = NSMakeRange(0, [[documentTextView textStorage] length]);
    NSData *data = [documentTextView RTFDFromRange:range];
    
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];// dataForType:NSPNGFileType];   
    [pasteBoard declareTypes:[NSArray arrayWithObjects:NSRTFDPboardType, nil] owner:nil];
    [pasteBoard setData:data forType:NSRTFDPboardType];
    
    
    
    NSString *strAttachmentCmds = [self getAppleScriptCmdForAttahment];
    
    
    
    NSString *strSubject= @"Meeting Notes by iLifeTouch";    
    
    NSString *strScriptCommand = [NSString stringWithFormat:
                                  @" set theSubject to \"%@\"\n"
                                  @" set theContent to \"\"\n"
                                  @" tell application \"Mail\"\n"
                                  
                                  @" set theMessage to make new outgoing message with properties {subject:theSubject, content:theContent, visible:true} \n"
                                  
                                  @" activate \n"
                                  @"end tell",strSubject];
    
    
    if(strAttachmentCmds != nil)
    {
        strScriptCommand = [NSString stringWithFormat:
                            @" set theSubject to \"%@\"\n"
                            @" set theContent to \"\"\n"
                            @" tell application \"Mail\"\n"
                            
                            @" set theMessage to make new outgoing message with properties {subject:theSubject, content:theContent, visible:true} \n"
                            
                            @"%@ \n\n"
                            
                            @" activate \n"
                            @"end tell",strSubject,strAttachmentCmds];
    }
    
    
    NSLog(@"%@",strScriptCommand);
    
    NSAppleScript *appleScript = [[[NSAppleScript alloc] initWithSource:strScriptCommand] autorelease];
    NSDictionary *errDict = nil;
    if (![appleScript executeAndReturnError:&errDict]) {
        NSLog(@"%@",[appleScript description]); 
    }
    
    //[self performSelector:@selector(delayIssuePasteCommand) withObject:nil afterDelay:2.0f];
    //[self delayIssuePasteCommand];
    
    [documentTextView setSelectedRange: NSMakeRange(0, 0) ];
    [self performSelector:@selector(delayIssuePasteCommand) withObject:nil afterDelay:3.0f];
     
}


-(NSArray*)getAudioURLs
{
    NSMutableArray * marrURLs = [[[NSMutableArray alloc] init] autorelease];
    
    NSAttributedString *strAttr = [documentTextView textStorage];
    NSRange range = NSMakeRange(0, [[documentTextView textStorage] length]);
    NSFileWrapper *fwr = [strAttr fileWrapperFromRange:range documentAttributes:[NSDictionary dictionaryWithObjectsAndKeys:NSRTFDTextDocumentType,NSDocumentTypeDocumentAttribute, nil] error:nil];
    //NSLog(@"File wrappers :: %@",[[fwr fileWrappers] description]);
    NSDictionary *dict = [fwr fileWrappers];
    
    //Voice Memo - 20110928190900.mp3;
    NSEnumerator *enumerator = [dict keyEnumerator];
    id key;
    
    NSMutableString *strAttachmentCmds = nil;
    
    NSArray *paths =   NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);//for document directory
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *audioFolderPath = [documentsDirectory stringByAppendingPathComponent:@"/MeetingNotesDetails/Voice"];
    audioFolderPath = [audioFolderPath stringByExpandingTildeInPath];
    
    
    while ((key = [enumerator nextObject])) {
        if(key == nil)
            continue;
        
        if([key hasSuffix:@".mp3"])
        {

            
            [marrURLs addObject:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",audioFolderPath,key]]];
        }
    }
    
    return marrURLs;
}



-(IBAction)doSendMail:(id)sender
{
    NSSharingService* mailShare = [NSSharingService sharingServiceNamed:NSSharingServiceNameComposeEmail];
    NSRange range = NSMakeRange(0, [[documentTextView textStorage] length]);
    NSData *data = [documentTextView RTFDFromRange:range];
    
    NSMutableAttributedString *attr = [[[NSMutableAttributedString alloc] initWithRTFD:data documentAttributes:NULL] autorelease];

    NSArray *arrURLs = [self getAudioURLs];
    NSMutableArray *shareItems = [NSMutableArray array];
    if([arrURLs count] > 0)
    {
        [shareItems addObjectsFromArray:arrURLs];
    }
    [shareItems addObject:attr];
    [mailShare performWithItems:shareItems];
}

-(void)saveDocument:(id)sender
{
    bIsSaving = YES;
    [super saveDocument:sender];
    bIsSaving = NO;
}

-(BOOL)saveToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation error:(NSError **)outError
{
    [super saveToURL:url ofType:typeName forSaveOperation:saveOperation error:outError];
}


- (void)saveToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation completionHandler:(void (^)(NSError *errorOrNil))completionHandler
{
    [super saveToURL:url ofType:typeName forSaveOperation:saveOperation completionHandler:completionHandler];
    
    //NSLog(@"Path is : %@",[url path]);
    
    NSString *strAudioKey = [NSString stringWithFormat:@"Audio Path - %@",[url path]];
    
    NSMutableArray * arrAudio = audioListHandler.nsMutaryOfDataObject;
    if ([arrAudio  count] > 0){
        NSMutableArray * arrAudioPath = [NSMutableArray new];
        for(int i= 0 ; i < [arrAudio count] ; i++)
        {
            NSDictionary * dict = [arrAudio objectAtIndex:i];
            if (dict != nil){
                NSString * strFullPath = [dict valueForKey:@"FULLPATH"];
                [arrAudio addObject:strFullPath];
            }
        }
    }

    
    NSString *strKey = [NSString stringWithFormat:@"Meeting Notes - %@",[url path]];
    
    NSColor  *color = [bgColorSelect color];
    
    NSData *theData=[NSArchiver archivedDataWithRootObject:color];
    [[NSUserDefaults standardUserDefaults] setObject:theData forKey:strKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if(strFileDisplaying == nil || [strFileDisplaying length] <= 0)
    {
        countNewDoc--;
        if(countNewDoc < 1)
            indexUntitledLast = 0;
    }
    
    if(strFileDisplaying == nil)
        strFileDisplaying = [[NSMutableString alloc] init];
    
    NSString *strFileName = [[url path] lastPathComponent];
    NSArray *arr = [strFileName componentsSeparatedByString:@"."];
    [strFileDisplaying setString:[arr objectAtIndex:0]];
    
    [documentWindow setTitle:[NSString stringWithFormat:@"Meeting Notes - %@",strFileDisplaying]];
    bIsSaving = NO;
    
}




@end

@implementation ValidatedViewToolbarItem

- (void)validate {
    [super validate]; // Let super take care of validating the menuFormRep, etc.

    if ([[self view] isKindOfClass:[NSControl class]]) {
        NSControl *control = (NSControl *)[self view];
        id target = [control target];
        SEL action = [control action];
        
        if ([target respondsToSelector:action]) {
            BOOL enable = YES;
            if ([target respondsToSelector:@selector(validateToolbarItem:)]) {
                enable = [target validateToolbarItem:self];
            }
            [self setEnabled:enable];
            [control setEnabled:enable];
        }
    }
}

@end
