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
    var numberOfOperationsStarted: UInt = 0;
    var sem = dispatch_semaphore_create(0);
    
    // load up the queue with 20 operations
    for i in 0..20 {
      queue.addBlock {
        numberOfOperationsStarted++;
        dispatch_semaphore_signal(sem);
        while 1==1 {};
      };
    }
    
    
    for i in 0..3 {
      dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    // ensure 20 operations are in the queue
    XCTAssert(queue.numberOfOperations == 20, "should be 20 operations in the queue")
    
    // ensure 3 of the operations have started
    XCTAssert(numberOfOperationsStarted == 3, "should be 3 operations started")
    
    
  }
  
  func testCancellation() {
    
    var queue = DZLSimpleQueue(maxCount: 3);
    var numberOfOperationsStarted: UInt = 0;
    var sem = dispatch_semaphore_create(0);
    
    var operation: DZLSimpleQueueOperationProtocol?

    // load up the queue with 20 operations
    for i in 0..20 {
      var op = queue.addBlock {
        numberOfOperationsStarted++;
        dispatch_semaphore_signal(sem);
        while 1==1 {};
      };
      
      if !operation {
        operation = op
      }
    }
    
    
    for i in 0..3 {
      dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    // cancel first operation
    operation!.cancel()
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    
    // ensure 20 operations are in the queue
    XCTAssert(queue.numberOfOperations == 19, "should be 19 operations in the queue")
    
    // ensure 3 of the operations have started
    XCTAssert(numberOfOperationsStarted == 4, "should be 4 operations started")
    
    
  }
  
}
