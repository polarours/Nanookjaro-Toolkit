#pragma once

#if defined(_WIN32)
#  if defined(NANOOKJARO_CORE_BUILD)
#    define NANOOKJARO_API __declspec(dllexport)
#  else
#    define NANOOKJARO_API __declspec(dllimport)
#  endif
#else
#  define NANOOKJARO_API __attribute__((visibility("default")))
#endif
