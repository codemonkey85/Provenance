//
//  PVTGBDualCore+Saves.h
//  PVTGBDual
//
//  Created by error404-na on 12/31/18.
//  Copyright © 2018 Provenance. All rights reserved.
//

#import "PVTGBDualBridge.h"

@interface PVTGBDualBridge (Saves)

- (BOOL)loadSaveFile:(NSString *)path forType:(int)type;
- (BOOL)writeSaveFile:(NSString *)path forType:(int)type;

@end
