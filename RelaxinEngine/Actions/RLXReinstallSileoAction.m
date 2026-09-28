//
//  RLXReinstallSileoAction.m
//  RelaxinEngine
//

#import "RLXActions.h"

#import "RLXActionRunner.h"
#import "../../RelaxinPostJailbreak/Actions/RLXPostJailbreakActionRunner.h"
#import "../Bootstrap/RLXBootstrapFinalizer.h"

#include <TargetConditionals.h>
#include <errno.h>
#include <libjailbreak/jbroot.h>

#if !TARGET_OS_SIMULATOR

NSError *_Nullable RLXReinstallSileo(NSBundle *resourceBundle, NSString *_Nullable __strong *_Nullable failurePhase) {
    __block NSError *installationError = nil;
    int status = RLXPostJailbreakRunAsEffectiveRoot(
        ^int {
            return RLXPostJailbreakRunUnsandboxed(
                ^int {
                    installationError = [RLXBootstrapFinalizer installBundledPackageNamed:@"sileo"
                                                                           resourceBundle:resourceBundle];
                    if (installationError) {
                        RLXPostJailbreakSetFailurePhase(failurePhase, @"install_sileo");
                        return EIO;
                    }
                    return 0;
                },
                failurePhase);
        },
        failurePhase);
    if (status == 0) {
        return nil;
    }
    return RLXActionExecutionError(RLXEngineActionReinstallSileo,
                                   failurePhase && *failurePhase ? *failurePhase : @"install_sileo",
                                   status,
                                   installationError);
}

NSError *_Nullable RLXReinstallPackageManager(
    NSBundle *resourceBundle,
    NSString *packageName,
    NSString *_Nullable __strong *_Nullable failurePhase
) {
    if (packageName.length == 0) {
        if (failurePhase) {
            *failurePhase = @"validate_package_manager";
        }
        return [NSError errorWithDomain:NSPOSIXErrorDomain
                                   code:EINVAL
                               userInfo:@{
                                   NSLocalizedDescriptionKey : @"A package manager name is required.",
                               }];
    }

    __block NSError *installationError = nil;
    int status = RLXPostJailbreakRunAsEffectiveRoot(
        ^int {
            return RLXPostJailbreakRunUnsandboxed(
                ^int {
                    installationError = [RLXBootstrapFinalizer installBundledPackageNamed:packageName
                                                                           resourceBundle:resourceBundle];
                    if (installationError) {
                        RLXPostJailbreakSetFailurePhase(
                            failurePhase,
                            [NSString stringWithFormat:@"install_%@", packageName]
                        );
                        return EIO;
                    }

                    if ([packageName isEqualToString:@"irisin"]) {
                        NSString *source = [resourceBundle pathForResource:@"irisin-default-list-managed"
                                                                       ofType:@"plist"];
                        NSString *destination = JBROOT_PATH(@"/Applications/irisin.app/default-list-managed.plist");
                        [NSFileManager.defaultManager removeItemAtPath:destination error:nil];
                        if (!source || ![NSFileManager.defaultManager copyItemAtPath:source
                                                                                 toPath:destination
                                                                                  error:nil]) {
                            RLXPostJailbreakSetFailurePhase(failurePhase, @"configure_irisin_sources");
                            return EIO;
                        }
                    }
                    return 0;
                },
                failurePhase);
        },
        failurePhase);
    if (status == 0) {
        return nil;
    }

    NSString *phase = failurePhase && *failurePhase
        ? *failurePhase
        : [NSString stringWithFormat:@"install_%@", packageName];
    return RLXActionExecutionError(RLXEngineActionReinstallPackageManager,
                                   phase,
                                   status,
                                   installationError);
}

#endif /* !TARGET_OS_SIMULATOR */
