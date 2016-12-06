//
//  LSDKeyChain.m
//  Tabster
//
//  Created by eagle on 13-9-25.
//  Copyright (c) 2013年 beyond. All rights reserved.
//

#import "LSDKeyChain.h"

/**
 * History:
 * 20131118  fixed all memory leak
 */

static NSString *_defaultService;

@interface LSDKeyChain () {
    NSMutableDictionary *itemsToUpdate;
}

@end

@implementation LSDKeyChain

+ (NSString *)defaultService
{
    if (!_defaultService) {
        _defaultService = [[NSBundle mainBundle] bundleIdentifier];
    }
    
    return _defaultService;
}

+ (void)setDefaultService:(NSString *)defaultService
{
    _defaultService = defaultService;
}

#pragma mark -

+ (LSDKeyChain *)keyChainStore
{
    return [[self alloc] initWithService:[self defaultService]];
}

+ (LSDKeyChain *)keyChainStoreWithService:(NSString *)service
{
    return [[self alloc] initWithService:service];
}

+ (LSDKeyChain *)keyChainStoreWithService:(NSString *)service accessGroup:(NSString *)accessGroup {
    return [[self alloc] initWithService:service accessGroup:accessGroup];
}

- (instancetype)init
{
    return [self initWithService:[self.class defaultService] accessGroup:nil];
}

- (instancetype)initWithService:(NSString *)service
{
    return [self initWithService:service accessGroup:nil];
}

- (instancetype)initWithService:(NSString *)service accessGroup:(NSString *)accessGroup
{
    self = [super init];
    if (self) {
        if (!service) {
            service = [self.class defaultService];
        }
        _service = [service copy];
        _accessGroup = [accessGroup copy];
        
        itemsToUpdate = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [_service release];
    [_accessGroup release];
    [itemsToUpdate release];
    
    [super dealloc];
}

#pragma mark -

+ (NSString *)stringForKey:(NSString *)key
{
    return [self stringForKey:key service:[self defaultService] accessGroup:nil];
}

+ (NSString *)stringForKey:(NSString *)key service:(NSString *)service
{
    return [self stringForKey:key service:service accessGroup:nil];
}

+ (NSString *)stringForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup
{
    NSData *data = [self dataForKey:key service:service accessGroup:accessGroup];
    if (data) {
        return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    }
    
    return nil;
}

+ (BOOL)setString:(NSString *)value forKey:(NSString *)key
{
    return [self setString:value forKey:key service:[self defaultService] accessGroup:nil];
}

+ (BOOL)setString:(NSString *)value forKey:(NSString *)key service:(NSString *)service
{
    return [self setString:value forKey:key service:service accessGroup:nil];
}

+ (BOOL)setString:(NSString *)value forKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup
{
    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
    return [self setData:data forKey:key service:service accessGroup:accessGroup];
}

#pragma mark -

+ (NSData *)dataForKey:(NSString *)key
{
    return [self dataForKey:key service:[self defaultService] accessGroup:nil];
}

+ (NSData *)dataForKey:(NSString *)key service:(NSString *)service
{
    return [self dataForKey:key service:service accessGroup:nil];
}

+ (NSData *)dataForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup
{
	if (!key) {
		return nil;
	}
	if (!service) {
        service = [self defaultService];
	}
    
	NSMutableDictionary *query = [[[NSMutableDictionary alloc] init] autorelease];;
	[query setObject:kSecClassGenericPassword forKey:kSecClass];
	[query setObject:[NSNumber numberWithBool:YES] forKey:kSecReturnData]; //kCFBooleanTrue-->
	[query setObject:kSecMatchLimitOne forKey:kSecMatchLimit];
	[query setObject:service forKey:kSecAttrService];
    [query setObject:key forKey:kSecAttrGeneric];
    [query setObject:key forKey:kSecAttrAccount];
#if !TARGET_IPHONE_SIMULATOR && defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
    if (accessGroup) {
        [query setObject:accessGroup forKey:kSecAttrAccessGroup];
    }
#endif
    
	CFTypeRef data = nil;
	OSStatus status = SecItemCopyMatching(( CFDictionaryRef)query, &data);
	if (status != errSecSuccess) {
        return nil;
	}
    
    NSData *ret = [NSData dataWithData:( NSData *)data];
    if (data) {
        CFRelease(data);
    }
    
    return ret;
}

+ (BOOL)setData:(NSData *)data forKey:(NSString *)key
{
    return [self setData:data forKey:key service:[self defaultService] accessGroup:nil];
}

+ (BOOL)setData:(NSData *)data forKey:(NSString *)key service:(NSString *)service
{
    return [self setData:data forKey:key service:service accessGroup:nil];
}

+ (BOOL)setData:(NSData *)data forKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup
{
	if (!key) {
		return NO;
	}
	if (!service) {
        service = [self defaultService];
	}
	
	NSMutableDictionary *query = [[[NSMutableDictionary alloc] init] autorelease];
	[query setObject:kSecClassGenericPassword forKey:kSecClass];
	[query setObject:service forKey:kSecAttrService];
    [query setObject:key forKey:kSecAttrGeneric];
    [query setObject:key forKey:kSecAttrAccount];
#if !TARGET_IPHONE_SIMULATOR && defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
    if (accessGroup) {
        [query setObject:accessGroup forKey:kSecAttrAccessGroup];
    }
#endif
    
	OSStatus status = SecItemCopyMatching(( CFDictionaryRef)query, NULL);
	if (status == errSecSuccess) {
        if (data) {
            NSMutableDictionary *attributesToUpdate = [[NSMutableDictionary alloc] init];
            [attributesToUpdate setObject:data forKey:kSecValueData];
            
            status = SecItemUpdate(( CFDictionaryRef)query, ( CFDictionaryRef)attributesToUpdate);
            if (status != errSecSuccess) {
                return NO;
            }
        } else {
            [self removeItemForKey:key service:service accessGroup:accessGroup];
        }
	} else if (status == errSecItemNotFound) {
		NSMutableDictionary *attributes = [[[NSMutableDictionary alloc] init] autorelease];
		[attributes setObject:kSecClassGenericPassword forKey:kSecClass];
        [attributes setObject:service forKey:kSecAttrService];
        [attributes setObject:key forKey:kSecAttrGeneric];
        [attributes setObject:key forKey:kSecAttrAccount];
		[attributes setObject:data forKey:kSecValueData];
#if !TARGET_IPHONE_SIMULATOR && defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
        if (accessGroup) {
            [attributes setObject:accessGroup forKey:kSecAttrAccessGroup];
        }
#endif
		
		status = SecItemAdd(( CFDictionaryRef)attributes, NULL);
		if (status != errSecSuccess) {
			return NO;
		}
	} else {
        return NO;
	}
    
    return YES;
}

#pragma mark -

- (void)setString:(NSString *)string forKey:(NSString *)key
{
    [self setData:[string dataUsingEncoding:NSUTF8StringEncoding] forKey:key];
}

- (NSString *)stringForKey:(id)key
{
    NSData *data = [self dataForKey:key];
    if (data) {
        return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    }
    
    return nil;
}

#pragma mark -

- (void)setData:(NSData *)data forKey:(NSString *)key
{
    if (!key) {
        return;
    }
    if (!data) {
        [self removeItemForKey:key];
    } else {
        [itemsToUpdate setObject:data forKey:key];
    }
}

- (NSData *)dataForKey:(NSString *)key
{
    NSData *data = [itemsToUpdate objectForKey:key];
    if (!data) {
        data = [[self class] dataForKey:key service:self.service accessGroup:self.accessGroup];
    }
    
    return data;
}

#pragma mark -

+ (BOOL)removeItemForKey:(NSString *)key
{
    return [LSDKeyChain removeItemForKey:key service:[self defaultService] accessGroup:nil];
}

+ (BOOL)removeItemForKey:(NSString *)key service:(NSString *)service
{
    return [LSDKeyChain removeItemForKey:key service:service accessGroup:nil];
}

+ (BOOL)removeItemForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup
{
	if (!key) {
		return NO;
	}
	if (!service) {
        service = [self defaultService];
	}
	
	NSMutableDictionary *itemToDelete = [[[NSMutableDictionary alloc] init] autorelease];
	[itemToDelete setObject:kSecClassGenericPassword forKey:kSecClass];
	[itemToDelete setObject:service forKey:kSecAttrService];
    [itemToDelete setObject:key forKey:kSecAttrGeneric];
    [itemToDelete setObject:key forKey:kSecAttrAccount];
#if !TARGET_IPHONE_SIMULATOR && defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
    if (accessGroup) {
        [itemToDelete setObject:accessGroup forKey:kSecAttrAccessGroup];
    }
#endif
	
	OSStatus status = SecItemDelete(( CFDictionaryRef)itemToDelete);
	if (status != errSecSuccess && status != errSecItemNotFound) {
        return NO;
	}
    
    return YES;
}

+ (NSArray *)itemsForService:(NSString *)service accessGroup:(NSString *)accessGroup
{
	if (!service) {
        service = [self defaultService];
	}
	
	NSMutableDictionary *query = [[[NSMutableDictionary alloc] init] autorelease];
	[query setObject:kSecClassGenericPassword forKey:kSecClass];
	[query setObject:(id)kCFBooleanTrue forKey:kSecReturnAttributes];
	[query setObject:(id)kCFBooleanTrue forKey:kSecReturnData];
	[query setObject:kSecMatchLimitAll forKey:kSecMatchLimit];
	[query setObject:service forKey:kSecAttrService];
#if !TARGET_IPHONE_SIMULATOR && defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
    if (accessGroup) {
        [query setObject:accessGroup forKey:kSecAttrAccessGroup];
    }
#endif
	
	CFArrayRef result = nil;
	OSStatus status = SecItemCopyMatching(( CFDictionaryRef)query, (CFTypeRef *)&result);
	if (status == errSecSuccess || status == errSecItemNotFound) {
		return CFBridgingRelease(result);
	} else {
		return nil;
	}
}

+ (BOOL)removeAllItems
{
    return [self removeAllItemsForService:[self defaultService] accessGroup:nil];
}

+ (BOOL)removeAllItemsForService:(NSString *)service
{
    return [self removeAllItemsForService:service accessGroup:nil];
}

+ (BOOL)removeAllItemsForService:(NSString *)service accessGroup:(NSString *)accessGroup
{
    NSArray *items = [LSDKeyChain itemsForService:service accessGroup:accessGroup];
    for (NSDictionary *item in items) {
        NSMutableDictionary *itemToDelete = [[NSMutableDictionary alloc] initWithDictionary:item];
        [itemToDelete setObject:kSecClassGenericPassword forKey:kSecClass];
        
        OSStatus status = SecItemDelete(( CFDictionaryRef)itemToDelete);
        if (status != errSecSuccess) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark -

- (void)removeItemForKey:(NSString *)key
{
    if ([itemsToUpdate objectForKey:key]) {
        [itemsToUpdate removeObjectForKey:key];
    } else {
        [[self class] removeItemForKey:key service:self.service accessGroup:self.accessGroup];
    }
}

- (void)removeAllItems
{
    [itemsToUpdate removeAllObjects];
    [[self class] removeAllItemsForService:self.service accessGroup:self.accessGroup];
}

#pragma mark -

- (void)synchronize
{
    for (NSString *key in itemsToUpdate) {
        [[self class] setData:[itemsToUpdate objectForKey:key] forKey:key service:self.service accessGroup:self.accessGroup];
    }
    
    [itemsToUpdate removeAllObjects];
}

#pragma mark -

- (NSString *)description
{
    NSArray *items = [LSDKeyChain itemsForService:self.service accessGroup:self.accessGroup];
    NSMutableArray *list = [[[NSMutableArray alloc] initWithCapacity:items.count] autorelease];
    for (NSDictionary *attributes in items) {
        NSMutableDictionary *attrs = [[[NSMutableDictionary alloc] init] autorelease];
        [attrs setObject:[attributes objectForKey:kSecAttrService] forKey:@"Service"];
        [attrs setObject:[attributes objectForKey:kSecAttrAccount] forKey:@"Account"];
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
        [attrs setObject:[attributes objectForKey:kSecAttrAccessGroup] forKey:@"AccessGroup"];
#endif
        NSData *data = [attributes objectForKey:kSecValueData];
        NSString *string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        if (string) {
            [attrs setObject:string forKey:@"Value"];
        } else {
            [attrs setObject:data forKey:@"Value"];
        }
        [list addObject:attrs];
    }
    
    return [list description];
}

@end
