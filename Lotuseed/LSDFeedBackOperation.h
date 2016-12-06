//
//  LSDFeedBackOperation.h
//  Lotuseed
//
//  Created by apple on 16/9/13.
//
//
#ifdef LOTUSEED_FEED
#import "LSDOnlineOperation.h"

@interface LSDFeedBackOperation : LSDOnlineOperation

{
@private

    id _delegate;
    SEL _selector;
}

@property (nonatomic, retain) NSString  *message;
@property (nonatomic, retain) NSString  *fileName;
@property (nonatomic, retain) NSData  *fileData;
@property (nonatomic, retain) NSString  *posterTime;
@property (nonatomic, retain) NSString  *posterAge;
@property (nonatomic, retain) NSString  *posterGender;
@property (nonatomic, retain) NSString  *posterContact;


- (id)initWithMessageID:(int)ID withMessage:(NSString *)message withFileName:(NSString *)fileName withFileData:(NSData *)fileData withPostTime:(NSString *)postTime withPosterAge:(NSString *)posterAge withPosterGender:(NSString *)posterGender withPosterContact:(NSString *)posterContact;

- (void)setSelector:(SEL)selector toTarget:(id)delegate;

@end
#endif
