#include <stdio.h>
#include <stdlib.h>

int main(void) {
    char *text = malloc(16);
    if (!text) return 1;
    snprintf(text, 16, "%d", 42);
    int result = puts(text) < 0;
    free(text);
    return result;
}
