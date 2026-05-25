#include "llama_bridge.h"
#include <string.h>
static int initialized = 0;
int llama_init(const char* model_path) {
    initialized = 1;
    return 0;
}
int llama_inference(const char* input, char* output, int output_size) {
    if (!initialized) return -1;
    const char* stub = "{\"humorous\":\"test\",\"warm\":\"test\",\"interactive\":\"test\"}";
    strncpy(output, stub, output_size - 1);
    output[output_size - 1] = \\0;
    return (int)strlen(output);
}
void llama_free(void) { initialized = 0; }
