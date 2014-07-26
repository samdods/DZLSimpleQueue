//
//  DZLSimpleQueue.m
//  Times
//
//  Created by Sam Dods on 25/07/2014.
//  Copyright (c) 2014 The App Business. All rights reserved.
//

#import "DZLSimpleQueue.h"
#import "DZLSimpleQueueOperation.h"

@interface DZLSimpleQueue () <DZLSimpleQueueOperationDelegate>
@property (nonatomic, strong, readonly) dispatch_semaphore_t semaphore;
@property (nonatomic, assign, readwrite) NSUInteger numberOfOperations;
@end

@implementation DZLSimpleQueue

+ (instancetype)simpleQueueWithMaxConcurrentOperationCount:(NSUInteger)maxCount
{
  return [[self alloc] initWithMaxCount:maxCount];
}

- (instancetype)initWithMaxCount:(NSUInteger)maxCount
{
  self = [super init];
  if (self) {
    _maxConcurrentOperationCount = maxCount;
    _semaphore = dispatch_semaphore_create(maxCount);
    _numberOfOperations = 0;
  }
  return self;
}

- (id)init
{
  NSAssert1(NO, @"Call +%@ to create", NSStringFromSelector(@selector(simpleQueueWithMaxConcurrentOperationCount:)));
  return nil;
}

- (void)dealloc
{
  while (_numberOfOperations > 0) {
    _numberOfOperations--;
    dispatch_semaphore_signal(_semaphore);
  }
  _semaphore = nil;
}

- (id<DZLSimpleQueueOperation>)addBlockToQueue:(void (^)(void))block
{
  NSAssert(block != nil, @"Must pass block");
  if (!block) {
    return nil;
  }
  DZLSimpleQueueOperation *operation = [DZLSimpleQueueOperation operationWithBlock:block];
  operation.delegate = self;
  
  __weak typeof(self) weakSelf = self;
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    dispatch_semaphore_wait(weakSelf.semaphore, DISPATCH_TIME_FOREVER);
    [operation start];
  });
  
  self.numberOfOperations++;
  
  return operation;
}

- (void)operation:(DZLSimpleQueueOperation *)operation didComplete:(BOOL)wasCancelled
{
  dispatch_semaphore_signal(self.semaphore);
  self.numberOfOperations--;
}

@end
