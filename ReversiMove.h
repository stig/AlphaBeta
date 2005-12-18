//
//  ReversiMove.h
//  AlphaBeta
//
//  Created by Stig Brautaset on 18/12/2005.
//  Copyright 2005 Stig Brautaset. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ReversiMove : NSObject {
    int row;
    int col;
}
- (id)initWithCol:(int)x andRow:(int)y;
- (int)col;
- (int)row;
- (NSString *)string;
@end
