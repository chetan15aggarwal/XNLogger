//
//  NLLoader.m
//  NetworkLogger
//
//  Created by Sunil Sharma on 22/07/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

//#import "NLLoader.h"
#import "NetworkLogger/NetworkLogger-Swift.h"

@interface NLLoader : NSObject

@end

@implementation NLLoader

+ (void)load {
    [[NetworkLogger shared] startLogging];
    NLConsoleLogHandler *consoleHandler = [NLConsoleLogHandler create];
    [[NetworkLogger shared] addLogHandlers: @[consoleHandler]];
    NLHostFilter *hostFilter = [[NLHostFilter alloc] initWithHost: @"t.appsflyer.com"];
    [[NetworkLogger shared] addFilters: @[hostFilter]];
    (void)[NLUIManager shared];
}


@end
