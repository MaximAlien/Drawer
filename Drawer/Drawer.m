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
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)applicationDidFinishLaunchingNotification:(NSNotification*)notification
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
