#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "MKBMocking.h"
#import "MKBTestExpectation.h"
#import "MKBTestUtils.h"
#import "MKBTypeFacade.h"
#import "Mockingbird.h"
#import "MKBBoolInvocationHandler.h"
#import "MKBCharInvocationHandler.h"
#import "MKBClassInvocationHandler.h"
#import "MKBComparator.h"
#import "MKBCStringInvocationHandler.h"
#import "MKBDoubleInvocationHandler.h"
#import "MKBFloatInvocationHandler.h"
#import "MKBIntInvocationHandler.h"
#import "MKBInvocationHandler.h"
#import "MKBInvocationHandlerChain.h"
#import "MKBLongInvocationHandler.h"
#import "MKBLongLongInvocationHandler.h"
#import "MKBObjectInvocationHandler.h"
#import "MKBPointerInvocationHandler.h"
#import "MKBSelectorInvocationHandler.h"
#import "MKBShortInvocationHandler.h"
#import "MKBStructInvocationHandler.h"
#import "MKBUnsignedCharInvocationHandler.h"
#import "MKBUnsignedIntInvocationHandler.h"
#import "MKBUnsignedLongInvocationHandler.h"
#import "MKBUnsignedLongLongInvocationHandler.h"
#import "MKBUnsignedShortInvocationHandler.h"
#import "NSInvocation+MKBErrorObjectType.h"
#import "MKBClassMock.h"
#import "MKBConcreteMock.h"
#import "MKBProperty.h"
#import "MKBProtocolMock.h"

FOUNDATION_EXPORT double MockingbirdVersionNumber;
FOUNDATION_EXPORT const unsigned char MockingbirdVersionString[];

