//
//  LSDTrack.h
//  LSDTrack
//
//  Created by beyond on 12-8-22.
//  Copyright (c) 2012年 beyond. All rights reserved.
//

#ifdef LOTUSEED_TRACK

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface LSDTrack : NSObject {
    
}

/**
 * 开启Lotuseed Tracking功能
 */
+ (void)startTracking:(NSString *)appKey;

@end

#endif
