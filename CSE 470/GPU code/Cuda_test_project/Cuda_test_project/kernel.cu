
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <vector>
#include <stdio.h>

cudaError_t Bellmanford(int *out, std::vector<int> V, std::vector<int> I, std::vector<int> E, std::vector<int> W, int blockSize);
cudaError_t test(std::vector<int> V, std::vector<int> I, std::vector<int> E, std::vector<int> W, int times);


__global__ void arrayInit(int* a, int size, int pos);
__global__ void relax(int size, int* c_V, int* c_I, int* c_E, int* c_W, int* d_V, int* d_P, int* d_I);
__global__ void copy(int size, int* d_V, int* d_I);
__global__ void pred(int size, int* c_I, int* c_E, int* c_W, int* d_V, int* d_P);


int main() {
    int times = 1;
    std::vector<int> V = { 0, 1, 2 };
    std::vector<int> I = { 0, 2, 3, 4 };
    std::vector<int> E = { 1, 2, 2, 1};
    std::vector<int> W = { 0, 0, 3, -2 };
    if (test(V, I, E, W, times) != cudaSuccess) return 1;

    V = {0, 1, 2, 3, 4};
    I = { 0, 2, 5, 6, 8, 10 };
    E = { 1, 3, 2, 3, 4, 1, 2, 4, 0, 2 };
    W = { 6, 7, 5, 8, -4, -2, -3, 9, 2, 7 };
    if (test(V, I, E, W, times) != cudaSuccess) return 1;

    V = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19};
    I = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20};
    E = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 0};
    W = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  -10};
    if (test(V, I, E, W, times) != cudaSuccess) return 1;

    return 0;
}

cudaError_t test(std::vector<int> V, std::vector<int> I, std::vector<int> E, std::vector<int> W, int times) {
    cudaEvent_t start, stop;
    int out[20] = { 0 };
    float total = 0.0;
    int blockSize = 16;
    for (int i = 0; i < times; i++) {
        cudaEventCreate(&start);
        cudaEventCreate(&stop);

        cudaEventRecord(start);

        cudaError_t cudaStatus = Bellmanford(out, V, I, E, W, blockSize);
        cudaEventRecord(stop);

        cudaEventSynchronize(stop);
        float milliseconds = 0;
        cudaEventElapsedTime(&milliseconds, start, stop);

        if (cudaStatus != cudaSuccess) {
            fprintf(stderr, "Bellmanford failed!");
            return cudaStatus;
        }

        cudaStatus = cudaDeviceReset();
        if (cudaStatus != cudaSuccess) {
            fprintf(stderr, "cudaDeviceReset failed!");
            return cudaStatus;
        }
        total += milliseconds;
    }
    printf("{%d", out[0]);
    for (int i = 1; i < V.size(); i++) {
        printf(",%d", out[i]);
    }
    printf("}\n");
    total = total / times;
    printf("%d runs took %f ms\n", times, total);
    return cudaSuccess;
}

cudaError_t Bellmanford(int* out, std::vector<int> V, std::vector<int> I, std::vector<int> E, std::vector<int> W, int blockSize) {
    int *c_V, *c_I, *c_E, *c_W, *d_V, *d_P, *d_I;
    cudaError_t cudaStatus;

    cudaStatus = cudaSetDevice(0);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaSetDevice failed!  Do you have a CUDA-capable GPU installed?");
        goto Error;
    }

    cudaStatus = cudaMalloc((void**)&c_V, V.size() * sizeof(int));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    cudaStatus = cudaMalloc((void**)&c_I, I.size() * sizeof(int));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    cudaStatus = cudaMalloc((void**)&c_E, E.size() * sizeof(int));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    cudaStatus = cudaMalloc((void**)&c_W, W.size() * sizeof(int));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    cudaStatus = cudaMalloc((void**)&d_V, V.size() * sizeof(int));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    cudaStatus = cudaMalloc((void**)&d_P, V.size() * sizeof(int));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    cudaStatus = cudaMalloc((void**)&d_I, V.size() * sizeof(int));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    cudaStatus = cudaMemcpy(c_V, V.data(), V.size() * sizeof(int), cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed");
        goto Error;
    }

    cudaStatus = cudaMemcpy(c_I, I.data(), I.size() * sizeof(int), cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed");
        goto Error;
    }

    cudaStatus = cudaMemcpy(c_E, E.data(), E.size() * sizeof(int), cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed");
        goto Error;
    }

    cudaStatus = cudaMemcpy(c_W, W.data(), W.size() * sizeof(int), cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed");
        goto Error;
    }

    int num_blocks = (V.size() + blockSize - 1) / blockSize;
    arrayInit <<<num_blocks, blockSize>>>(d_V, V.size(), 0);
    cudaStatus = cudaGetLastError();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "arrayInit launch failed: %s\n", cudaGetErrorString(cudaStatus));
        goto Error;
    }

    arrayInit <<<num_blocks, blockSize>>>(d_P, V.size(), 0);
    cudaStatus = cudaGetLastError();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "arrayInit launch failed: %s\n", cudaGetErrorString(cudaStatus));
        goto Error;
    }

    arrayInit<<<num_blocks, blockSize>>>(d_I, V.size(), 0);
    cudaStatus = cudaGetLastError();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "arrayInit launch failed: %s\n", cudaGetErrorString(cudaStatus));
        goto Error;
    }

    for (int i = 0; i < I.size() - 2; i++) {
        relax<<<num_blocks, blockSize>>>(V.size(), c_V, c_I, c_E, c_W, d_V, d_P, d_I);
        cudaStatus = cudaGetLastError();
        if (cudaStatus != cudaSuccess) {
            fprintf(stderr, "relax launch failed: %s\n", cudaGetErrorString(cudaStatus));
            goto Error;
        }

        copy<<<num_blocks, blockSize>>>(V.size(), d_V, d_I);
        cudaStatus = cudaGetLastError();
        if (cudaStatus != cudaSuccess) {
            fprintf(stderr, "copy launch failed: %s\n", cudaGetErrorString(cudaStatus));
            goto Error;
        }
    }

    pred<<<num_blocks, blockSize>>>(V.size(), c_I, c_E, c_W, d_V, d_P);
    cudaStatus = cudaGetLastError();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "pred launch failed: %s\n", cudaGetErrorString(cudaStatus));
        goto Error;
    }

    cudaStatus = cudaMemcpy(out, d_V, V.size() * sizeof(int), cudaMemcpyDeviceToHost);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }


Error:
    cudaFree(c_V);
    cudaFree(c_I);
    cudaFree(c_E);
    cudaFree(c_W);
    cudaFree(d_V);
    cudaFree(d_P);
    cudaFree(d_I);

    return cudaStatus;

}
__global__ void arrayInit(int *a, int size, int pos) {
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    if (index < size) {
        a[index] = index == pos ? 0 : INT_MAX;
    }
}

__global__ void relax(int size, int* c_V, int* c_I, int* c_E, int* c_W, int* d_V, int* d_P, int* d_I) {
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    if (index < size) {
        if (d_V[index] != INT_MAX) {
            for (int i = c_I[index]; i < c_I[index + 1]; i++) {
                int dis = d_V[index] + c_W[i];
                atomicMin(&d_I[c_E[i]], dis);
            }
        }
    }
}

__global__ void copy(int size, int* d_V, int* d_I) {
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    if (index < size) {
        d_V[index] = d_I[index];
    }
}

__global__ void pred(int size, int* c_I, int* c_E, int* c_W, int* d_V, int* d_P) {
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    if (index < size) {
        for (int i = c_I[index]; i < c_I[index + 1]; i++) {
            int dis = d_V[index] + c_W[i];
            if (dis <= d_V[c_E[i]]) {
                if (dis == d_V[c_E[i]]) {
                    d_P[c_E[i]] = index; // don't care which parent just that there is one
                }
            }
        }
    }
}


