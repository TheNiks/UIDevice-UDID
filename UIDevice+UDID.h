// UIDevice+UDID
// Created by William Denniss
// Public domain. No rights reserved.

#import <Foundation/Foundation.h>

@interface UIDevice (UDID)

- (NSString*) macAddressForInterface:(NSString*)interfaceNameOrNil __attribute__ ((deprecated));
- (NSString*) UDID;
- (NSString*) UDIDWithSalt:(NSString*)salt;
- (NSString*) cachedMacAddressOrVendorIdentifier;

@end
