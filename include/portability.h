

#ifndef THORSANVIL_PORTABILITY_H
#define THORSANVIL_PORTABILITY_H




#if (__GNUG__ == 4) && (__GNUC_PATCHLEVEL__ == 3) && (__GNUC_MINOR__ == 6)

#define PORTABILITY_TESTED

#if (__GXX_EXPERIMENTAL_CXX0X__ > 0)

#define SMART_OWNED_PTR_TYPE_STD_UNIQUE_PTR  1

#else

#define SMART_OWNED_PTR_TYPE_STD_AUTO_PTR    1

#endif

#endif




#ifndef PORTABILITY_TESTED
#error "UNTESTED VERSION: Need to check portability file"
#endif

#if ((SMART_OWNED_PTR_TYPE_STD_AUTO_PTR + SMART_OWNED_PTR_TYPE_STD_UNIQUE_PTR) == 1)
#if (SMART_OWNED_PTR_TYPE_STD_AUTO_PTR)

#define     SMART_OWNED_PTR     std::auto_ptr
#define     SMART_OWNED_MOVE(A) A

#elif (SMART_OWNED_PTR_TYPE_STD_UNIQUE_PTR)

#define     SMART_OWNED_PTR     std::unique_ptr
#define     SMART_OWNED_MOVE(A) std::move(A)

#endif // SMART_OWNED_PTR_TYPE_STD_AUTO_PTR

#ifndef SMART_OWNED_PTR

#error  "Need to define SMART_OWNED_PTR"
#error  "Between C++03 and C++11 std::auto_ptr was deprecated."
#error  "To make code portable use SMART_OWNED_PTR in place of std::auto_ptr"

#endif // SMART_OWNED_PTR
#endif // ((SMART_OWNED_PTR_TYPE_STD_AUTO_PTR + SMART_OWNED_PTR_TYPE_STD_UNIQUE_PTR) == 1)




#endif // THORSANVIL_PORTABILITY_H

