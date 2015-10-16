//
//  LoggerHelper.h
//  invi
//
//  Created by Noam on 2/5/13.
//  Copyright (c) 2013 invi. All rights reserved.
//

#define LOG_ESC_CH         "\033"

typedef enum {
    LogLevelDebug       = 0,
    LogLevelInfo,
    LogLevelWarning,
    LogLevelError,
    LogLevelCritical    = 99
} LogLevel;

#ifdef DEBUG
# define MIN_LOG_LEVEL       LogLevelDebug
#elif defined FORCE_DEBUGGING
# define MIN_LOG_LEVEL       LogLevelDebug
#else
# define MIN_LOG_LEVEL       LogLevelError
#endif

#if defined (__cplusplus)
extern "C" {
#endif
    
void _Log_print(LogLevel logLevel, const char* fileName, const char* funcName, unsigned line, int processID, const char* log);
    
#if defined (__cplusplus)
}
#endif

#if defined (DEBUG) || defined (FORCE_DEBUGGING)
# define DebugLog(f, ...)   _Log_print(LogLevelDebug, __FILE__, __FUNCTION__, __LINE__, [[NSProcessInfo processInfo] processIdentifier], [[NSString stringWithFormat:f, ##__VA_ARGS__] UTF8String])
# define DLog(f, ...)       _Log_print(LogLevelDebug, __FILE__, __FUNCTION__, __LINE__, [[NSProcessInfo processInfo] processIdentifier], [[NSString stringWithFormat:f, ##__VA_ARGS__] UTF8String])
# define InfoLog(f, ...)    _Log_print(LogLevelInfo, __FILE__, __FUNCTION__, __LINE__, [[NSProcessInfo processInfo] processIdentifier], [[NSString stringWithFormat:f, ##__VA_ARGS__] UTF8String])
# define ILog(f, ...)       _Log_print(LogLevelInfo, __FILE__, __FUNCTION__, __LINE__, [[NSProcessInfo processInfo] processIdentifier], [[NSString stringWithFormat:f, ##__VA_ARGS__] UTF8String])
# define WarnLog(f, ...)    _Log_print(LogLevelWarning, __FILE__, __FUNCTION__, __LINE__, [[NSProcessInfo processInfo] processIdentifier], [[NSString stringWithFormat:f, ##__VA_ARGS__] UTF8String])
# define WLog(f, ...)       _Log_print(LogLevelWarning, __FILE__, __FUNCTION__, __LINE__, [[NSProcessInfo processInfo] processIdentifier], [[NSString stringWithFormat:f, ##__VA_ARGS__] UTF8String])
# define ErrorLog(f, ...)   _Log_print(LogLevelError, __FILE__, __FUNCTION__, __LINE__, [[NSProcessInfo processInfo] processIdentifier], [[NSString stringWithFormat:f, ##__VA_ARGS__] UTF8String])
# define ELog(f, ...)       _Log_print(LogLevelError, __FILE__, __FUNCTION__, __LINE__, [[NSProcessInfo processInfo] processIdentifier], [[NSString stringWithFormat:f, ##__VA_ARGS__] UTF8String])
# define CriticalLog(f, ...)   _Log_print(LogLevelCritical, __FILE__, __FUNCTION__, __LINE__, [[NSProcessInfo processInfo] processIdentifier], [[NSString stringWithFormat:f, ##__VA_ARGS__] UTF8String])
# define CLog(f, ...)       _Log_print(LogLevelCritical, __FILE__, __FUNCTION__, __LINE__, [[NSProcessInfo processInfo] processIdentifier], [[NSString stringWithFormat:f, ##__VA_ARGS__] UTF8String])
#else // DEBUG
# define DebugLog(f, ...)
# define DLog(f, ...)
# define InfoLog(f, ...)
# define ILog(f, ...)
# define WarnLog(f, ...)
# define WLog(f, ...)
# define ErrorLog(f, ...)   _Log_print(LogLevelError, __FILE__, __FUNCTION__, __LINE__, [[NSProcessInfo processInfo] processIdentifier], [[NSString stringWithFormat:f, ##__VA_ARGS__] UTF8String])
# define ELog(f, ...)       _Log_print(LogLevelError, __FILE__, __FUNCTION__, __LINE__, [[NSProcessInfo processInfo] processIdentifier], [[NSString stringWithFormat:f, ##__VA_ARGS__] UTF8String])
# define CriticalLog(f, ...)   _Log_print(LogLevelCritical, __FILE__, __FUNCTION__, __LINE__, [[NSProcessInfo processInfo] processIdentifier], [[NSString stringWithFormat:f, ##__VA_ARGS__] UTF8String])
# define CLog(f, ...)       _Log_print(LogLevelCritical, __FILE__, __FUNCTION__, __LINE__, [[NSProcessInfo processInfo] processIdentifier], [[NSString stringWithFormat:f, ##__VA_ARGS__] UTF8String])
#endif // DEBUG

