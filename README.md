Sample Code:
```
-(id)loadSettingGroups  {
    NSMutableArray *_backingArray = [NSMutableArray new];
    NSMutableArray *items = [NSMutableArray new];
    [items addObject: [TSKSettingItem toggleItemWithTitle:@"Custom Key"
                                              description:@"Do something cool"
                                        representedObject:facade
                                                  keyPath:@"CustomValueKey"
                                                  onTitle:nil
                                                 offTitle:nil]];
    SBSettingsFacade *facade = [[SBSettingsFacade alloc] initWithDomain:@"com.code.sample" notifyChanges:TRUE];
    [facade setGetter:^(NSString *key, id value) {
        return customGetter(key, value);
    } andSetter:^(NSString *key, id value) {
        customSetter(key, value);
        return (id)nil;
    } forKey:@"CustomValueKey"];
    [items addObject: [TSKSettingItem multiValueItemWithTitle:@"Interpreted Key"
                                                  description:@"Do something else cool"
                                            representedObject:facade
                                                      keyPath:@"InterpretedKey"
                                              availableValues:@[@"Sure!", @"Unset", @"No Way!"]]];
    [facade setGetter:^(NSString *key, id value) {
        if (value == nil) {
            return @"Unset";
        }
        return [value boolValue]?@"Sure!":@"No Way!";
    } andSetter:^(NSString *key, id value) {
        if ([value isEqualToString:@"Sure!"]) {
            value = @YES;
        } else if ([value isEqualToString:@"Unset"]) {
            value = nil;
        } else if ([value isEqualToString:@"No Way!"]) {
            value = @NO;
        } else {
            [NSException raise:NSInternalInconsistencyException format:@"Invalid option passed to InterpretedKey"];
        }
        return value;
    } forKey:@"InterpretedKey"];
    [_backingArray addObject:[TSKSettingGroup groupWithTitle:nil settingItems:items]];
    [self setValue:_backingArray forKey:@"_settingGroups"];
    return _backingArray;
}
```
