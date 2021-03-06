//
//  TriviaOutlineViewController.m
//  TriviaOutlineView
//
//  Created by Nur Monson on 1/18/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "TriviaOutlineViewController.h"


/* Heriarchy:
 * Board/round
 * - Categories (5)
 * -- Questions (5)
 */

@implementation TriviaOutlineViewController

#define TriviaOutlinePboardType @"TriviaOutlinePboardType"

- (id)init
{
	if( (self = [super init]) ) {
		NSError *anError;
		theQuestionDoc = [[TriviaQuestionDocument alloc] initWithType:@"TriviaDocumentTest" error:&anError];

		[self addBoard:self];
		
		checkedoutBoard = nil;
	}

	return self;
}

- (void)dealloc
{
	//[boards release];
	[theQuestionDoc release];

	[super dealloc];
}

- (void)selectTabForItem:(id)anItem
{
	NSString *tabViewItemID = nil;
	
	if( [anItem isKindOfClass:[TriviaBoard class]] ) {
		tabViewItemID = @"board";
		[self setCurrentBoard:anItem];
	} else if( [anItem isKindOfClass:[TriviaCategory class]] ) {
		tabViewItemID = @"category";
		[self setCurrentCategory:anItem];
	} else {
		tabViewItemID = @"question";
		[self setCurrentQuestion:anItem];
	}
	
	[theTabView selectTabViewItemWithIdentifier:tabViewItemID];
}

- (void)awakeFromNib
{
	NSTableColumn *nameColumn = [theOutlineView tableColumnWithIdentifier:@"NameColumn"];
	ButtonTextCell *newCell = [[[ButtonTextCell alloc] init] autorelease];
	[newCell setEditable:YES];
	[newCell setTarget:self];
	[newCell setAction:@selector(addItem:)];
	[nameColumn setDataCell:newCell];
	
	id aSelectedItem = [theOutlineView itemAtRow:[theOutlineView selectedRow]];
	[self selectTabForItem:aSelectedItem];
	
	NSDictionary *bindingOptions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSContinuouslyUpdatesValueBindingOption,nil];
	[theQuestionView bind:@"question" toObject:theQuestionController withKeyPath:@"selection.question" options:bindingOptions];
	
	[theOutlineView registerForDraggedTypes:[NSArray arrayWithObject:TriviaOutlinePboardType]];

	[[triviaWindowController window] setTitle:[NSString stringWithFormat:@"Host (%@)",[theQuestionDoc displayName]]];
}

#pragma mark Acessor Methods

- (TriviaBoard *)currentBoard
{
	return currentBoard;
}
- (void)setCurrentBoard:(TriviaBoard *)newBoard
{	
	if( newBoard != nil ) {
		[self setCurrentCategory:nil];
		[self setCurrentQuestion:nil];
		
		[newBoard addObserver:self forKeyPath:@"anyPropertyChanged" options:NSKeyValueObservingOptionNew context:NULL];
	}
	
	if( currentBoard != nil )
		[currentBoard removeObserver:self forKeyPath:@"anyPropertyChanged"];

	currentBoard = newBoard;
}

- (TriviaCategory *)currentCategory
{
	return currentCategory;
}
- (void)setCurrentCategory:(TriviaCategory *)newCategory
{	
	if( newCategory != nil ) {
		[self setCurrentBoard:nil];
		[self setCurrentQuestion:nil];
		
		[newCategory addObserver:self forKeyPath:@"anyPropertyChanged" options:NSKeyValueObservingOptionNew context:NULL];
	}
	
	if( currentCategory != nil )
		[currentCategory removeObserver:self forKeyPath:@"anyPropertyChanged"];
	currentCategory = newCategory;
}

- (TriviaQuestion *)currentQuestion
{
	return currentQuestion;
}
- (void)setCurrentQuestion:(TriviaQuestion *)newQuestion
{	
	if( newQuestion != nil ) {
		[self setCurrentBoard:nil];
		[self setCurrentCategory:nil];
		
		[newQuestion addObserver:self forKeyPath:@"anyPropertyChanged" options:NSKeyValueObservingOptionNew context:NULL];
	}

	if( currentQuestion != nil )
		[currentQuestion removeObserver:self forKeyPath:@"anyPropertyChanged"];
	currentQuestion = newQuestion;
}

#pragma mark Actions

- (IBAction)addBoard:(id)sender
{
	
	TriviaBoard *newBoard = [[TriviaBoard alloc] init];
	[newBoard setTitle:[NSString stringWithFormat:@"Round %d",(int)[[theQuestionDoc boards] count]+1]];
	TriviaCategory *newCategory = [[TriviaCategory alloc] init];
	[newCategory setTitle:@"New Category"];

	[newBoard addCategory:newCategory];
	[theQuestionDoc addBoard:newBoard];
	
	[newCategory release];
	[newBoard release];
	
	[theOutlineView reloadData];
	id selectedItem = [theOutlineView itemAtRow:[theOutlineView selectedRow]];
	[self selectTabForItem:selectedItem];
}

- (IBAction)addCategory:(id)sender
{
	TriviaCategory *newCategory = [[TriviaCategory alloc] init];
	TriviaBoard *aBoard = [[theQuestionDoc boards] objectAtIndex:0];
	if( [aBoard isFull] ) {
		NSBeep();
		return;
	}
	[aBoard addCategory:newCategory];
	[newCategory release];
	
	[theOutlineView reloadData];
}

- (IBAction)addItem:(id)sender
{
	id item = [theOutlineView itemAtRow:[theOutlineView selectedRow]];
	
	if( [item isKindOfClass:[TriviaBoard class]] ) {
		TriviaCategory *newCategory = [[TriviaCategory alloc] init];
		[(TriviaBoard *)item addCategory:newCategory];
		[newCategory release];
		
		[theOutlineView reloadData];
		if( ![theOutlineView isItemExpanded:item] )
			[theOutlineView expandItem:item];
	} else if( [item isKindOfClass:[TriviaCategory class]] ) {
		TriviaQuestion *newQuestion = [[TriviaQuestion alloc] init];
		[(TriviaCategory *)item addQuestion:newQuestion];
		[newQuestion release];
		
		[theOutlineView reloadData];
		if( ![theOutlineView isItemExpanded:item] )
			[theOutlineView expandItem:item];
	}
}

- (IBAction)deleteItem:(id)sender
{
	int selectedRow = [theOutlineView selectedRow];
	if( selectedRow == -1 ) {
		NSBeep();
		return;
	}
	
	id selectedItem = [theOutlineView itemAtRow:selectedRow];
	if( selectedItem == nil ) {
		NSBeep();
		return;
	}
	
	if( [selectedItem isKindOfClass:[TriviaBoard class]] ) {
		[theQuestionDoc removeBoard:selectedItem];
	} else if( [selectedItem isKindOfClass:[TriviaCategory class]] ) {
		TriviaBoard *parentBoard = (TriviaBoard *)[(TriviaCategory *)selectedItem parent];
		[parentBoard removeCategory:selectedItem];
	} else if( [selectedItem isKindOfClass:[TriviaQuestion class]] ) {
		TriviaCategory *parentCategory = (TriviaCategory *)[(TriviaQuestion *)selectedItem questionParent];
		[parentCategory removeQuestion:selectedItem];
	} else {
		NSBeep();
		return;
	}
	
	[theOutlineView reloadData];
	[self outlineViewSelectionDidChange:[NSNotification notificationWithName:NSOutlineViewSelectionDidChangeNotification object:theOutlineView]];
}

- (BOOL)openGameFile:(NSString *)filename
{
	if( ![theQuestionDoc promptIfUnsavedChanges] )
		return NO;
		
	NSString *extension = [filename pathExtension];
	if( ![extension isEqualToString:@"triviaqm"] )
		return NO;
	
	NSError *anError = nil;
	TriviaQuestionDocument *newDocument = [[TriviaQuestionDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filename] ofType:@"TriviaDocument" error:&anError];
	if( anError != nil )
		return NO;
	[self setDocument:newDocument];
	[[triviaWindowController window] setTitle:[NSString stringWithFormat:@"Host (%@)",[theQuestionDoc displayName]]];
	
	[theOutlineView reloadData];
	
	[self selectTabForItem:[[[[theQuestionDoc boards] objectAtIndex:0] categories] objectAtIndex:0]];
	
	[[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:[NSURL fileURLWithPath:filename]];
	return YES;
}

- (IBAction)openGame:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setAllowedFileTypes:[NSArray arrayWithObject:@"triviaqm"]];
	int openResult = [openPanel runModal];
	
	if( openResult == NSCancelButton || [[openPanel URLs] count] == 0 )
		return;
	
	
	NSString *filePath = [(NSURL*)[[openPanel URLs] objectAtIndex:0] path];
	[self openGameFile:filePath];
}

- (IBAction)saveGame:(id)sender
{
	[theQuestionDoc saveDocument:sender];
	[[triviaWindowController window] setTitle:[NSString stringWithFormat:@"Host (%@)",[theQuestionDoc displayName]]];
}

- (IBAction)saveAs:(id)sender
{
	[theQuestionDoc saveDocumentAs:sender];
	[[triviaWindowController window] setTitle:[NSString stringWithFormat:@"Host (%@)",[theQuestionDoc displayName]]];
}

- (IBAction)revert:(id)sender
{
	[self setCurrentBoard:nil];
	[theQuestionDoc revertDocumentToSaved:sender];
	//TriviaBoard *newBoard = [[theQuestionDoc boards] objectAtIndex:0];
	//[self setCurrentBoard:newBoard];
	[theOutlineView reloadData];
}

- (IBAction)new:(id)sender
{
	if( ![theQuestionDoc promptIfUnsavedChanges] )
		return;
	
	[theQuestionDoc close];
	[theQuestionDoc release];
	
	NSError *anError;
	theQuestionDoc = [[TriviaQuestionDocument alloc] initWithType:@"TriviaDocumentTest" error:&anError];
	
	[self addBoard:self];
	
	[theOutlineView reloadData];
	
	[[triviaWindowController window] setTitle:[NSString stringWithFormat:@"Host (%@)",[theQuestionDoc displayName]]];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuitem
{
	if( [menuitem action] == @selector(revert:) ) {
		if( [theQuestionDoc fileURL] == nil )
			return NO;
	}
	
	return YES;
}

- (TriviaQuestionDocument *)document
{
	return theQuestionDoc;
}

- (void)setDocument:(TriviaQuestionDocument *)newDocument
{
	if( newDocument == theQuestionDoc )
		return;
	
	[theQuestionDoc close];
	[theQuestionDoc release];
	theQuestionDoc = [newDocument retain];
}

#pragma mark Game Methods

- (TriviaBoard *)checkoutBoard
{
	if( checkedoutBoard != nil )
		return checkedoutBoard;
	
	NSEnumerator *boardEnumerator = [[theQuestionDoc boards] objectEnumerator];
	TriviaBoard *aBoard;
	while( (aBoard = [boardEnumerator nextObject]) && [aBoard allUsed] ) {
	}
	
	checkedoutBoard = aBoard;
	return checkedoutBoard;
}
- (void)checkinBoard
{
	checkedoutBoard = nil;
}

#pragma mark KVO Methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if( object == currentBoard || object == currentCategory || object == currentQuestion )
		[theOutlineView reloadData];
	else
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark OutlineView Delegate Methods

- (void)outlineViewSelectionDidChange:(NSNotification *)aNotification
{
	TriviaOutlineView *aTriviaOutlineView = [aNotification object];
	id selectedItem = [aTriviaOutlineView itemAtRow:[aTriviaOutlineView selectedRow]];
	
	[self selectTabForItem:selectedItem];
}

#pragma mark Drag and Drop Methods

- (BOOL)canDropBoard:(TriviaBoard *)aBoard onItem:(id)item atIndex:(int)anIndex andDoIt:(BOOL)doIt
{
	NSMutableArray *boards = (NSMutableArray *)[theQuestionDoc boards];
	if( item == nil && anIndex != NSOutlineViewDropOnItemIndex ) {
		if( doIt ) {
			[aBoard retain];
			TriviaBoard *boardAtTargetIndex = [boards objectAtIndex:anIndex];
			[boards removeObject:aBoard];
			unsigned newIndex = [boards indexOfObject:boardAtTargetIndex];
			[boards insertObject:aBoard atIndex:newIndex];
			[aBoard release];
		}
		
		return YES;
	}
	
	if( [item isKindOfClass:[TriviaBoard class]] && anIndex == NSOutlineViewDropOnItemIndex && item != aBoard ) {
		if( doIt ) {
			unsigned aBoardIndex = [boards indexOfObject:aBoard];
			unsigned targetBoardIndex = [boards indexOfObject:item];
			[boards exchangeObjectAtIndex:aBoardIndex withObjectAtIndex:targetBoardIndex];
		}
		
		return YES;
	}

	return NO;
}

- (BOOL)canDropCategory:(TriviaCategory *)aCategory onItem:(id)item atIndex:(int)anIndex andDoIt:(BOOL)doIt
{
	// we can drop into Boards
	if( [item isKindOfClass:[TriviaBoard class]] && !([(TriviaBoard *)item isFull] || item == [aCategory parent]) ) {
		if( doIt ) {
			TriviaBoard *aBoard = (TriviaBoard *)item;
			
			if( aBoard == [aCategory parent] && anIndex == NSOutlineViewDropOnItemIndex ) {
				// do nothing
			} else if( anIndex == NSOutlineViewDropOnItemIndex ) {
				[aBoard addCategory:aCategory];
			} else {
				[aCategory retain];
				[[aCategory parent] removeCategory:aCategory];
				[aBoard insertObject:aCategory inCategoriesAtIndex:anIndex];
				[aCategory release];
			}
		}
		return YES;
	}

	// we can drop on categories other than ourselves, but not into categories
	if( [item isKindOfClass:[TriviaCategory class]] && anIndex == NSOutlineViewDropOnItemIndex && item != aCategory ) {
		if( doIt ) {
			TriviaCategory *anotherCategory = (TriviaCategory *)item;
			unsigned aCategoryIndex = [[[aCategory parent] categories] indexOfObject:aCategory];
			unsigned anotherCategoryIndex = [[[anotherCategory parent] categories] indexOfObject:anotherCategory];
			
			if( [anotherCategory parent] == [aCategory parent] ) {
				[[anotherCategory parent] insertObject:aCategory inCategoriesAtIndex:anotherCategoryIndex];
			} else {
				[aCategory retain];
				[anotherCategory retain];
				
				TriviaBoard *aCategoryParent = [aCategory parent];
				TriviaBoard *anotherCategoryParent = [anotherCategory parent];
				
				[[aCategoryParent categories] addObject:anotherCategory];
				[[aCategoryParent categories] exchangeObjectAtIndex:aCategoryIndex withObjectAtIndex:[[aCategoryParent categories] count]-1];
				[[aCategoryParent categories] removeObjectAtIndex:[[aCategoryParent categories] count]-1];
				
				[[anotherCategoryParent categories] addObject:aCategory];
				[[anotherCategoryParent categories] exchangeObjectAtIndex:anotherCategoryIndex withObjectAtIndex:[[anotherCategoryParent categories] count]-1];
				[[anotherCategoryParent categories] removeObjectAtIndex:[[anotherCategoryParent categories] count]-1];
				
				[anotherCategory release];
				[aCategory release];
			}
		}
		
		return YES;
	}
		
	return NO;
}

- (void)swapQuestion:(TriviaQuestion *)questionOne withQuestion:(TriviaQuestion *)questionTwo
{
	[questionOne retain];
	[questionTwo retain];

	TriviaCategory *questionOneParent = [questionOne questionParent];
	TriviaCategory *questionTwoParent = [questionTwo questionParent];
	
	unsigned questionOneIndex = [[questionOneParent questions] indexOfObject:questionOne];
	unsigned questionTwoIndex = [[questionTwoParent questions] indexOfObject:questionTwo];

	[[questionOneParent questions] addObject:questionTwo];
	[[questionOneParent questions] exchangeObjectAtIndex:questionOneIndex withObjectAtIndex:[[questionOneParent questions] count]-1];
	[[questionOneParent questions] removeObjectAtIndex:[[questionOneParent questions] count]-1];
	//set the new parent ourselves since we're going straight to the array
	[questionTwo setQuestionParent:questionOneParent];

	[[questionTwoParent questions] addObject:questionOne];
	[[questionTwoParent questions] exchangeObjectAtIndex:questionTwoIndex withObjectAtIndex:[[questionTwoParent questions] count]-1];
	[[questionTwoParent questions] removeObjectAtIndex:[[questionTwoParent questions] count]-1];
	[questionOne setQuestionParent:questionTwoParent];

	[questionTwo release];
	[questionOne release];
	
	// we changed the document outside of KVO methods so the document won't notice.
	[theQuestionDoc updateChangeCount:NSChangeDone];
}

- (BOOL)canDropQuestion:(TriviaQuestion *)aQuestion onItem:(id)item atIndex:(int)anIndex andDoIt:(BOOL)doIt
{
	// if we're dropping it in a category that is our parent or isn't already full...
	if( [item isKindOfClass:[TriviaCategory class]] && (![(TriviaCategory *)item isFull] || item == [aQuestion questionParent])) {
		if( item == [aQuestion questionParent] && anIndex == NSOutlineViewDropOnItemIndex )
			return NO;
		if( doIt ) {
			TriviaCategory *aCategory = (TriviaCategory *)item;
			
			if( anIndex == NSOutlineViewDropOnItemIndex ) {
				// we allow drops on other categories
				[aCategory addQuestion:aQuestion];
			} else {
				// we're dropping between questions in our own category
				[aCategory insertObject:aQuestion inQuestionsAtIndex:anIndex];
			}
		}
		return YES;
	}
	
	// if we're dropping it on a question...
	if( [item isKindOfClass:[TriviaQuestion class]] && anIndex == NSOutlineViewDropOnItemIndex && item != aQuestion ) {
		if( doIt ) {
			TriviaQuestion *anotherQuestion = (TriviaQuestion *)item;
			int anotherQuestionIndex = [[[anotherQuestion questionParent] questions] indexOfObject:anotherQuestion];
			
			if( [anotherQuestion questionParent] == [aQuestion questionParent] ) {
				NSMutableArray *questionArray = [[aQuestion questionParent] questions];
				int aQuestionIndex = [questionArray indexOfObject:aQuestion];
				[aQuestion retain];
				[anotherQuestion retain];
				
				[questionArray replaceObjectAtIndex:aQuestionIndex withObject:anotherQuestion];
				[questionArray replaceObjectAtIndex:anotherQuestionIndex withObject:aQuestion];
				
				[anotherQuestion release];
				[aQuestion release];
			} else {
				[self swapQuestion:aQuestion withQuestion:anotherQuestion];
			}
		}
		return YES;
	}

	return NO;
}


// Actually DO the drop
- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(int)anIndex
{
	if( [[info draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:TriviaOutlinePboardType]] == nil )
		return NO;
	
	id aDraggedItem = theDraggedItem;
	if( aDraggedItem == nil )
		return NO;
	
	// we don't allow dropping an object onto itself
	if(aDraggedItem == item && anIndex == NSOutlineViewDropOnItemIndex)
		return NO;
	
	BOOL result = NO;
	if( [aDraggedItem isKindOfClass:[TriviaBoard class]] )
		result = [self canDropBoard:(TriviaBoard *)aDraggedItem onItem:item atIndex:anIndex andDoIt:YES];
	else if( [aDraggedItem isKindOfClass:[TriviaCategory class]] )
		result = [self canDropCategory:(TriviaCategory *)aDraggedItem onItem:item atIndex:anIndex andDoIt:YES];
	else if( [aDraggedItem isKindOfClass:[TriviaQuestion class]] )
		result = [self canDropQuestion:(TriviaQuestion *)aDraggedItem onItem:item atIndex:anIndex andDoIt:YES];
	
	if( result == YES ) {
		[outlineView reloadData];
		[self outlineViewSelectionDidChange:[NSNotification notificationWithName:NSOutlineViewSelectionDidChangeNotification object:outlineView]];
	}
	
	return result;
}

// Can we drop it here?
// Retarget it if necessary.
- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(int)anIndex
{
	id targetItem = item;
	BOOL dropIsAllowed = NO;
	id aDraggedItem = theDraggedItem;
	
	// Can't drop the item on itself or above and below
	if(aDraggedItem == item && anIndex == NSOutlineViewDropOnItemIndex)
		return NO;
	
	if( [aDraggedItem isKindOfClass:[TriviaBoard class]] ) {
		
		dropIsAllowed = [self canDropBoard:(TriviaBoard *)aDraggedItem onItem:targetItem atIndex:anIndex andDoIt:NO];
		if( [item isKindOfClass:[TriviaQuestion class]] ) {
			[outlineView setDropItem:[[(TriviaQuestion *)item questionParent] parent] dropChildIndex:NSOutlineViewDropOnItemIndex];
			return NSDragOperationGeneric;
		} else if( [item isKindOfClass:[TriviaCategory class]] ) {
			[outlineView setDropItem:[(TriviaCategory *)item parent] dropChildIndex:NSOutlineViewDropOnItemIndex];
			return NSDragOperationGeneric;
		}
		
	} else if( [aDraggedItem isKindOfClass:[TriviaCategory class]] ) {
		
		dropIsAllowed = [self canDropCategory:(TriviaCategory *)aDraggedItem onItem:targetItem atIndex:anIndex andDoIt:NO];
		if( [item isKindOfClass:[TriviaQuestion class]] ) {
			[outlineView setDropItem:[(TriviaQuestion *)item questionParent] dropChildIndex:NSOutlineViewDropOnItemIndex];
			return NSDragOperationGeneric;
		}
		
	} else if( [aDraggedItem isKindOfClass:[TriviaQuestion class]] )
		dropIsAllowed = [self canDropQuestion:(TriviaQuestion *)aDraggedItem onItem:targetItem atIndex:anIndex andDoIt:NO];
	
	//[outlineView setDropItem:targetItem dropChildIndex:childIndex];
	
	return (dropIsAllowed ? NSDragOperationGeneric : NSDragOperationNone);
}

// BEGIN drag
- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard
{
	if( [items count] != 1 )
		return NO;
	
	[pboard declareTypes:[NSArray arrayWithObject:TriviaOutlinePboardType] owner:self];
	[pboard setData:[NSData data] forType:TriviaOutlinePboardType];
	theDraggedItem = [items objectAtIndex:0];
	
	return YES;
}

#pragma mark Datasource Methods

- (NSArray *)getChildrenArrayForItem:(id)item
{
	NSArray *items;
	
	if( [item isKindOfClass:[TriviaCategory class]] )
		items = [(TriviaCategory *)item questions];
	else if( item == nil )
		items = [[[theQuestionDoc boards] objectAtIndex:0] categories];
	else
		items = nil;
	
	return items;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)anIndex ofItem:(id)item
{
	NSArray *items = [self getChildrenArrayForItem:item];
	if( anIndex >= (int)[items count] )
		return  nil;
	
	return [items objectAtIndex:anIndex];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	if( [item isKindOfClass:[TriviaBoard class]] || [item  isKindOfClass:[TriviaCategory class]] )
		return YES;
	
	return NO;
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	NSArray *items = [self getChildrenArrayForItem:item];
	
	if( items == nil )
		return 0;
	
	return [items count];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	id itemValue = nil;
	if( [item isKindOfClass:[TriviaBoard class]] || [item isKindOfClass:[TriviaCategory class]] || [item isKindOfClass:[TriviaQuestion class]] ) {
		if( [[tableColumn identifier] isEqualToString:@"NameColumn"] )
			itemValue = item;
	}
	
	return itemValue;
}
@end
