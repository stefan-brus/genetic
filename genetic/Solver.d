/**
 * Genetic algorithm solver module.
 */

module genetic.Solver;

import genetic.Config;
import genetic.Creature;

/**
 * Solver class.
 *
 * Template params:
 *      CreatureType = The creature type
 *      IterationStrategy = The iteration strategy to use
 *      StrategyArgs = The arguments to the strategy
 */

class Solver ( CreatureType, alias IterationStrategy, StrategyArgs ... )
{
    import std.traits;

    static assert(__traits(isSame, TemplateOf!(CreatureType), Creature),
        "Creature type must be genetic.Creature");

    /**
     * The solver configuration
     */

    private SolverConfig config;

    /**
     * The initial population
     */

    private CreatureType[] population;

    /**
     * The function to determine a winner of two creatures
     *
     * Params:
     *      is_winner = The creature to check whether it's a winner
     *      contender = The other creature
     *
     * Returns:
     *      True if the creature is a winner
     */

    private alias WinnerFn = bool function ( CreatureType is_winner, CreatureType contender );

    private WinnerFn winner;

    /**
     * The iteration strategy
     */

    mixin IterationStrategy!(StrategyArgs);

    /**
     * The current generation
     */

    private uint generation;

    /**
     * Constructor
     *
     * Params:
     *      config = The solver configuration
     *      winner = The winner determination function
     */

    this ( SolverConfig config, WinnerFn winner )
    {
        this.config = config;
        this.winner = winner;

        this.population.length = this.config.population_size;
    }

    /**
     * Run the solver
     */

    void run ( )
    {
        debug(SolverRun) import std.stdio;
        import std.traits;

        this.initPopulation();

        debug(SolverRun) writefln("Initialized population:");
        debug(SolverRun) writefln("%s", this.population);

        debug(SolverRun)
        {
            writefln("Initial fitness:");

            foreach ( i, creature; this.population )
            {
                writefln("%d: %f", i + 1, creature.fitness());
            }
        }

        runIteration(&this.iterate);

        auto best = this.determineBest();

        printSolution(best, this.generation);
    }

    /**
     * Perform an iteration of the solver.
     */

    private void iterate ( )
    {
        import std.random;
        debug(SolverIterate) import std.stdio;

        // Generate random creature indices for this generation's breeding pair
        size_t idx1, idx2;

        while ( idx1 == idx2 )
        {
            idx1 = uniform(0, this.config.population_size);
            idx2 = uniform(0, this.config.population_size);
        }

        debug(SolverIterate) writefln("Indices: %d %d", idx1, idx2);

        auto c1 = this.population[idx1],
             c2 = this.population[idx2],
             c1_won = this.winner(c1, c2);

        auto winner = c1_won ? c1 : c2,
             loser = c1_won ? c2 : c1,
             loser_idx = c1_won ? idx2 : idx1;

        debug(SolverIterate) writefln("Winner: %s", winner);
        debug(SolverIterate) writefln("Fitness: %f", winner.fitness());
        debug(SolverIterate) writefln("Loser: %s", loser);
        debug(SolverIterate) writefln("Fitness: %f", loser.fitness());

        this.population[loser_idx] = this.breed(winner, loser);

        debug(SolverIterate) writefln("Mutated loser: %s", this.population[loser_idx]);
        debug(SolverIterate) writefln("Fitness: %f", this.population[loser_idx].fitness());
    }

    /**
     * Breed two creatures
     *
     * Params:
     *      winner = The winner creature
     *      loser = The loser creature
     *
     * Returns:
     *      The Offspring
     */

    private CreatureType breed ( CreatureType winner, CreatureType loser )
    {
        import std.random;
        debug(SolverBreed) import std.stdio;

        foreach ( i, ref gene; loser )
        {
            // Recombine
            if ( uniform01() < this.config.recombination_rate )
            {
                debug(SolverBreed) writefln("Recombining %d, %s", i, winner[i]);
                loser[i] = winner[i];
            }

            // Mutate
            if ( uniform01() < this.config.mutation_rate )
            {
                loser.mutate(i);
                debug(SolverBreed) writefln("Mutated %d, %s", i, loser[i]);
            }
        }

        return loser;
    }

    /**
     * Initialize the population by mutating each individual
     */

    private void initPopulation ( )
    {
        foreach ( ref creature; this.population )
        {
            foreach ( i, _; creature )
            {
                creature.mutate(i);
            }
        }
    }

    /**
     * Determine the best creature in the given population
     *
     * Returns:
     *      A copy of the best creature found
     */

    private CreatureType determineBest ( )
    out ( result )
    {
        assert(result != CreatureType.init);
    }
    body
    {
        CreatureType best;

        foreach ( creature; this.population )
        {
            if ( this.winner(creature, best) )
            {
                best = creature;
            }
        }

        return best;
    }

    /**
     * Print the given solution
     *
     * Params:
     *      creature = The creature found to solve the problem
     *      generations = The number of generations it took
     */

    private static void printSolution ( CreatureType creature, uint generations )
    {
        import std.stdio;

        writefln("Solution found after %d generations: %s", generations, creature);
        writefln("Fitness: %f", creature.fitness());
    }
}
