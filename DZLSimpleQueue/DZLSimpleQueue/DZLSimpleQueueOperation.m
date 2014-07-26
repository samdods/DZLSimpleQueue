//
//  DZLSimpleQueueOperation.m
//  Times
//
//  Created by Sam Dods on 25/07/2014.
//  Copyright (c) 2014 The App Business. All rights reserved.
//

#import "DZLSimpleQueueOperation.h"

@interface DZLSimpleQueueOperation ()
@property (nonatomic, strong) dispatch_source_t dispatchSource;
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation DZLSimpleQueueOperation

+ (instancetype)operationWithBlock:(void (^)(void))block
{
  return [[self alloc] initWithBlock:block];
}

- (instancetype)initWithBlock:(void (^)(void))block
{
  self = [super init];
  if (self) {
    __weak typeof (self) weakSelf = self;
    _queue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL);
    _dispatchSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);
    dispatch_source_set_timer(_dispatchSource, DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_dispatchSource, ^{
      !block ?: block();
      [self.delegate operation:weakSelf didComplete:NO];
    });
  }
  return self;
}

- (id)init
{
  NSAssert1(NO, @"Call +%@ to create", NSStringFromSelector(@selector(operationWithBlock:)));
  return nil;
}

- (void)start
{
  dispatch_resume(self.dispatchSource);
}

- (void)cancel
{
  dispatch_source_cancel(self.dispatchSource);
  [self.delegate operation:self didComplete:YES];
}

@end
