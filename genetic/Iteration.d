/**
 * Iteration strategy templates.
 */

module genetic.Iteration;

/**
 * Iterate for n generations
 *
 * Template params:
 *      n = The number of generations to iterate for
 *
 * Params:
 *      iteration = The iteration delegate
 */

template IterateN ( uint n )
{
    alias IterateDg = void delegate ( );

    void runIteration ( IterateDg iteration )
    {
        while ( this.generation < n )
        {
            this.generation++;

            iteration();
        }
    }
}


/*template IterateN ( uint n )
{
    template IterateN ( alias Iterate )
    {
        static assert(is(typeof(generation) == uint),
            "Iteration requires a local uint called generation");

        void iterate ( )
        {
            while ( generation < iterations )
            {
                generation++;

                Iterate();
            }
        }
    }
}*/
