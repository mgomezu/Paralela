gcc -o openmp -fopenmp openMP.c
nvcc CUDA.cu -o cuda
sudo mpicc -o mpi MPI.c

./openmp 1024 1
./cuda 1024 64
./mpirun -np 4 --hostfile mpi_hosts ./mpi 1024