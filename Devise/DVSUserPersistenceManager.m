//
//  DVSUserPersistenceManager.m
//  Devise
//
//  Created by Wojciech Trzasko on 13.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "DVSUserPersistenceManager.h"
#import <UICKeyChainStore/UICKeyChainStore.h>
#import "DVSConfiguration.h"
#import "DVSUser+Persistence.h"

@interface DVSUserPersistenceManager ()

@property (strong, nonatomic, readwrite) DVSConfiguration *configuration;

@end

@implementation DVSUserPersistenceManager

@synthesize localUser = _localUser;

#pragma mark - Lifecycle

- (instancetype)initWithConfiguration:(DVSConfiguration *)configuration {
    if (self = [super init]) {
        self.configuration = configuration;
    }
    return self;
}

+ (instancetype)defaultPersistanceManager {
    return [[[self class] alloc] initWithConfiguration:[DVSConfiguration sharedConfiguration]];
}

#pragma mark - Accessors

- (DVSUser *)localUser {
    return _localUser ? : (_localUser = [self persistentUser]);
}

- (void)setLocalUser:(DVSUser *)user {
    [self removePersistentUser];
    _localUser = user;
    if (_localUser) [self savePersistentUser:_localUser];
}

#pragma mark - Persistent helpers

- (void)savePersistentUser:(DVSUser *)user {
    NSString *keychainService = self.configuration.keychainServiceName;
    NSString *keychainKey = self.configuration.resourceName;
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:user];
    [UICKeyChainStore setData:archivedData forKey:keychainKey service:keychainService];
}

- (void)removePersistentUser {
    NSString *keychainService = self.configuration.keychainServiceName;
    NSString *keychainKey = self.configuration.resourceName;
    [UICKeyChainStore removeItemForKey:keychainKey service:keychainService];
}

- (DVSUser *)persistentUser {
    NSString *keychainService = self.configuration.keychainServiceName;
    NSString *keychainKey = self.configuration.resourceName;
    NSData *archivedData = [UICKeyChainStore dataForKey:keychainKey service:keychainService];
    return [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
}


@end
