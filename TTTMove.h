//
//  TTTMove.h
//  AlphaBeta
//
//  Created by Stig Brautaset on 11/12/2005.
//  Copyright 2005 Stig Brautaset. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTTMove : NSObject {
    int col;
    int row;
}
- (TTTMove *)initWithX:(int)x andY:(int)y;
- (int)x;
- (int)y;
- (NSString *)string;
@end
