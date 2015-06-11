//
//  ObjectExtension.h
//  Drawer
//
//  Created by maxim.makhun on 6/11/15.
//  Copyright © 2015 Maxim Makhun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Plugin)

+ (void)pluginDidLoad:(NSBundle *)plugin;

@end