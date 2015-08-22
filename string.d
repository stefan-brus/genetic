/**
 * Attempt to generate a certain string
 */

module string;

import genetic.Config;
import genetic.Creature;
import genetic.Iteration;
import genetic.Solver;

/**
 * The string we are attempting to generate
 */

const TARGET = "Why, hello there! You did it, computer!";

/**
 * The solver configuration
 */

class StringConfig : SolverConfig
{
    /**
     * Constants
     */

    static const POPULATION_SIZE = 10,
                 RECOMBINATION_RATE = 0.8,
                 MUTATION_RATE = 0.05;

    /**
     * Constructor
     */

    this ( )
    {
        super(POPULATION_SIZE, RECOMBINATION_RATE, MUTATION_RATE);
    }
}

/**
 * Genome type and length.
 *
 * Each gene represents a character of the string.
 */

alias Gene = char;

const GenomeLength = TARGET.length;

/**
 * The fitness function.
 *
 * The fitness is the combined error of how far away each character in
 * the genome is from the corresponding character in the target string.
 */

template fitness ( )
{
    double fitness ( )
    {
        import std.math;

        // TODO: Figure out how to get rid of this duplication
        const TARGET = "Why, hello there! You did it, computer!";

        double error_sum = 0;

        foreach ( i, c; this )
        {
            error_sum += abs(cast(int)TARGET[i] - c);
        }

        return error_sum;
    }
}

/**
 * The mutator function
 */

template mutate ( )
{
    void mutate ( size_t idx )
    in
    {
        assert(idx < this.length);
    }
    body
    {
        import std.random;

        this[idx] = cast(Gene)uniform(0, Gene.max);
    }
}

/**
 * The creature type alias
 */

alias StringCreature = Creature!(Gene, GenomeLength, fitness, mutate);

/**
 * The solver type alias
 */

alias StringSolver = Solver!(StringCreature, IterateUntil, hasPerfect, StringCreature);

/**
 * Winner function
 */

bool winner ( StringCreature is_winner, StringCreature contender )
{
    return is_winner.fitness() < contender.fitness();
}

void main ( )
{
    auto solver = new StringSolver(new StringConfig(), &winner);
    solver.run();
}
