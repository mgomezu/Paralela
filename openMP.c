// OpenMP program 
// using C language 
  
// OpenMP header 
#include <omp.h>   
#include <stdio.h> 
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <string.h>
  

int main(int argc, char* argv[]) 
{   
    int N = atoi(argv[1]);
    int num_threads = atoi(argv[2]);
    int matrizA[N][N];
    int matrizB[N][N];

    for (int i=0; i<N; i++){
      for (int j=0; j<N; j++){
        matrizA[i][j] = rand();
        matrizB[i][j] = rand();
      }
    }

    int producto[N][N];
    omp_set_num_threads(num_threads);
    #pragma omp parallel
    {
      int id,nthrds;
      double x;
      id = omp_get_thread_num();
      nthrds = omp_get_num_threads();
      for (int a = id; a < N; a=a+nthrds) {
          // Dentro recorremos las filas de la primera (A)
          for (int i = 0; i < N; i++) {
              int suma = 0;
              // Y cada columna de la primera (A)
              for (int j = 0; j < N; j++) {
                  // Multiplicamos y sumamos resultado
                  suma += matrizA[i][j] * matrizB[j][a];
              }
              // Lo acomodamos dentro del producto
              producto[i][a] = suma;
          }
      }

    }
    // Ending of parallel region

    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
          printf("%d ", producto[i][j]);
        }
          printf("\\n");
    } 
}
