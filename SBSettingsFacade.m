#import "SBSettingsFacade.h"

@implementation SBSettingsFacade
-(SBSettingsFacade*)initWithDomain:(id)domain notifyChanges:(bool)notifyChanges {
    return [self initWithDomain:domain containerPath:nil notifyChanges:notifyChanges];
}

-(SBSettingsFacade*)initWithDomain:(id)domain containerPath:(NSURL*)containerPath {
    return [self initWithDomain:domain containerPath:containerPath notifyChanges:nil];
}

-(SBSettingsFacade*)initWithDomain:(id)domain containerPath:(NSURL*)containerPath notifyChanges:(bool)notifyChanges {
    self = [super init];
    if (self) {
        _domain = [domain copy];
        _containerPath = [containerPath copy];
        _prefs = [TVSPreferences preferencesWithDomain:_domain];
        _defaultValues = [[NSMutableDictionary alloc] init];
        _defaultValue = @NO;
        _handlers = [[NSMutableDictionary alloc] init];
        if (notifyChanges) {
            [[TVSPreferenceManager sharedInstance] enableDistributedSyncForDomain:_domain];
        }
    }
    return self;
}

-(id)valueForUndefinedKey:(NSString*)key {
    id value;
    if (_containerPath) {
        value = (__bridge_transfer id)_CFPreferencesCopyAppValueWithContainer((__bridge CFStringRef)key, (__bridge CFStringRef)_domain, (__bridge CFURLRef)_containerPath);
    } else {
        value = [_prefs objectForKey:key];
    }

    SBSettingsGetterBlock handler = _handlers[key][@"getter"];
    if (handler) {
        // Calls block with key and the value from prefs
        return handler(key, value);
    }

    // Default everything to off - default value could be set as an instance variable
    if (value == nil) value = [_defaultValue copy];
    return value;
}

-(void)setValue:(id)value forUndefinedKey:(NSString*)key {
    SBSettingsSetterBlock handler = _handlers[key][@"setter"];
    if (handler) {
        // Calls setter with the key and value, saves returned value to defaults - return nil to save nothing
        value = handler(key, value);
    }
    if (_containerPath) {
        _CFPreferencesSetAppValueWithContainer((__bridge CFStringRef)key, (__bridge CFTypeRef)value, (__bridge CFStringRef)_domain, (__bridge CFURLRef)_containerPath);
        _CFPreferencesAppSynchronizeWithContainer((__bridge CFStringRef)_domain, (__bridge CFURLRef)_containerPath);
        _CFPreferencesPostValuesChangedInDomains((__bridge CFArrayRef)@[_domain]);
        GSSendAppPreferencesChanged((__bridge CFStringRef)_domain, (__bridge CFTypeRef)value);
    } else {
        [_prefs setObject:value forKey:key];
    }
}

-(void)registerDefaultValue:(id)value forKey:(NSString*)key {
    _defaultValues[key] = [value copy];
}

-(void)setGetter:(SBSettingsGetterBlock)block forKey:(NSString*)key {
    [self setGetter:block andSetter:_handlers[key][@"setter"] forKey:key];
}

-(void)setSetter:(SBSettingsSetterBlock)block forKey:(NSString*)key {
    [self setGetter:_handlers[key][@"getter"] andSetter:block forKey:key];
}
-(void)setGetter:(SBSettingsGetterBlock)getBlock andSetter:(SBSettingsGetterBlock)setBlock forKey:(NSString*)key {
    NSMutableDictionary *handlers;
    @synchronized (_handlers) {
        handlers = [_handlers objectForKey:key];
        if (handlers==nil) {
            handlers = [[NSMutableDictionary alloc] init];
            _handlers[key] = handlers;
        }
    }
    handlers[@"setter"] = setBlock;
    handlers[@"getter"] = getBlock;
}
@end
