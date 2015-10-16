//
//  LoggerHelper.m
//  invi
//
//  Created by Noam on 2/5/13.
//  Copyright (c) 2013 invi. All rights reserved.
//

#include <pthread.h>


#import <Foundation/Foundation.h>

#import "LoggerHelper.h"

const char* logLevelTag(LogLevel logLevel) {
    const char* tag = "";
    switch (logLevel) {
        case LogLevelDebug: tag = "DEBUG"; break;
        case LogLevelInfo: tag = "INFO"; break;
        case LogLevelWarning: tag = "WARNING"; break;
        case LogLevelError: tag = "ERROR"; break;
        case LogLevelCritical: tag = "CRITICAL"; break;
    }
    
    return tag;
}

void _Log_getFileName(const char* path, char* name) {
    long l = strlen(path);
    while (--l >= 0 && path[l] != '/') {}
    strcpy(name, path + (l >= 0 ? l + 1 : 0));
}

void _Log_print(LogLevel logLevel, const char* fileName, const char* funcName, unsigned line, int processID, const char* log) {
    if (logLevel < MIN_LOG_LEVEL)
        return;
    
    mach_port_t machTID = pthread_mach_thread_np(pthread_self());
    
    char* file = (char*)malloc(sizeof(char) * strlen(fileName));
    _Log_getFileName(fileName, file);
    
    NSMutableString* logMessage = [NSMutableString new];
    [logMessage appendFormat:@"[%s]  ", logLevelTag(logLevel)];
    [logMessage appendFormat:@"%s:%u %s [0x%x:0x%x]  ", file, line, funcName, processID, machTID];          // fileName
    [logMessage appendFormat:@"%s", log];
    
#ifdef DEBUG
    printf("%s\n", [[logMessage copy] UTF8String]);
#else // DEBUG
    BFLog(@"%@", [logMessage copy]);
#endif // DEBUG
    
    free(file);
}
