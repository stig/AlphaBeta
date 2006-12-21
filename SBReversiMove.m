/*
Copyright (C) 2006 Stig Brautaset. All rights reserved.

This file is part of SBAlphaBeta.

SBAlphaBeta is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

SBAlphaBeta is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with SBAlphaBeta; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

*/

#import "SBReversiMove.h"

@implementation SBReversiMove

- (id)initWithCol:(int)x andRow:(int)y
{
    if (self = [super init]) {
        col = x;
        row = y;
    }
    return self;
}

+ (id)moveWithCol:(int)x andRow:(int)y
{
    return [[[self alloc] initWithCol:x andRow:y] autorelease];
}

- (int)col
{
    return col;
}

- (int)row
{
    return row;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"(%d,%d)", col, row];
}

@end
