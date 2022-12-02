// OpenMP program 
// using C language 
  
// OpenMP header 

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <omp.h> 

/*****************************************************************************/
void multMatrix(const int *A, const int *B, int *C, int numElements, int XDIM, int YDIM, int num_threads)
{
  int i, x, j;
  
  omp_set_num_threads(num_threads);
  #pragma omp parallel
  {
    int id,nthrds, pos;
    id = omp_get_thread_num();
    nthrds = omp_get_num_threads();  

    for (int j = id; j<YDIM; j=j+nthrds){
      for(x = 0; x < XDIM; x++)
      {   
          pos=(XDIM*j)+x;
          *(C + pos) = 0;
          for(i = 0; i < XDIM; i++){
              *(C + pos) = *(C + pos) + (*(A + (j*XDIM) + i)  * (*(B + (i*YDIM) + x )));
          }
      }  
    }
  }
}


/*****************************************************************************/

int printMatrix(int *ap, int XDIM, int YDIM)
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
    
    int N = atoi(argv[1]);
    int NUMTHREADS = atoi(argv[2]);
    int XDIM = N;
    int YDIM = N;
    int MATRIXSIZE = XDIM*YDIM;
    
    int i, v=0;
    int numElements = MATRIXSIZE;
    size_t size = MATRIXSIZE * sizeof(int);
    if(v == 1) printf("[Matrix mult of %d elements]\n", numElements);

    int *h_A = (int *)malloc(size);
    int *h_B = (int *)malloc(size);
    int *h_C = (int *)malloc(size);
    
    for(i = 0; i < MATRIXSIZE; i++){
        *(h_A + i) = rand() & 0xF;
        *(h_B + i) = rand() & 0xF;        
        *(h_C + i) = 0;
    }

	      printf("\n");
    multMatrix(h_A, h_B, h_C, numElements, XDIM, YDIM, NUMTHREADS);

    printMatrix(h_C, XDIM, YDIM);

    // Free host memory
    free(h_A);
    free(h_B);
    free(h_C);

    return 0;
}

