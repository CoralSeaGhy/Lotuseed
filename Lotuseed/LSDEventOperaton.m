//
//  LSDEventOperaton.m
//  Lotuseed
//
//  Created by beyond on 12-5-30.
//  Copyright (c) 2012年 beyond. All rights reserved.
//

#import "LSDEventOperaton.h"
#import "LSDConstants.h"
#import "LSDEMP2.h"
#import "LSDSession.h"
#import "LSDProfile.h"
#import "LSDProvider.h"
#import "LotuseedInternal.h"
#import "LSDUtils.h"
#import <objc/runtime.h>

@implementation LSDEventOperaton

- (NSData*)generatePostData
{
    LSDEMP2 *emp = [[[LSDEMP2 alloc] init] autorelease];
    
    [emp addInteger:@"/mid" value:MESSAGE_ID_POST_EVENT];
    
    [emp addString:@"/mid/sid" value:[LSDSession sessionID]];
    [emp addInteger:@"/mid/et" value:_eventType];
    [emp addString:@"/mid/ei" value:_eventID];
    
    if (_eventType == EVENT_TYPE_LIFECYCLE && [_eventID isEqualToString:EVENT_ID_ONDESTROY]) {
        [emp addString:@"/mid/em" value:[NSString stringWithFormat:@"%@+%d", _eventLabel, [LSDProfile currentTimeZone]]];
    }
    else {
        [emp addString:@"/mid/em" value:[NSString stringWithFormat:@"%lld+%d", _eventTime, [LSDProfile currentTimeZone]]];
    }
    
    switch (_eventType) {
		case EVENT_TYPE_LIFECYCLE:
            if ([_eventID isEqualToString:EVENT_ID_ONPAUSE] || [_eventID isEqualToString:EVENT_ID_ONRESUME]) {
                [emp addString:@"/mid/pi" value:_eventLabel];
                [emp addBoolean:@"/mid/so" value:[LSDProfile isScreenOrientationLandscape]];
            }
            break;
		case EVENT_TYPE_LOG:
            [emp addString:@"/mid/lt" value:_eventLabel];
			break;
#ifdef LOTUSEED_AUTO
        case EVENT_TYPE_AUTO:
            [emp addString:@"/mid/el" value:_eventLabel];
            //只有私有隐式数据 isDuration&immediately 参数同时为 true!!!
            if (_isDuration && _isImmediate==YES) {
                [emp addInteger:@"/mid/dt" value:1];
            }
            break;
#endif
		case EVENT_TYPE_CUSTOM:
            [emp addString:@"/mid/el" value:_eventLabel];
            [emp addBoolean:@"/mid/ef" value:_isDuration];
            [emp addInteger:@"/mid/ec" value:_eventCount];
			break;
    }
    
    // 动态扩展数据
    @try {
        int dynamicFlag = [LSDProvider getEventExtinfoFlag];
        
        if ((dynamicFlag & DYNAMIC_FLAG_FILELINE) == DYNAMIC_FLAG_FILELINE) {
            [emp addString:@"/mid/ex/a/v" value: [LSDProfile getAppBuildVersion]];
            [emp addString:@"/mid/ex/a/c" value: [LSDProfile getChannel]];
        }
        
        if ((dynamicFlag & DYNAMIC_FLAG_DEVICE) == DYNAMIC_FLAG_DEVICE) {
            [emp addString:@"/mid/ex/b/IDFA" value: [LSDProfile getIDFA]];
            [emp addString:@"/mid/ex/b/IDFV" value: [LSDProfile getIDFV]];
        }
        
        NSDictionary *wifiInfo = [LSDProfile getWifiInfo];
        
        if ((dynamicFlag & DYNAMIC_FLAG_LOCATION) == DYNAMIC_FLAG_LOCATION) {
#ifdef LOTUSEED_LOCATION
            CLLocation* location = [LotuseedInternal getLocation];
            if (location) {
                CLLocationCoordinate2D loc = [location coordinate];
                
                [emp addFloat:@"/mid/ex/c/lla" value:loc.latitude];
                [emp addFloat:@"/mid/ex/c/llo" value:loc.longitude];
                [emp addFloat:@"/mid/ex/c/lac" value:[location horizontalAccuracy]];
                [emp addFloat:@"/mid/ex/c/lal" value:[location altitude]];
                [emp addString:@"/mid/ex/c/lat"value:[LSDUtils toTimestampString:[location timestamp] withTimezone:[LSDProfile currentTimeZone]]];
                [emp addFloat:@"/mid/ex/c/las" value:[location speed]];
                [emp addFloat:@"/mid/ex/c/lab" value:[location course]];
            }
#endif
            if (wifiInfo) {
                NSString* bssid =[NSString stringWithFormat:@"%@", [wifiInfo objectForKey:@"BSSID"]];
                [emp addString:@"/mid/ex/c/MAC2" value:bssid];
            }
        }
        
        if ((dynamicFlag & DYNAMIC_FLAG_NETWORK) == DYNAMIC_FLAG_NETWORK) {
            [emp addString:@"/mid/ex/d/ct" value: [LSDProfile getNetworkType]];
            if (wifiInfo) {
                 NSString* ssid =[NSString stringWithFormat:@"%@", [wifiInfo objectForKey:@"SSID"]];
                [emp addString:@"/mid/ex/d/ssid" value:ssid];
            }
            [emp addString:@"/mid/ex/d/ca" value:[LSDProfile getCarrier]];
        }
        
        if ((dynamicFlag & DYNAMIC_FLAG_CUSTOM) == DYNAMIC_FLAG_CUSTOM) {
            NSString* data = [LSDProfile getCustomData256];
            if (data) {
                [emp addString:@"/mid/ex/e" value:data];
            }
        }
    } @catch (NSException *exception) {
        
    }
    
    return [emp getBuffer];
}

- (id)initWithEventType:(int)eventType eventID:(NSString*)ID eventLabel:(NSString*)label eventCount:(long)count isDuration:(boolean_t)flag forcePost:(BOOL)immediately eventTime:(int64_t)time
{
    if (self = [super initWithMessageID:MESSAGE_ID_POST_EVENT forcePost:immediately]) {
        self->_eventType = eventType;
        self->_eventID = [ID retain];
        self->_eventLabel = [label retain];
        self->_isDuration = flag;
        self->_isImmediate = immediately;
        self->_eventCount = count;
        self->_eventTime = time;

        NSData *data = [self generatePostData];
        [self setPostData:data];
    }
    return self;
}

- (void)dealloc
{
    [_eventID release];
    [_eventLabel release];
    
    [super dealloc];
}

@end
