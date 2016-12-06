//
//  LSDOnlineLocationOperation.m
//  Tabster
//
//  Created by beyond on 12-8-22.
//  Copyright (c) 2012年 beyond. All rights reserved.
//

#ifdef LOTUSEED_LOCATION

#import "LSDOnlineLocationOperation.h"
#import "LSDConstants.h"
#import "LSDProfile.h"
#import "LSDJsonParser.h"
#import "LSDSession.h"
#import "LSDEMP2.h"

@interface LSDOnlineLocationOperation(PRIVATE)

- (NSData*)generatePostData;

@end

@implementation LSDOnlineLocationOperation

@synthesize location;

- (id)initWithMessageID:(int)ID
{
    if (self = [super initWithMessageID:ID]) {
        [self setPostData:[self generatePostData]];
    }
    return self;
}

- (void)dealloc
{
    if (_delegate) {
        [_delegate release];
    }
    [super dealloc];
}

- (void)setSelector:(SEL)selector toTarget:(id)delegate
{
    [delegate retain];
    [_delegate release];
    _delegate = delegate;
    
    _selector = selector;
}

- (NSData*)generatePostData
{
    LSDEMP2 *emp = [[[LSDEMP2 alloc] init] autorelease];
    
    [emp addInteger:@"/mid" value:MESSAGE_ID_LOCATION_QUERY];
    [emp addString:@"/mid/sid" value:[LSDSession sessionID]];
    [emp addString:@"/mid/cl" value:[LSDProfile getSystemLanguage]];
    
    if (location) {
        CLLocationCoordinate2D loc = [location coordinate];
        [emp addFloat:@"/mid/gps/lla" value:loc.latitude];
        [emp addFloat:@"/mid/gps/llo" value:loc.longitude];
    }
    
    /*
    Location location = Profile.getLocation(mAppContext);
    if (location != null) {
        emp.add("/mid/gps/lla", location.getLatitude());
        emp.add("/mid/gps/llo", location.getLongitude());
        emp.add("/mid/gps/lac", location.getAccuracy());
        emp.add("/mid/gps/lal", location.getAltitude());
    }
    
    GsmCellLocation cellLocation = Profile.getCellLocation(mAppContext);
    if (cellLocation != null) {
        emp.add("/mid/lac/CELL", cellLocation.getCid());
        emp.add("/mid/lac/LAC", cellLocation.getLac());
    }
    */
    
    NSDictionary *wifiInfo = [LSDProfile getWifiInfo];
    if (wifiInfo) {
        NSString* bssid =[NSString stringWithFormat:@"%@", [wifiInfo objectForKey:@"BSSID"]];
        [emp addString:@"/mid/MAC" value:bssid];
    }
    
    return [emp getBuffer];
}

//Override
- (BOOL)doResult:(NSDictionary*)jsonDic
{
    if (jsonDic && _delegate && _selector) {
        NSString *code = [jsonDic objectForKey:@"v"];
        NSString *name = [jsonDic objectForKey:@"n"];
        
        NSMutableDictionary *retDic = [NSMutableDictionary dictionaryWithCapacity:2];
        if (code) [retDic setObject:code forKey:@"code"];
        if (name) [retDic setObject:name forKey:@"name"];
        
        //消息回调
        [_delegate performSelectorOnMainThread:_selector withObject:retDic waitUntilDone:NO];
            
        return YES;
    }
    
    if (_delegate && _selector) {
        //消息回调
        [_delegate performSelectorOnMainThread:_selector withObject:nil waitUntilDone:NO];
    }
    
    return NO;
}

@end

#endif
