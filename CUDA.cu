
#include <stdio.h>
#include <cuda_runtime.h>

#define DIM  64
#define XDIM  DIM
#define YDIM  DIM
#define MATRIXSIZE  XDIM*YDIM
#define BLOCKSPERGRID  16
#define NUMTHREADS DIM

/*****************************************************************************/
__global__ void multMatrix(const int *A, const int *B, int *C, int numElements)
{
	int yOffset;
    int i, x;
    __shared__ int rowAshared[XDIM][32];

    int y = blockDim.x * blockIdx.x + threadIdx.x;
    int yRel = y - (blockDim.x * blockIdx.x);

    yOffset = y * XDIM;
    for(i = 0; i < XDIM; i++)
        rowAshared[i][yRel] = *(A + yOffset + i);

    if (y < numElements)
    {
        for(x = 0; x < XDIM; x++)
        {   *(C + yOffset + x) = 0;
            for(i = 0; i < XDIM; i++){
                *(C + yOffset + x) = *(C + yOffset + x) + (rowAshared[i][yRel] * (*(B + (i*YDIM) + x )));
            }
        } 
    }
}


/*****************************************************************************/

int printMatrix(int *ap)
{
	int x, y;
	for(y = 0; y < YDIM; y++)
	{
		printf("\n");
		for(x = 0; x < XDIM; x++)
		{
		    printf("%i ", *(ap + (y*XDIM) + x));
		}
	}
	printf("\n");
return 0;
}


/******************************************************************************
 * Host main routine
 */
int main(int argc, char *argv[])
{   
    if (argc != 3) {
        cout << "Error en numero de parametros de entrada" << endl;
        exit(0);
    }
    else {
        int N = stoi(argv[1]);
        int NUMTHREADS = stoi(argv[2]);
        int threadsPerBlock = (N + NUMTHREADS - 1) / NUMTHREADS;
        int XDIM = N;
        int YDIM = N;
        INT MATRIXSIZE = XDIM*YDIM;
    }
    int i, v=0;
    int blocksPerGrid, threadsPerBlock;
    blocksPerGrid = BLOCKSPERGRID;
    // Error code to check return values for CUDA calls
    cudaError_t err = cudaSuccess;

    // Print the vector length to be used, and compute its size
    int numElements = MATRIXSIZE;
    size_t size = MATRIXSIZE * sizeof(int);
    if(v == 1) printf("[Matrix mult of %d elements]\n", numElements);

    // Allocate the host input vector A
    int *h_A = (int *)malloc(size);

    // Allocate the host input vector B
    int *h_B = (int *)malloc(size);

    // Allocate the host output vector C
    int *h_C = (int *)malloc(size);

    // Verify that allocations succeeded
    if (h_A == NULL || h_B == NULL || h_C == NULL)
    {
        fprintf(stderr, "Failed to allocate host vectors!\n");
        exit(EXIT_FAILURE);
    }

    // Initialize the host input vectors
    
    for(i = 0; i < MATRIXSIZE; i++){
        *(h_A + i) = rand() & 0xF;
        *(h_B + i) = rand() & 0xF;        
        *(h_C + i) = 0;
    }
    //printMatrix(h_A);
    //printMatrix(h_B);
    
    // Allocate the device input vector A
    int *d_A = NULL;
    err = cudaMalloc((void **)&d_A, size);

    if (err != cudaSuccess)
    {
        fprintf(stderr, "Failed to allocate device vector A (error code %s)!\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }

    // Allocate the device input vector B
    int *d_B = NULL;
    err = cudaMalloc((void **)&d_B, size);

    if (err != cudaSuccess)
    {
        fprintf(stderr, "Failed to allocate device vector B (error code %s)!\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }

    // Allocate the device output vector C
    int *d_C = NULL;
    err = cudaMalloc((void **)&d_C, size);

    if (err != cudaSuccess)
    {
        fprintf(stderr, "Failed to allocate device vector C (error code %s)!\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }
    

    // Copy the host input vectors A and B in host memory to the device input vectors in
    // device memory
    if(v == 1) printf("Copy input data from the host memory to the CUDA device\n");
    err = cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);

    if (err != cudaSuccess)
    {
        fprintf(stderr, "Failed to copy vector A from host to device (error code %s)!\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }

    err = cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);

    if (err != cudaSuccess)
    {
        fprintf(stderr, "Failed to copy vector B from host to device (error code %s)!\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }

    // Launch the Vector Add CUDA Kernel
    threadsPerBlock = NUMTHREADS/blocksPerGrid;
    //blocksPerGrid = BLOCKS; //(numElements + threadsPerBlock - 1) / threadsPerBlock;
    printf("CUDA kernel launch with %d blocks of %d threads\n", blocksPerGrid, threadsPerBlock);
    multMatrix<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_B, d_C, numElements);
    err = cudaGetLastError();

    if (err != cudaSuccess)
    {
        fprintf(stderr, "Failed to launch vectorAdd kernel (error code %s)!\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }

    // Copy the device result vector in device memory to the host result vector
    // in host memory.

    err = cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);

    if (err != cudaSuccess)
    {
        fprintf(stderr, "Failed to copy vector C from device to host (error code %s)!\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }


    // Free device global memory
    err = cudaFree(d_A);

    if (err != cudaSuccess)
    {
        fprintf(stderr, "Failed to free device vector A (error code %s)!\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }

    err = cudaFree(d_B);

    if (err != cudaSuccess)
    {
        fprintf(stderr, "Failed to free device vector B (error code %s)!\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }

    err = cudaFree(d_C);

    if (err != cudaSuccess)
    {
        fprintf(stderr, "Failed to free device vector C (error code %s)!\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }

    printMatrix(h_C);

    // Free host memory
    free(h_A);
    free(h_B);
    free(h_C);

    // Reset the device and exit
    // cudaDeviceReset causes the driver to clean up all state. While
    // not mandatory in normal operation, it is good practice.  It is also
    // needed to ensure correct operation when the application is being
    // profiled. Calling cudaDeviceReset causes all profile data to be
    // flushed before the application exits
    err = cudaDeviceReset();

    if (err != cudaSuccess)
    {
        fprintf(stderr, "Failed to deinitialize the device! error=%s\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }


    return 0;
}
