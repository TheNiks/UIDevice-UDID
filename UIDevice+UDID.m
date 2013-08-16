// UIDevice+UDID
// Created by William Denniss
// Public domain. No rights reserved.

#import "UIDevice+UDID.h"

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import "NSString+SHA1.h"

#undef IS_IOS7
#define IS_IOS7()  ([[UIApplication sharedApplication] respondsToSelector:@selector(setMinimumBackgroundFetchInterval:)])

//#define IS_IOS7()  (true)  // uncomment to test iOS7 behavior

#define kUIDeviceMacKey  @"UIDevice+UDID:MacAddress"
#define kUIDeviceVendorIdentifierKey @"UIDevice+UDID:identifierForVendor"

@implementation UIDevice (UDID)

- (NSString*) cachedMacAddressOrVendorIdentifier
{
	NSString* identifierForVendor = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
	
	if (IS_IOS7())
	{
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		// if a mac address was previously recorded, and the device it was recorded on is the current device, returns it
		if ([defaults objectForKey:kUIDeviceMacKey] && [defaults objectForKey:kUIDeviceVendorIdentifierKey] && [[defaults objectForKey:kUIDeviceVendorIdentifierKey] isEqualToString:identifierForVendor])
		{
			return [defaults objectForKey:kUIDeviceMacKey];
		}
		
		// else returns the identifierForVendor
		return identifierForVendor;
	}
	else
	{
		NSString* macAddress = [self macAddressForInterface:nil];

		// saves the mac address & associated identifierForVendor for future use on iOS 7
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:macAddress forKey:kUIDeviceMacKey];
		[defaults setObject:identifierForVendor forKey:kUIDeviceVendorIdentifierKey];
		[defaults synchronize];
		
		return macAddress;
	}
}

// returns the local MAC address.
- (NSString*) macAddressForInterface:(NSString*)interfaceNameOrNil
{
    // uses en0 as the default interface name
    NSString* interfaceName = interfaceNameOrNil;
    if (interfaceName == nil)
    {
        interfaceName = @"en0";
    }
    
    // code snippet via Georg Kitz, via FreeBSD hackers email list 
    // ref: https://github.com/gekitz/UIDevice-with-UniqueIdentifier-for-iOS-5/blob/master/Classes/UIDevice%2BIdentifierAddition.m
        
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex([interfaceName UTF8String])) == 0)
    {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0)
    {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL)
    {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0)
    {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr*) buf;
    sdl = (struct sockaddr_dl*) (ifm + 1);
    ptr = (unsigned char*) LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", 
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}

// returns a 40 char string that is the sha1 hash of the user's en0 MAC address
- (NSString*) UDID
{
    return [[self cachedMacAddressOrVendorIdentifier] sha1];
}

// gets a salted UDID. For a per-application UDID, you could use [[NSBundle mainBundle] bundleIdentifier]
- (NSString*) UDIDWithSalt:(NSString*)salt
{
  return [[NSString stringWithFormat:@"%@%@", [self cachedMacAddressOrVendorIdentifier], salt] sha1];
}

@end
