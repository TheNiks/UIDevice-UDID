# UIDevice-UUID

UIDevice-UDID is a replacement for the now deprecated `[[UIDevice currentDevice] uniqueIdentifier]` method. It is designed to be code compatible generating a string of the same number of characters, that should be unique per device.  It isn't a drop-in replacement for fear of monkey patching over Apple's own methods. However you are free to rename the `UDID` method to `uniqueIdentifier` if you like (at your own risk).

No black magic, just a sha1 hash of the user's `en0` MAC address.  The SHA1 function is included in a separate .h/.m in case you'd like to use it independently. A method to get the user's MAC address (used to generate the UDID) is also exposed, in case you need it.

There are no `release`/`retain`/`autorelease` calls so it should work with or without ARC.

No rights reserved, this code is in the public domain. Do with it as you please.


## Usage

    #import "UIDevice+UDID.h"
    
    // later in your code
    
    // for a true unique device identifier
    NSLog(@"UDID: %@", [[UIDevice currentDevice] UDID]);
    
    // for a unique device identifier just for your apps
    NSLog(@"UDID with custom salt: %@", [[UIDevice currentDevice] UDIDWithSalt:@"some secret key"]);
    
    // for a unique device identifier just for this specific app
    NSLog(@"UDID with bundle-id salt: %@", [[UIDevice currentDevice] UDIDWithSalt:[[NSBundle mainBundle] bundleIdentifier]]);

    // get the user's mac address (I probably wouldn't recommend using this as your UDID)
    NSLog(@"MAC Address %@", [[UIDevice currentDevice]  macAddressForInterface:nil]);

    
    
## Resources

The following sources provided useful code snippets for this little library:

[Generating a SHA1 hash on iPhone][1]
[Getting the users Mac address][2]

[1]: http://stackoverflow.com/a/1084497/72176
[2]: https://github.com/gekitz/UIDevice-with-UniqueIdentifier-for-iOS-5/blob/master/Classes/UIDevice%2BIdentifierAddition.m