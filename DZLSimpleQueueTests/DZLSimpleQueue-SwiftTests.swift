//
//  DZLSimpleQueue-SwiftTests.swift
//  DZLSimpleQueue
//
//  Created by Sam Dods on 03/06/2014.
//  Copyright (c) 2014 Sam Dods. All rights reserved.
//

import XCTest

class DZLSimpleQueueSwiftTests: XCTestCase {
  
  func testMaxConcurrentOperations() {
    
    var queue = DZLSimpleQueue(maxCount: 3);
    var numberOfOperationsStarted = 0;
    var sem = dispatch_semaphore_create(0);
    
    // load up the queue with 20 operations
    for i in 1...20 {
      queue.addBlock {
        numberOfOperationsStarted = i;
        dispatch_semaphore_signal(sem);
        while 1==1 {};
      };
    }
    
    
    for i in 1...3 {
      dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    // ensure 20 operations are in the queue
    XCTAssert(queue.numberOfOperations == 20, "should be 20 operations in the queue, got \(queue.numberOfOperations)")
    
    // ensure 3 of the operations have started
    XCTAssert(numberOfOperationsStarted == 3, "should be 3 operations started, got \(numberOfOperationsStarted)")
    
  }
  
  func testCancellation() {
    
    var queue = DZLSimpleQueue(maxCount: 3);
    var numberOfOperationsStarted = 0;
    var numberOfOperationsCompleted: Int = 0;
    var sem = dispatch_semaphore_create(0);
    
    var operation: DZLSimpleQueueOperationProtocol?

    // load up the queue with 20 operations
    for i in 1...20 {
      var op = queue.addBlock {
        numberOfOperationsStarted = i;
        dispatch_semaphore_signal(sem);
        while 1==1 {};
      };
      
      op.completionHandler = {
        numberOfOperationsCompleted = numberOfOperationsCompleted + 1;
      }
      
      if !operation {
        operation = op
      }
    }
    
    
    for i in 1...3 {
      dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    // cancel first operation
    operation!.cancel()
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    
    // ensure 20 operations are in the queue
    XCTAssert(queue.numberOfOperations == 19, "should be 19 operations in the queue, got \(queue.numberOfOperations)")
    
    // ensure 3 of the operations have started
    XCTAssert(numberOfOperationsStarted == 4, "should be 4 operations started, got \(numberOfOperationsStarted)")
    
    // ensure no operations have completed
    XCTAssert(numberOfOperationsCompleted == 0, "should be 0 operations completed, got \(numberOfOperationsCompleted)")
    
  }
  
}
