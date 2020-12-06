#import <Foundation/Foundation.h>
#import <GraphicsServices/GraphicsServices.h>
#import <TVServices/TVSPreferences.h>
#import <TVServices/TVSPreferenceManager.h>

extern CFTypeRef _CFPreferencesCopyAppValueWithContainer(CFStringRef key, CFStringRef applicationID, CFURLRef container);
extern void _CFPreferencesSetAppValueWithContainer(CFStringRef key, CFTypeRef value, CFStringRef applicationID, CFURLRef container);
extern void _CFPreferencesAppSynchronizeWithContainer(CFStringRef applicationID, CFURLRef container);
extern void _CFPreferencesPostValuesChangedInDomains(CFArrayRef domains);

typedef id (^SBSettingsGetterBlock)(NSString *key, id value);
typedef id (^SBSettingsSetterBlock)(NSString *key, id value);

@interface SBSettingsFacade : NSObject {
    TVSPreferences *_prefs;
    NSString *_domain;
    NSURL *_containerPath;
    NSMutableDictionary *_defaultValues;
    NSMutableDictionary *_handlers;
    id _defaultValue;
}
@property (readonly, copy, nonatomic) NSString *domain;
@property (readonly, copy, nonatomic) NSURL *containerPath;
@property (nonatomic, strong) id defaultValue;
-(SBSettingsFacade*)initWithDomain:(id)domain containerPath:(id)containerPath;
-(SBSettingsFacade*)initWithDomain:(id)domain notifyChanges:(bool)changes;
-(SBSettingsFacade*)initWithDomain:(id)domain containerPath:(id)containerPath notifyChanges:(bool)changes;
-(void)setValue:(id)value forUndefinedKey:(NSString*)key;
-(id)valueForUndefinedKey:(NSString*)key;
-(void)registerDefaultValue:(id)value forKey:(NSString*)key;
-(void)setGetter:(SBSettingsGetterBlock)block forKey:(NSString*)key;
-(void)setSetter:(SBSettingsSetterBlock)block forKey:(NSString*)key;
-(void)setGetter:(SBSettingsGetterBlock)getBlock andSetter:(SBSettingsGetterBlock)setBlock forKey:(NSString*)key;
@end
