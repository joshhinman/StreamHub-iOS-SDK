//
//  LFClientTests.m
//  LFClientTests
//
//  Created by zjj on 1/14/13.
//
//  Copyright (c) 2013 Livefyre
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.

#import "LFClientTests.h"
#import "LFPublicAPIClient.h"
#import "LFBootstrapClient.h"
#import "LFWriteClient.h"
#import "LFStreamClient.h"
#import "LFAdminClient.h"
#import "LFConstants.h"
#import "Config.h"

@interface LFClientTests()
@property (strong, nonatomic) Config *config;
@property (nonatomic) NSString *event;
@end

@implementation LFClientTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testCollectionRetrieval {
    __block NSDictionary *coll;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    [LFBootstrapClient getInitForArticle:@"integration test collection 1357158021"
                                  inSite:[Config objectForKey:@"site"]
                             withNetwork:[Config objectForKey:@"domain"]
                         withEnvironment:[Config objectForKey:@"environment"]
                                 success:^(NSDictionary *collection) {
                                     coll = collection;
                                     dispatch_semaphore_signal(sema);
                                 }
                                 failure:^(NSError *error) {
                                     if (error)
                                         NSLog(@"Error code %d, with desciption %@", error.code, [error localizedDescription]);
                                     dispatch_semaphore_signal(sema);
                                 }];
    
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
    STAssertEquals([coll count], 4u, @"Collection dictionary should have 4 keys");
    self.event = [[coll objectForKey:@"collectionSettings"] objectForKey:@"event"];
    NSLog(@"Got init bootstrap data");
}

- (void)testHeatAPICalls {
    __block NSArray *res;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);

    [LFPublicAPIClient getTrendingCollectionsForTag:@"tag"
                                             inSite:[Config objectForKey:@"site"]
                                          onNetwork:[Config objectForKey:@"domain"]
                                     desiredResults:10
                                            success:^(NSArray *results) {
                                                res = results;
                                                dispatch_semaphore_signal(sema);
                                            } failure:^(NSError *error) {
                                                NSLog(@"Error code %d, with desciption %@", error.code, [error localizedDescription]);
                                                dispatch_semaphore_signal(sema);
                                            }];
 
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
    STAssertEquals([res count], 10u, @"Heat API should return 10 items");
    NSLog(@"Got trending collections");
}

- (void)testUserDataRetrieval {
    __block NSArray *res;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [LFPublicAPIClient getUserContentForUser:@"system"
                                   withToken:nil
                                   onNetwork:@"labs-t402.fyre.co"
                                 forStatuses:nil
                                  withOffset:nil
                                     success:^(NSArray *results) {
                                         res = results;
                                         dispatch_semaphore_signal(sema);
                                   } failure:^(NSError *error) {
                                        NSLog(@"Error code %d, with desciption %@", error.code, [error localizedDescription]);
                                        dispatch_semaphore_signal(sema);
                                   }];
    
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));

    STAssertEquals([res count], 12u, @"User content API should return 12 items");
    NSLog(@"Got user data");
}

- (void)testUserAuthentication {
    //with article and site ids
    __block NSDictionary *res;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    NSString *userToken = [Config objectForKey:@"moderator user auth token"];
    
    [LFAdminClient authenticateUserWithToken:userToken
                                     forSite:[Config objectForKey:@"site"]
                                  forArticle:@"integration test collection 1357158021"
                               forCollection:nil
                                   onNetwork:[Config objectForKey:@"domain"]
                                     success:^(NSDictionary *gotUserData) {
                                         res = gotUserData;
                                         dispatch_semaphore_signal(sema);
                                     } failure:^(NSError *error) {
                                         NSLog(@"Error code %d, with desciption %@", error.code, [error localizedDescription]);
                                         dispatch_semaphore_signal(sema);
                                     }];
    
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
    //lazy
    STAssertEqualObjects([res objectForKey:@"status"], @"ok", @"This response should have been ok");
    NSLog(@"Authenticated user w/ site and article.");
    
    //with collection id
    res = nil;    
    [LFAdminClient authenticateUserWithToken:userToken
                                     forSite:nil
                                  forArticle:nil
                               forCollection:@"10665123"
                                   onNetwork:[Config objectForKey:@"domain"]
                                     success:^(NSDictionary *gotUserData) {
                                         res = gotUserData;
                                         dispatch_semaphore_signal(sema);
                                     } failure:^(NSError *error) {
                                         NSLog(@"Error code %d, with desciption %@", error.code, [error localizedDescription]);
                                         dispatch_semaphore_signal(sema);
                                     }];
    
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
    //lazy
    STAssertEqualObjects([res objectForKey:@"status"], @"ok", @"This response should have been ok");
    NSLog(@"Authenticated user w/ collection.");
}

- (void)testLikes {
    __block NSDictionary *res;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    NSString *userToken = [Config objectForKey:@"moderator user auth token"];

    [LFWriteClient likeContent:@"26373227"
                       forUser:userToken
                  inCollection:@"10665123"
                     onNetwork:[Config objectForKey:@"domain"]
                       success:^(NSDictionary *content) {
                           res = content;
                           dispatch_semaphore_signal(sema);
                       } failure:^(NSError *error) {
                           NSLog(@"Error code %d, with desciption %@", error.code, [error localizedDescription]);
                           dispatch_semaphore_signal(sema);
                       }];
    
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
    STAssertEqualObjects([res objectForKey:@"status"], @"ok", @"This response should have been ok");
    NSLog(@"Liiiiiiiked");
    
    res = nil;
    [LFWriteClient unlikeContent:@"26373227"
                       forUser:userToken
                  inCollection:@"10665123"
                     onNetwork:[Config objectForKey:@"domain"]
                       success:^(NSDictionary *content) {
                           res = content;
                           dispatch_semaphore_signal(sema);
                       } failure:^(NSError *error) {
                           NSLog(@"Error code %d, with desciption %@", error.code, [error localizedDescription]);
                           dispatch_semaphore_signal(sema);
                       }];
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
    STAssertEqualObjects([res objectForKey:@"status"], @"ok", @"This response should have been ok");
    NSLog(@"UnnnnnnnnnLiiiiiiiked");
}

- (void)testPost {
    __block NSDictionary *res;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    NSString *userToken = [Config objectForKey:@"moderator user auth token"];
    NSUInteger ran = arc4random();
    
    [LFWriteClient postContent:[NSString stringWithFormat:@"test post, %d", ran]
                       forUser:userToken
                     inReplyTo:nil
                  inCollection:@"10665123"
                     onNetwork:[Config objectForKey:@"domain"]
                       success:^(NSDictionary *content) {
                           res = content;
                           dispatch_semaphore_signal(sema);
                       } failure:^(NSError *error) {
                           NSLog(@"Error code %d, with desciption %@", error.code, [error localizedDescription]);
                           dispatch_semaphore_signal(sema);
                       }];
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
    STAssertEqualObjects([res objectForKey:@"status"], @"ok", @"This response should have been ok");
    NSLog(@"Successfully posted");
    
    //in reply to
    NSString *parent = @"26373228";
    ran = arc4random();
    [LFWriteClient postContent:[NSString stringWithFormat:@"test reply, %d", ran]
                       forUser:userToken
                     inReplyTo:parent
                  inCollection:@"10665123"
                     onNetwork:[Config objectForKey:@"domain"]
                       success:^(NSDictionary *content) {
                           res = content;
                           dispatch_semaphore_signal(sema);
                       } failure:^(NSError *error) {
                           NSLog(@"Error code %d, with desciption %@", error.code, [error localizedDescription]);
                           dispatch_semaphore_signal(sema);
                       }];
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
    NSString *prent = [[[[[res objectForKey:@"data"] objectForKey:@"messages"] objectAtIndex:0] objectForKey:@"content"] objectForKey:@"parentId"];
    STAssertEqualObjects(prent, parent, @"This response should have been a child.");
    NSLog(@"Successfully posted in reply");
    
    //share to
//    ran = arc4random();
//    [LFWriteClient postContent:[NSString stringWithFormat:@"test reply, %d", ran]
//                       forUser:userToken
//                     inReplyTo:nil
//                       shareTo:@[kShareTypeTwitter]
//                  inCollection:@"10665123"
//                     onNetwork:[Config objectForKey:@"domain"]
//                       success:^(NSDictionary *content) {
//                           res = content;
//                           dispatch_semaphore_signal(sema);
//                       } failure:^(NSError *error) {
//                           NSLog(@"Error code %d, with desciption %@", error.code, [error localizedDescription]);
//                           dispatch_semaphore_signal(sema);
//                       }];
//    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
//    STAssertEqualObjects(prent, parent, @"This response should have been a child.");
//    NSLog(@"Successfully posted w/ shareTo");
}

- (void)testStream {
    __block NSDictionary *res;
    //__block NSUInteger trips = 3;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    LFStreamClient *streamer = [LFStreamClient new];
    [streamer startStreamForCollection:@"10665123"
                             fromEvent:@"2648462675" //the past
                             onNetwork:[Config objectForKey:@"domain"]
                               success:^(NSDictionary *updates) {
                                   res = updates;
//                                   trips--;
//                                   if (trips == 0)
                                    dispatch_semaphore_signal(sema);
                               } failure:^(NSError *error) {
                                   NSLog(@"Error code %d, with desciption %@", error.code, [error localizedDescription]);
                                   dispatch_semaphore_signal(sema);
                               }];
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    NSLog(@"Successfully streamed");
    
    [streamer stopStreamForCollection:@"10665123"];
}

@end
