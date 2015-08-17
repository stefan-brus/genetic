/**
 * Configuration for a genetic algorithm problem solver.
 */

module genetic.Config;

/**
 * Aggregation of config fields.
 */

class SolverConfig
{
    /**
     * The size of the population.
     */

    immutable size_t population_size;

    /**
     * The chance to recombine a gene.
     */

    immutable double recombination_rate;

    /**
     * The chance to mutate a gene.
     */

    immutable double mutation_rate;

    /**
     * Constructor
     *
     * Params:
     *      population_size = The initial population size
     *      recombination_rate = The recombination rate
     *      mutation_rate = The mutation rate
     */

    this ( size_t population_size, double recombination_rate, double mutation_rate )
    {
        this.population_size = population_size;
        this.recombination_rate = recombination_rate;
        this.mutation_rate = mutation_rate;
    }
}
