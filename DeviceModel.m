//
//  DeviceModel.m
//  Capstone Location
//
//  Created by Kyle Bailey on 3/27/16.
//  Copyright © 2016 Kyle Bailey. All rights reserved.
//

#import "DeviceModel.h"
#import <Foundation/Foundation.h>
#import <sys/utsname.h>

NSString* deviceName()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}