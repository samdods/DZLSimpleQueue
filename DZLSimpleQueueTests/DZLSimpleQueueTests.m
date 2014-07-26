//
//  DZLSimpleQueueTests.m
//  DZLSimpleQueueTests
//
//  Created by Sam Dods on 25/07/2014.
//  Copyright (c) 2014 Dodzilla. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DZLSimpleQueue.h"

@interface DZLSimpleQueueTests : XCTestCase

@end

@implementation DZLSimpleQueueTests

- (void)testMaxConcurrentOperationCount
{
  DZLSimpleQueue *queue = [DZLSimpleQueue simpleQueueWithMaxConcurrentOperationCount:3];
  
  __block NSUInteger numberOfOperationsStarted = 0;
  
  dispatch_semaphore_t sem = dispatch_semaphore_create(0);
  
  // load up the queue with 20 operations
  for (int i = 0; i < 20; i++) {
    [queue addBlockToQueue:^{
      numberOfOperationsStarted++;
      dispatch_semaphore_signal(sem);
      while(1){};
    }];
  }
  
  for (int i = 0; i < 3; i++) {
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
  }
  
  // ensure the queue has 20 operations in it
  XCTAssertEqual(queue.numberOfOperations, 20, @"number of queued operations should be 20");
  
  // ensure 3 of the operations have started
  XCTAssertEqual(numberOfOperationsStarted, 3, @"number of started operations should be 3");
}

- (void)testCancellation
{
  DZLSimpleQueue *queue = [DZLSimpleQueue simpleQueueWithMaxConcurrentOperationCount:3];
  
  __block NSUInteger numberOfOperationsStarted = 0;
  
  dispatch_semaphore_t sem = dispatch_semaphore_create(0);
  
  id<DZLSimpleQueueOperation> operation = nil;
  
  // load up the queue with 20 operations
  for (int i = 0; i < 20; i++) {
    id op = [queue addBlockToQueue:^{
      numberOfOperationsStarted++;
      dispatch_semaphore_signal(sem);
      while(1){};
    }];
    if (!operation) {
      operation = op;
    }
  }
  
  for (int i = 0; i < 3; i++) {
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
  }
  
  // cancel first operation
  [operation cancel];
  
  dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
  
  // ensure the queue has 19 operations in it
  XCTAssertEqual(queue.numberOfOperations, 19, @"number of queued operations should be 19");
  
  // ensure 4 of the operations have started
  XCTAssertEqual(numberOfOperationsStarted, 4, @"number of started operations should be 4");
}

@end
