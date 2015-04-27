// CA_ValueTransformer.h
// 
// Copyright (c) 2015 Tiago Flores
//
// Based on Mantle's MTLValueTransformer, MIT licensed.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>

typedef id (^CA_ValueTransformerBlock)(id value);

/**
 Generic block-based value transformer.
 */
@interface CA_ValueTransformer : NSValueTransformer

/**
 Returns a transformer which transforms values using the given block. Reverse transformations will not be allowed.
 */
+ (instancetype)transformerWithBlock:(CA_ValueTransformerBlock)block;

/**
 Returns a transformer which transforms values using the given block, for forward or reverse transformations.
 */
+ (instancetype)reversibleTransformerWithBlock:(CA_ValueTransformerBlock)block;

/**
 Returns a transformer which transforms values using the given blocks.
 */
+ (instancetype)reversibleTransformerWithForwardBlock:(CA_ValueTransformerBlock)forwardBlock reverseBlock:(CA_ValueTransformerBlock)reverseBlock;

@end
