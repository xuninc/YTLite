#import "YTPDB.h"

@implementation YTPDB

+ (id)thanks {
    return @"thanks";
}

+ (id)clip {
    return @"clip";
}

+ (id)report {
    return @"report";
}

+ (id)hype {
    return @"hype";
}

+ (id)stopAds {
    return @"stopAds";
}

+ (NSArray *)supportedLanguages {
    NSArray *localizations = [[NSBundle mainBundle] localizations];
    NSMutableArray *mutableLocalizations = [localizations mutableCopy];

    NSUInteger count = [mutableLocalizations count];
    if (count != 0) {
        NSUInteger i = 0;
        do {
            NSString *localization = [mutableLocalizations objectAtIndex:i];
            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:localization];
            NSString *displayName = [locale displayNameForKey:NSLocaleIdentifier value:localization];
            if (displayName != nil) {
                [mutableLocalizations replaceObjectAtIndex:i withObject:displayName];
            }
            i = i + 1;
            count = [mutableLocalizations count];
        } while (i < count);
    }

    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:mutableLocalizations];
    NSArray *allObjects = [orderedSet array];
    NSMutableArray *sortedArray = [allObjects mutableCopy];

    [sortedArray sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *result = [sortedArray copy];
    return result;
}

+ (NSString *)langCodeForIndex:(long long)index {
    NSArray *supportedLanguages = [self supportedLanguages];
    NSArray *localizations = [[NSBundle mainBundle] localizations];
    NSMutableArray *mutableLocalizations = [localizations mutableCopy];
    NSMutableDictionary *langMap = [NSMutableDictionary dictionary];

    for (NSString *localization in mutableLocalizations) {
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:localization];
        NSString *displayName = [locale displayNameForKey:NSLocaleIdentifier value:localization];
        if (displayName != nil) {
            NSString *existing = [langMap objectForKey:displayName];
            if (existing == nil) {
                [langMap setObject:localization forKey:displayName];
            }
        }
    }

    NSString *result = nil;
    if (index < 0) {
        result = nil;
    } else {
        NSUInteger count = [supportedLanguages count];
        if ((NSUInteger)index < count) {
            NSString *displayName = [supportedLanguages objectAtIndex:(NSUInteger)index];
            result = [langMap objectForKey:displayName];
        } else {
            result = nil;
        }
    }

    return result;
}

+ (unsigned long long)indexOfPreferredLanguage {
    NSArray *supportedLanguages = [self supportedLanguages];
    NSArray *localizations = [[NSBundle mainBundle] localizations];
    NSArray *preferredLanguages = [NSBundle preferredLocalizationsFromArray:localizations];
    NSString *preferredLang = [preferredLanguages firstObject];

    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:preferredLang];
    NSString *displayName = [locale displayNameForKey:NSLocaleIdentifier value:preferredLang];

    unsigned long long result = 0;
    if (displayName != nil) {
        NSUInteger foundIndex = [supportedLanguages indexOfObject:displayName];
        if (foundIndex != NSNotFound) {
            result = (unsigned long long)foundIndex;
        }
    }

    return result;
}

@end
