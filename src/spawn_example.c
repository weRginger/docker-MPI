#include "mpi.h"
#include <stdio.h>
#include <stdlib.h>

#define NUM_SPAWNS 16

int main( int argc, char *argv[] )
{
    int np = NUM_SPAWNS;
    int errcodes[NUM_SPAWNS];
    MPI_Comm parentcomm, intercomm;

    MPI_Init( &argc, &argv );
    
    int world_size;
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);
    
    int world_rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);

    char processor_name[MPI_MAX_PROCESSOR_NAME];
    int name_len;
    MPI_Get_processor_name(processor_name, &name_len);

    MPI_Info info;
    MPI_Info_create(&info);
    //MPI_Info_set(info, "add-hostfile", "myhosts");
    MPI_Info_set(info, "add-hostfile", "startinghosts");

    MPI_Comm_get_parent( &parentcomm );
    if (parentcomm == MPI_COMM_NULL)
    {
        MPI_Comm_spawn( "spawn_example", MPI_ARGV_NULL, np, info, 0, MPI_COMM_WORLD, &intercomm, errcodes );
        //MPI_Comm_spawn( "spawn_example", MPI_ARGV_NULL, np, MPI_INFO_NULL, 0, MPI_COMM_WORLD, &intercomm, errcodes );
        printf("I'm the parent");
        printf(" from processor %s, rank %d out of %d processors\n", processor_name, world_rank, world_size);
    }
    else
    {
        printf("I'm the spawned");
        printf(" from processor %s, rank %d out of %d processors\n", processor_name, world_rank, world_size);
    }
    fflush(stdout);
    MPI_Finalize();
    return 0;
}
