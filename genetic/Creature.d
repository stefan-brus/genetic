/**
 * Creature template.
 *
 * A creature is a genome and a fitness function
 */

module genetic.Creature;

/**
 * Template for a creature.
 *
 * The genome can be directly accessed through alias this.
 *
 * Template params:
 *      Gene = The genome type
 *      GenomeLength = The length of the genome
 *      FitnessFn = The fitness function
 *      MutateFn = The mutation function
 */

struct Creature ( Gene, size_t GenomeLength, alias FitnessFn, alias MutateFn )
{
    import std.traits;

    /**
     * The genome.
     */

     Gene[GenomeLength] genome;

     alias genome this;

     /**
      * The fitness function
      */

    mixin FitnessFn;

    static assert(is(typeof(fitness)),
        "Fitness function must be called 'fitness'");

    static assert(is(ReturnType!fitness == double),
        "Return type of fitness function must be double");

    static assert(ParameterTypeTuple!fitness.length == 0,
        "Fitness function must take no arguments");

    /**
     * The mutatation function
     */

    mixin MutateFn;

    static assert(is(typeof(mutate)),
        "Mutation function must be called 'mutate'");

    static assert(is(ReturnType!mutate == void),
        "Return type of mutation function must be void");

    static assert(ParameterTypeTuple!mutate.length == 1,
        "Mutation function must take 1 argument");

    static assert(is(ParameterTypeTuple!mutate[0] == size_t),
        "Mutation function argument must be of type size_t");
}
