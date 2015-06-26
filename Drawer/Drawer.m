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
        NSTextView *textView = (NSTextView *)[notification object];
        
        NSUInteger currentCursorLocation = [[[textView selectedRanges] objectAtIndex:0] rangeValue].location;
        NSLog(@"CurrentCursorLocation = %lu", currentCursorLocation);
        
        NSUInteger lengthOfSelectedText = [[[textView selectedRanges] objectAtIndex:0] rangeValue].length;
        NSLog(@"LengthOfSelectedText = %lu", lengthOfSelectedText);
        
        NSString *selectedString = [[textView string] substringWithRange:[textView selectedRange]];
        NSLog(@"selectedString = %@", selectedString);
        
        if (![selectedString isEqualTo:@""])
        {
            NSString *editedString = [NSString stringWithFormat:@"/*%@*/", selectedString];
            [textView replaceCharactersInRange:[textView selectedRange] withString:editedString];
        }
    }
}

- (void)applicationDidFinishLaunchingNotification:(NSNotification*)notificationasdfsdhhhd
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (menuItem)
    {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Action" action:@selector(doAction) keyEquivalent:@""];
        [actionMenuItem setTarget:self];
        [[menuItem submenu] addItem:actionMenuItem];
    }
}

- (void)doAction
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Action"];
    [alert runModal];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end