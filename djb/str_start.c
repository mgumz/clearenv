#include "str.h"
#include <stddef.h>

int str_start(const char* s, const char* p) {

    size_t i = 0;
    for (i = 0;; ++i) {
        if (!p[i]) { return 1; }
        if (s[i] != p[i]) { break; }
    }
    return 0;
}
