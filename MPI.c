// OpenMP program 
// using C language 
  
// OpenMP header 

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <omp.h> 
#include <mpi.h>

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
int main(int argc, char *argv[]){   
    
    int N = atoi(argv[1]);
    int NUMTHREADS = atoi(argv[2]);
    int XDIM = N;
    int YDIM = N;
    int MATRIXSIZE = XDIM*YDIM;
    
    int i, v=0;
    size_t size = MATRIXSIZE * sizeof(int);

    int *h_A = (int *)malloc(size);
    int *h_B = (int *)malloc(size);
    int *h_C = (int *)malloc(size);
    
    for(i = 0; i < MATRIXSIZE; i++){
        *(h_A + i) = rand() & 0xF;
        *(h_B + i) = rand() & 0xF;        
        *(h_C + i) = 0;
    }

    int i, pid, npr;
    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &npr);
    MPI_Comm_rank(MPI_COMM_WORLD, &pid);
    
    for (int j = pid; j < YDIM; j += npr){
      for(int x = 0; x < XDIM; x++)
      {   
          int pos = (XDIM * j) + x;
          *(h_C + pos) = 0;
          for(i = 0; i < XDIM; i++){
              *(h_C + pos) = *(h_C + pos) + (*(h_A + (j*XDIM) + i) * 
                              (*(h_B + (i*YDIM) + x )));
          }
      }  
    }

    MPI_Finalize();

    printMatrix(h_C, XDIM, YDIM);

    // Free memory
    free(h_A);
    free(h_B);
    free(h_C);

    return 0;
}

