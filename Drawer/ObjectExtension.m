//
//  ObjectExtension.m
//  Drawer
//
//  Created by maxim.makhun on 6/11/15.
//  Copyright © 2015 Maxim Makhun. All rights reserved.
//

#import "ObjectExtension.h"
#import "Drawer.h"

@implementation NSObject (Plugin)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    
    if ([currentApplicationName isEqual:@"Xcode"])
    {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[Drawer alloc] initWithBundle:plugin];
        });
    }
}

@end