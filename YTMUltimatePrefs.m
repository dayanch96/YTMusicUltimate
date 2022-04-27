//
//  YTMUltimatePrefs.m
//  
//
//  Created by Noah Little on 17/8/21.
//

#import "YTMUltimatePrefs.h"

@implementation YTMUltimatePrefs

-(id)init{
    self = [super init];
    if (self){
        
    } return self;
}

+(id)sharedInstance{
    static YTMUltimatePrefs *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[YTMUltimatePrefs alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

@end
