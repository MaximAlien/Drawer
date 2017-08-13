//
//  RuntimeTools.h
//  CodeInjectorSlave
//
//  Created by Maxim Makhun on 8/12/17.
//  Copyright © 2017 Maxim Makhun. All rights reserved.
//

@import Foundation;

#import <objc/runtime.h>

const NSString *kPrefix = @"[Drawer]";

bool isClassPresent(NSString *className) {
    Class testClass = NSClassFromString(className);
    if (testClass == nil) {
        NSLog(@"%@ %s. Class %@ is not present.", kPrefix, __FUNCTION__, className);
        return false;
    }
    
    NSLog(@"%@ %s. Class %@ is present.", kPrefix, __FUNCTION__, className);
    return true;
}

void createClass(NSString *className) {
    NSLog(@"%@ %s", kPrefix, __FUNCTION__);
    
    Class clazz;
    if (!isClassPresent(className)) {
        clazz = objc_allocateClassPair([NSObject class], [className UTF8String], 0);
    }
    
    objc_registerClassPair(clazz);
}

int getClassesNumber() {
    return objc_getClassList(NULL, 0);
}

void getClasses() {
    int classCount = getClassesNumber();
    Class *classes = NULL;
    
    if (classCount > 0) {
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * classCount);
        classCount = objc_getClassList(classes, classCount);
        for (int i = 0; i < classCount; ++i) {
            Class class = classes[i];
            const char *className = class_getName(class);
            NSLog(@"%@ Class name: %s\n", kPrefix, className);
        }
        
        free(classes);
    }
}

void getClassMethods(Class class) {
    NSLog(@"%@ \n----------------------------------------------------------------------\n", kPrefix);
    uint methodsCount;
    
    NSLog(@"%@ Class methods list of: %s\n", kPrefix, [NSStringFromClass(class) UTF8String]);
    Method *methods = class_copyMethodList(class, &methodsCount);
    NSLog(@"%@ Methods count: %d\n", kPrefix, methodsCount);
    
    for (uint i = 0; i < methodsCount; ++i) {
        Method method = methods[i];
        SEL selector = method_getName(method);
        const char *methodName = sel_getName(selector);
        NSString *methodNameStr = [NSString stringWithCString:methodName encoding:NSUTF8StringEncoding];
        
        const char *returnType = method_copyReturnType(method);
        NSString *returnTypeStr = [NSString stringWithCString:returnType encoding:NSUTF8StringEncoding];
        
        uint argumentsCount = method_getNumberOfArguments(method);
        
        NSMutableString *argumentTypeStr = [NSMutableString string];
        for (uint t = 0; t < argumentsCount; ++t) {
            char *argumentType = method_copyArgumentType(method, t);
            [argumentTypeStr appendString:[NSString stringWithUTF8String:argumentType]];
            free(argumentType);
        }
        
        NSLog(@"%@ Method name: %@, Return type: %@, Arguments count: %d, Arguments: %@\n",
              kPrefix,
              methodNameStr,
              returnTypeStr,
              argumentsCount,
              argumentTypeStr);
        
        if (argumentsCount == 2) {
            if ([returnTypeStr isEqualToString:@"@"]) {
                @try {
                    if ([class respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                        id result = [class performSelector:selector];
                        
                        NSLog(@"%@ Result: %@\n", kPrefix, result);
#pragma clang diagnostic pop
                    } else {
                        NSLog(@"%@ Method name: %@ does not respond to selector\n", kPrefix, methodNameStr);
                    }
                } @catch(id exception) {
                    NSLog(@"%@ Exception occured: %s", kPrefix, [[exception description] UTF8String]);
                }
            }
        }
    }
    
    free(methods);
    NSLog(@"%@ \n----------------------------------------------------------------------\n", kPrefix);
}

void getInstanceMethods(id instance) {
    NSLog(@"%@ \n----------------------------------------------------------------------\n", kPrefix);
    uint methodsCount;
    
    NSLog(@"%@ Instance methods list of: %s\n", kPrefix, [NSStringFromClass([instance class]) UTF8String]);
    Method *methods = methods = class_copyMethodList([instance class], &methodsCount);
    
    for (uint i = 0; i < methodsCount; ++i) {
        Method method = methods[i];
        SEL selector = method_getName(method);
        const char *methodName = sel_getName(selector);
        NSString *methodNameStr = [NSString stringWithCString:methodName encoding:NSUTF8StringEncoding];
        
        const char *returnType = method_copyReturnType(method);
        NSString *returnTypeStr = [NSString stringWithCString:returnType encoding:NSUTF8StringEncoding];
        
        uint argumentsCount = method_getNumberOfArguments(method);
        
        NSMutableString *argumentTypeStr = [NSMutableString string];
        for (uint t = 0; t < argumentsCount; ++t) {
            char *argumentType = method_copyArgumentType(method, t);
            [argumentTypeStr appendString:[NSString stringWithUTF8String:argumentType]];
            free(argumentType);
        }
        
        NSLog(@"%@ Method name: %@, Return type: %@, Arguments count: %d, Arguments: %@\n", kPrefix, methodNameStr, returnTypeStr, argumentsCount, argumentTypeStr);
        
        if (![returnTypeStr isEqualToString:@"v"] && argumentsCount == 2 && [returnTypeStr isEqualToString:@"@"]) {
            @try {
                if ([instance respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    id result = [instance performSelector:selector];
                    
                    NSLog(@"%@ Result: %@\n", kPrefix, result);
#pragma clang diagnostic pop
                } else {
                    NSLog(@"%@ Method name: %@ does not respond to selector\n", kPrefix, methodNameStr);
                }
            } @catch(id exception) {
                NSLog(@"%@ Exception occured: %s", kPrefix, [[exception description] UTF8String]);
            }
        }
        
        NSArray<NSString *> *primitiveTypesArray = @[@"B", @"i", @"q", @"f", @"d"];
        
        BOOL isPrimitiveType = NO;
        for (NSString *type in primitiveTypesArray) {
            if ([type isEqualToString:returnTypeStr]) {
                isPrimitiveType = YES;
                break;
            }
        }
        
        if (![returnTypeStr isEqualToString:@"v"] && argumentsCount == 2 && isPrimitiveType) {
            BOOL invocationResult = NO;
            
            NSMethodSignature *signature = [instance methodSignatureForSelector:selector];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            [invocation setTarget:instance];
            [invocation setSelector:selector];
            [invocation invoke];
            [invocation getReturnValue:&invocationResult];
            
            NSLog(@"%@ Result: %d\n", kPrefix, invocationResult);
        }
    }
    
    free(methods);
    NSLog(@"%@ \n----------------------------------------------------------------------\n", kPrefix);
}

void getInstanceiVars(id instance) {
    NSLog(@"%@ \n----------------------------------------------------------------------\n", kPrefix);
    uint iVarsCount;
    
    NSLog(@"%@ iVar list of: %s\n", kPrefix, [NSStringFromClass([instance class]) UTF8String]);
    Ivar *iVars = class_copyIvarList([instance class], &iVarsCount);
    for (int i = 0; i < iVarsCount; ++i) {
        @try {
            Ivar iVar = iVars[i];
            NSString *iVarNameStr = [NSString stringWithUTF8String:ivar_getName(iVar)];
            NSString *iVarTypeStr = [NSString stringWithUTF8String:ivar_getTypeEncoding(iVar)];
            NSString *iVarTypeEncoding = [iVarTypeStr substringWithRange:NSMakeRange(0, 1)];
            
            NSLog(@"%@ Name: %@, Type: %@, Type encoding: %@", kPrefix, iVarNameStr, iVarTypeStr, iVarTypeEncoding);
            
            if ([iVarTypeEncoding isEqualToString:@"@"]) {
                id iVarValue = object_getIvar(instance, iVar);
                NSLog(@"\nValue: %@", iVarValue);
            }
            
            NSLog(@"\n");
        } @catch(id exception) {
            NSLog(@"%@ Exception occured: %s", kPrefix, [[exception description] UTF8String]);
        }
    }
    
    free(iVars);
    NSLog(@"%@ \n----------------------------------------------------------------------\n", kPrefix);
}

void getInstanceProperties(id instance) {
    NSLog(@"%@ \n----------------------------------------------------------------------\n", kPrefix);
    uint propertiesCount;
    
    NSLog(@"%@ Property list of: %s\n", kPrefix, [NSStringFromClass([instance class]) UTF8String]);
    objc_property_t *properties = class_copyPropertyList([instance class], &propertiesCount);
    for (uint i = 0; i < propertiesCount; ++i) {
        @try {
            NSString *propertyNameStr = [NSString stringWithUTF8String:property_getName(properties[i])];
            id propertyValue = [instance valueForKeyPath:propertyNameStr];
            NSLog(@"%@ %@: %@\n", kPrefix, propertyNameStr, propertyValue);
        } @catch(id exception) {
            NSLog(@"%@ Exception occured: %s", kPrefix, [[exception description] UTF8String]);
        }
    }
    
    free(properties);
    NSLog(@"%@ \n----------------------------------------------------------------------\n", kPrefix);
}

void getClassProperties(Class class) {
    NSLog(@"%@ \n----------------------------------------------------------------------\n", kPrefix);
    uint propertiesCount;
    
    objc_property_t *properties = class_copyPropertyList(class, &propertiesCount);
    for (uint i = 0; i < propertiesCount; ++i) {
        NSLog(@"%@ Property name: %@\n", kPrefix, [NSString stringWithUTF8String:property_getName(properties[i])]);
        
        uint attributesCount;
        objc_property_attribute_t *propertyAttributes = property_copyAttributeList(properties[i], &attributesCount);
        
        for (uint t = 0; t < attributesCount; ++t) {
            NSString *attribute;
            switch (propertyAttributes[t].name[0]) {
                case 'R': // readonly
                    attribute = @"readonly";
                    break;
                case 'C': // copy
                    attribute = @"copy";
                    break;
                case '&': // retain
                    attribute = @"retain";
                    break;
                case 'N': // nonatomic
                    attribute = @"nonatomic";
                    break;
                case 'G': // custom getter
                    attribute = @"custom getter";
                    break;
                case 'S': // custom setter
                    attribute = @"custom setter";
                    break;
                case 'D': // dynamic
                    attribute = @"dynamic";
                    break;
                case 'W': // weak
                    attribute = @"weak";
                    break;
                case 'T': // type
                    attribute = @"type";
                    break;
                case 'P': // eligible for garbage collection
                    attribute = @"eligible for garbage collection";
                    break;
                case 'V': // value
                    attribute = @"value";
                    break;
                default:
                    break;
            }
            
            NSLog(@"%@ Attribute: %@ (%@).%@\n",
                  kPrefix,
                  attribute,
                  [NSString stringWithUTF8String:&propertyAttributes[t].name[0]],
                  propertyAttributes[t].name[0] == 'V'
                  ? [NSString stringWithFormat:@" Value: %@.", [NSString stringWithUTF8String:propertyAttributes->value]]
                  : @"");
        }
        
        free(propertyAttributes);
    }
    
    free(properties);
    NSLog(@"%@ \n----------------------------------------------------------------------\n", kPrefix);
}
