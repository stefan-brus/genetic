/**
 * Attempt to solve the following optimization problem:
 *
 * A farmer has 2400 ft of fencing and wants to fence off a rectangular field
 * that borders a straight river. He needs no fence along the river. What are
 * the dimensions of the field that has the largest area?
 */

module fence;

import genetic.Config;
import genetic.Creature;
import genetic.Iteration;
import genetic.Solver;

/**
 * The solver configuration
 */

class FenceConfig : SolverConfig
{
    /**
     * Constants
     */

    static const POPULATION_SIZE = 10,
                 RECOMBINATION_RATE = 0.5,
                 MUTATION_RATE = 0.2;

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
 * The first gene represents the width of the area, the second the height.
 */

alias Gene = uint;

const GenomeLength = 2;

/**
 * The fitness function.
 *
 * Calculates the surface of the fenced in area.
 * If the total amount of fence used is > 2400, the creature is unfit.
 */

template fitness ( )
{
    double fitness ( )
    {
        const MAX_FENCE_LENGTH = 2400;

        if ( this[0] + (this[1] * 2) > MAX_FENCE_LENGTH )
        {
            return -1;
        }
        else
        {
            return this[0] * this[1];
        }
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

        const MAX_FENCE_LENGTH = 2400,
              X_IDX = 0,
              Y_IDX = 1;

        if ( idx == X_IDX )
        {
            this[X_IDX] = uniform(1, MAX_FENCE_LENGTH);
        }
        else
        {
            this[Y_IDX] = uniform(1, MAX_FENCE_LENGTH / 2);
        }
    }
}

/**
 * The creature type alias
 */

alias FenceCreature = Creature!(Gene, GenomeLength, fitness, mutate);

/**
 * The solver type alias
 */

alias FenceSolver = Solver!(FenceCreature, IterateN, 100000);

/**
 * Winner function
 */

bool winner ( FenceCreature is_winner, FenceCreature contender )
{
    return is_winner.fitness() > contender.fitness();
}

void main ( )
{
    auto solver = new FenceSolver(new FenceConfig(), &winner);
    solver.run();
}
