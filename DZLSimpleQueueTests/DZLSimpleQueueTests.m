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
  for (int i = 1; i <= 20; i++) {
    [queue addBlockToQueue:^{
      numberOfOperationsStarted++;
      dispatch_semaphore_signal(sem);
      while(1){};
    }];
  }
  
  for (int i = 1; i <= 3; i++) {
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
  }
  
  // ensure the queue has 20 operations in it
  XCTAssertEqual(queue.numberOfOperations, 20, @"number of queued operations should be 20, got %zd", queue.numberOfOperations);
  
  // ensure 3 of the operations have started
  XCTAssertEqual(numberOfOperationsStarted, 3, @"number of started operations should be 3, got %zd", numberOfOperationsStarted);
}

- (void)testCancellation
{
  DZLSimpleQueue *queue = [DZLSimpleQueue simpleQueueWithMaxConcurrentOperationCount:3];
  
  __block NSUInteger numberOfOperationsStarted = 0;
  __block NSUInteger numberOfOperationsCompleted = 0;
  
  dispatch_semaphore_t sem = dispatch_semaphore_create(0);
  
  id<DZLSimpleQueueOperation> operation = nil;
  
  // load up the queue with 20 operations
  for (NSUInteger i = 1; i <= 20; i++) {
    id<DZLSimpleQueueOperation> op = [queue addBlockToQueue:^{
      numberOfOperationsStarted = i;
      dispatch_semaphore_signal(sem);
      while(1){};
    }];
    
    op.completionHandler = ^{
      numberOfOperationsCompleted++;
    };
    
    if (!operation) {
      operation = op;
    }
  }
  
  for (int i = 1; i <= 3; i++) {
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
  }
  
  // cancel first operation
  [operation cancel];
  
  dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
  
  // ensure the queue has 19 operations in it
  XCTAssertEqual(queue.numberOfOperations, 19, @"number of queued operations should be 19, got %zd", queue.numberOfOperations);
  
  // ensure 4 of the operations have started
  XCTAssertEqual(numberOfOperationsStarted, 4, @"number of started operations should be 4, got %zd", numberOfOperationsStarted);
  
  // ensure no of the operations have completed
  XCTAssertEqual(numberOfOperationsCompleted, 0, @"number of completed operations should be 0, got %zd", numberOfOperationsCompleted);
}

@end
