//
//  ARC4.h
//  LivefyreClient
//
//  Created by Thomas Goyne on 5/17/12.
//
//  Copyright (c) 2013 Livefyre
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.

#import <Foundation/Foundation.h>

@interface LFARC4 : NSObject
/** @name eref decoding. */

/** 
 * A method to assist with decoding content erefs using a Livefyre user's key or keys.
 *
 * @param eref The eref to attempt to decode.
 * @param keys The keys to apply to the encoded content.
 * @return NSString
 */
+ (NSString *)tryToDecodeEref:(NSString *)eref withKeys:(NSArray *)keys;

/**
 * A method to assist with decoding Livefyre content ciphers.
 * @param string The cipher text.
 * @param key The secret key.
 * @return NSString
 */
+ (NSString *)decrypt:(NSString *)string withKey:(NSString *)key;
@end
