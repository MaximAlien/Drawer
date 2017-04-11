//
//  Drawer.m
//  Drawer
//
//  Created by Maxim Makhun on 6/11/15.
//  Copyright © 2015 Maxim Makhun. All rights reserved.
//

#import "Drawer.h"

@interface Drawer ()

@property (nonatomic, strong) NSBundle *bundle;

@end

@implementation Drawer

static Drawer *sharedPlugin = nil;

+ (void)pluginDidLoad:(NSBundle *)plugin {
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
            NSLog(@"[Drawer] Plugin was loaded.");
        });
    }
}

- (id)initWithBundle:(NSBundle *)plugin {
    if (self = [self init]) {
        self.bundle = plugin;
    }
    
    return self;
}

+ (Drawer *)sharedPlugin {
    return sharedPlugin;
}

- (id)init {
    NSLog(@"[Drawer] Called init method.");
    
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidFinishLaunching:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(selectionDidChange:)
                                                     name:NSTextViewDidChangeSelectionNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(windowDidBecomeMain:)
                                                     name:NSWindowDidBecomeMainNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)selectionDidChange:(NSNotification *)notification {
    if ([[notification object] isKindOfClass:[NSTextView class]]) {
        self.textView = (NSTextView *)[notification object];
        
        NSUInteger currentCursorLocation = [[[self.textView selectedRanges] objectAtIndex:0] rangeValue].location;
        NSLog(@"CurrentCursorLocation = %lu", currentCursorLocation);
        
        NSUInteger lengthOfSelectedText = [[[self.textView selectedRanges] objectAtIndex:0] rangeValue].length;
        NSLog(@"LengthOfSelectedText = %lu", lengthOfSelectedText);
        
        NSString *selectedString = [[self.textView string] substringWithRange:[self.textView selectedRange]];
        NSLog(@"selectedString = %@", selectedString);
    }
}

- (void)windowDidBecomeMain:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSWindowDidBecomeMainNotification
                                                  object:nil];
    
    NSWindow *window = [NSApplication sharedApplication].mainWindow;
    
    if ([window.className isEqualToString:@"IDEWorkspaceWindow"]) {
        [self layoutInvocationButton:[self createInvocationButton:window]];
    }
}

- (NSButton *)createInvocationButton:(NSWindow *)window {
    NSButton *invocationButton = [NSButton new];
    invocationButton.wantsLayer = YES;
    invocationButton.imagePosition = NSImageOnly;
    invocationButton.bordered = NO;
    invocationButton.image = [self.bundle imageForResource:@"invoke_icon"];
    invocationButton.target = self;
    invocationButton.action = @selector(invokeAction);
    invocationButton.translatesAutoresizingMaskIntoConstraints = NO;
    [window.contentView addSubview:invocationButton];
    
    return invocationButton;
}

- (void)layoutInvocationButton:(NSButton *)invocationButton {
    NSWindow *window = [NSApplication sharedApplication].mainWindow;
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:invocationButton
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:[window contentView]
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1.0f
                                                                       constant:4.0f];
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:invocationButton
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:[window contentView]
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0f
                                                                      constant:4.0f];
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:invocationButton
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0f
                                                                         constant:20.0f];
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:invocationButton
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0f
                                                                        constant:20.0f];
    
    [window.contentView addConstraints:@[leftConstraint, topConstraint]];
    [invocationButton addConstraints:@[heightConstraint, widthConstraint]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSApplicationDidFinishLaunchingNotification
                                                  object:nil];
    
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Comment"
                                                                action:@selector(commentSelection)
                                                         keyEquivalent:@""];
        [actionMenuItem setTarget:self];
        [actionMenuItem setKeyEquivalentModifierMask:NSShiftKeyMask | NSFunctionKeyMask];
        [actionMenuItem setKeyEquivalent:@"1"];
        [[menuItem submenu] addItem:actionMenuItem];
    }
}

- (void)commentSelection {
    NSString *selectedString = [[self.textView string] substringWithRange:[self.textView selectedRange]];
    
    if (![selectedString isEqualTo:@""]) {
        NSString *editedString = [NSString stringWithFormat:@"/*%@*/", selectedString];
        
        if ([self.textView shouldChangeTextInRange:[self.textView selectedRange] replacementString:editedString]) {
            [[self.textView textStorage] beginEditing];
            [self.textView.textStorage replaceCharactersInRange:[self.textView selectedRange] withString:editedString];
            [[self.textView textStorage] endEditing];
            [self.textView didChangeText];
        }
    }
}

- (void)invokeAction {
    NSLog(@"[Drawer] Action invoked.");
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
