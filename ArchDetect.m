#import "ArchDetect.h"
#include <sys/sysctl.h>

@implementation ArchDetect

+ (void)initialize {
    [NSClassFromString(@"MobileFFmpegConfig") class];
    [NSClassFromString(@"MobileFFmpeg") class];
}

+ (NSString *)getCpuArch {
    NSMutableString *result = [[NSMutableString alloc] init];

    int cpuType = 0;
    int cpuSubtype = 0;
    size_t len = 4;

    sysctlbyname("hw.cputype", &cpuType, &len, NULL, 0);
    len = 4;
    sysctlbyname("hw.cpusubtype", &cpuSubtype, &len, NULL, 0);

    if (cpuType == 0x100000c) {
        [result appendString:@"arm64"];
        if (cpuSubtype == 1) {
            [result appendString:@"v8"];
        }
    }
    else if (cpuType == 0x1000007) {
        [result appendString:@"x86_64"];
    }
    else if (cpuType == 7) {
        [result appendString:@"x86"];
        switch (cpuSubtype) {
            case 3:
                [result appendString:@"_64all"];
                break;
            case 4:
                [result appendString:@"_arch1"];
                break;
            case 8:
                [result appendString:@"_64h"];
                break;
            default:
                break;
        }
    }
    else if (cpuType == 0xc) {
        [result appendString:@"arm"];
        switch (cpuSubtype) {
            case 5:
                [result appendString:@"v4t"];
                break;
            case 6:
                [result appendString:@"v6"];
                break;
            case 7:
                [result appendString:@"v5tej"];
                break;
            case 8:
                [result appendString:@"xscale"];
                break;
            case 9:
                [result appendString:@"v7"];
                break;
            case 10:
                [result appendString:@"v7f"];
                break;
            case 0xb:
                [result appendString:@"v7s"];
                break;
            case 0xc:
                [result appendString:@"v7k"];
                break;
            case 0xd:
                [result appendString:@"v8"];
                break;
            case 0xe:
                [result appendString:@"v6m"];
                break;
            case 0xf:
                [result appendString:@"v7m"];
                break;
            case 0x10:
                [result appendString:@"v7em"];
                break;
            default:
                break;
        }
    }
    else {
        [result appendString:[NSString stringWithFormat:@"%d", cpuType]];
    }

    return result;
}

+ (NSString *)getArch {
    NSMutableString *result = [[NSMutableString alloc] init];
    [result appendString:@"arm64"];
    return result;
}

+ (int)isLTSBuild {
    return 1;
}

@end
