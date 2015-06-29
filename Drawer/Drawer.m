//
//  Drawer.m
//  Drawer
//
//  Created by maxim.makhun on 6/11/15.
//  Copyright © 2015 Maxim Makhun. All rights reserved.
//

#import "Drawer.h"


@implementation Drawer

static Drawer *sharedPlugin = nil;


+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedPlugin = [[self alloc] init];
        NSLog(@"[Drawer] Plugin was loaded");
    });
}

+ (Drawer *)sharedPlugin
{
    return sharedPlugin;
}

- (id)init
{
    NSLog(@"[Drawer] Called init method");
    
    if (self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunchingNotification:) name:NSApplicationDidFinishLaunchingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionDidChange:) name:NSTextViewDidChangeSelectionNotification object:nil];
    }

    return self;
}

- (void)selectionDidChange:(NSNotification *)notification
{
    if ([[notification object] isKindOfClass:[NSTextView class]])
    {
        self.textView = (NSTextView *)[notification object];
        
        NSUInteger currentCursorLocation = [[[self.textView selectedRanges] objectAtIndex:0] rangeValue].location;
        NSLog(@"CurrentCursorLocation = %lu", currentCursorLocation);
        
        NSUInteger lengthOfSelectedText = [[[self.textView selectedRanges] objectAtIndex:0] rangeValue].length;
        NSLog(@"LengthOfSelectedText = %lu", lengthOfSelectedText);
        
        NSString *selectedString = [[self.textView string] substringWithRange:[self.textView selectedRange]];
        NSLog(@"selectedString = %@", selectedString);
    }
}

- (void)applicationDidFinishLaunchingNotification:(NSNotification*)notificationasdfsdhhhd
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    
    if (menuItem)
    {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Comment" action:@selector(commentSelection) keyEquivalent:@""];
        [actionMenuItem setTarget:self];
        [actionMenuItem setKeyEquivalentModifierMask:NSShiftKeyMask | NSFunctionKeyMask];
        [actionMenuItem setKeyEquivalent:@"1"];
        [[menuItem submenu] addItem:actionMenuItem];
    }
}

- (void)commentSelection
{
    NSString *selectedString = [[self.textView string] substringWithRange:[self.textView selectedRange]];
    
    if (![selectedString isEqualTo:@""])
    {
        NSString *editedString = [NSString stringWithFormat:@"/*%@*/", selectedString];
        
        if ([self.textView shouldChangeTextInRange:[self.textView selectedRange] replacementString:editedString])
        {
            [[self.textView textStorage] beginEditing];
            [self.textView.textStorage replaceCharactersInRange:[self.textView selectedRange] withString:editedString];
            [[self.textView textStorage] endEditing];
            [self.textView didChangeText];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end