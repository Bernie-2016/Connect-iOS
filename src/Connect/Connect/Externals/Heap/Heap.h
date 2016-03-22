//
//  Heap.h
//  Version 2.2.2
//  Copyright (c) 2014 Heap Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Heap : NSObject

// Return the version number of the Heap library.
+ (NSString * const)libVersion;

// Return the Heap-generated user ID of the current user.
+ (NSString * const)userId;

// Set the app ID for your project, and begin tracking events automatically.
+ (void)setAppId:(NSString *)newAppId;

// Enable Event Visualizer. Allows capturing events in-app.
+ (void)enableVisualizer;

// Start/stop debug mode. Displays Heap activity via NSLog.
+ (void)startDebug;
+ (void)stopDebug;

// Attach meta-level properties to the user (e.g. email, handle).
+ (void)identify:(NSDictionary *)properties;

// Track a custom event with optional key-value properties.
+ (void)track:(NSString *)event;
+ (void)track:(NSString *)event withProperties:(NSDictionary *)properties;

// Attach custom key-value properties to all subsequent events.
+ (void)setEventProperties:(NSDictionary *)properties;
// Unset an event property to stop attaching it to events.
+ (void)unsetEventProperty:(NSString *)property;
// Unset all event properties.
+ (void)clearEventProperties;

// Change the frequency at which data is sent to Heap. Default is 15 seconds.
+ (void)changeInterval:(double)interval;

@end
