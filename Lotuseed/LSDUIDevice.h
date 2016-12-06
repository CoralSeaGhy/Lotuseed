/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */
#ifndef	UI_DEVICE_HARDWARE
#define	UI_DEVICE_HARDWARE


#import <UIKit/UIKit.h>


@interface LSDUIDevice : NSObject

+ (LSDUIDevice *)currentDevice;

- (NSString *) platform;
- (NSString *) hwmodel;

- (NSUInteger) cpuFrequency;
- (NSUInteger) busFrequency;
- (NSUInteger) totalMemory;
- (NSUInteger) userMemory;

- (NSNumber *) totalDiskSpace;
- (NSNumber *) freeDiskSpace;

- (NSString *) macaddress;
- (NSString *) ipaddress;
- (NSString *) hostname;
@end

#endif