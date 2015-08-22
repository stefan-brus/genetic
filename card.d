/**
 * Attempt to solve the following optimization problem:
 *
 * http://www.codeproject.com/Articles/16286/AI-Simple-Genetic-Algorithm-GA-to-solve-a-card-pro
 */

module card;

import genetic.Config;
import genetic.Creature;
import genetic.Iteration;
import genetic.Solver;

/**
 * The solver configuration
 */

class CardConfig : SolverConfig
{
    /**
     * Constants
     */

    enum POPULATION_SIZE = 30,
         RECOMBINATION_RATE = 0.5,
         MUTATION_RATE = 0.1;

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
 * If a gene is true, it goes in the product pile, otherwise it goes in the sum pile.
 */

alias Gene = bool;

enum GenomeLength = 10;

/**
 * The fitness function.
 *
 * The fitness is the combined error factor of the sum pile and the product pile.
 * The lower the number, the better the fitness.
 */

template fitness ( )
{
    double fitness ( )
    {
        import std.math;

        enum SUM_TARGET = 36,
             PROD_TARGET = 360;

        auto sum = 0,
             prod = 1;

        foreach ( n, gene; this )
        {
            if ( gene )
            {
                prod *= n + 1;
            }
            else
            {
                sum += n + 1;
            }
        }

        auto sum_error = cast(double)(sum - SUM_TARGET) / SUM_TARGET,
            prod_error = cast(double)(prod - PROD_TARGET) / PROD_TARGET,
            total_error = cast(double)abs(sum_error) + abs(prod_error);

        return total_error;
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
        this[idx] = !this[idx];
    }
}

/**
 * The creature type alias
 */

alias CardCreature = Creature!(Gene, GenomeLength, fitness, mutate);

/**
 * The solver type alias
 */

alias CardSolver = Solver!(CardCreature, IterateUntil, hasPerfect, CardCreature);

/**
 * Winner function
 */

bool winner ( CardCreature is_winner, CardCreature contender )
{
    return is_winner.fitness() < contender.fitness();
}

void main ( )
{
    auto solver = new CardSolver(new CardConfig(), &winner);
    solver.run();
}
