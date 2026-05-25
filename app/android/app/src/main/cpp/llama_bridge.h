#ifndef LLAMA_BRIDGE_H
#define LLAMA_BRIDGE_H
int llama_init(const char* model_path);
int llama_inference(const char* input, char* output, int output_size);
void llama_free(void);
#endif
