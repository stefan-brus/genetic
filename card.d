/**
 * Trying to implement the following tutorial in D:
 *
 * http://www.codeproject.com/Articles/16286/AI-Simple-Genetic-Algorithm-GA-to-solve-a-card-pro
 */

class GeneticCards
{
    /**
     * Constants
     */

    static const POPULATION_SIZE = 30,
                 GENE_SIZE = 10,
                 MUTATION_RATE = 0.1,
                 RECOMBINATION_RATE = 0.5,
                 SUM_TARGET = 36,
                 PROD_TARGET = 360;

    /**
     * The population.
     *
     * Each creature is represented by a genome of 10 booleans.
     * If the gene is true, then the index of this card goes in the product pile.
     * If it is false, it goes in the sum pile.
     */

    alias Gene = bool;

    alias Creature = Gene[GENE_SIZE];

    Creature[POPULATION_SIZE] population;

    /**
     * Solve the card problem.
     *
     * Generates a random initial population.
     * Loops until a population with a perfect creature, one with a card pile that fits the critera, is found.
     * Each generation, two creatures are picked at random, and a "winner" and a "loser" is determined.
     * The loser's genes are recombined with the winner's genes, and mutated.
     * If the mutated loser has solved the problem, the loop is stopped.
     */

    void run ( )
    {
        import std.random;
        debug(Run) import std.stdio;

        this.initPopulation();

        debug(Run) writefln("Initialized population:");
        debug(Run) writefln("%s", this.population);

        debug(Run)
        {
            writefln("Initial fitness:");

            foreach ( i, creature; this.population )
            {
                writefln("%d: %f", i + 1, fitness(creature));
            }
        }

        uint generation;

        while ( true )
        {
            generation++;
            debug(Run) writefln("Generation %d", generation);

            // Check if the problem has been solved
            if ( auto perfect_index = this.hasPerfectIndex() != -1 )
            {
                this.printSolution(this.population[perfect_index], generation);
                break;
            }

            // Generate random creature indices for this generation's breeding pair
            size_t idx1, idx2;
            Creature* winner, loser;

            while ( idx1 == idx2 )
            {
                idx1 = uniform(0, POPULATION_SIZE);
                idx2 = uniform(0, POPULATION_SIZE);
            }

            debug(Run) writefln("Indices: %d %d", idx1, idx2);

            auto c1 = &this.population[idx1],
                 c2 = &this.population[idx2];

            auto c1_won = fitness(*c1) < fitness(*c2);

            winner = c1_won ? c1 : c2;
            loser = c1_won ? c2 : c1;

            debug(Run) writefln("Winner: %s", *winner);
            debug(Run) writefln("Fitness: %f", fitness(*winner));
            debug(Run) writefln("Loser: %s", *loser);
            debug(Run) writefln("Fitness: %f", fitness(*loser));

            breed(winner, loser);

            debug(Run) writefln("Mutated loser: %s", *loser);
            debug(Run) writefln("Fitness: %f", fitness(*loser));

            if ( fitness(*loser) == 0 )
            {
                this.printSolution(*loser, generation);
                break;
            }
        }
    }

    /**
     * Breed two creatures.
     *
     * The winner's genes are left untouched, and the loser's genes are combined
     * with the winner's at the configured rates.
     *
     * Params:
     *      winner = The winner
     *      loser = The loser
     */

    static void breed ( Creature* winner, Creature* loser )
    {
        import std.random;
        debug(Breed) import std.stdio;

        foreach ( i, _; *loser )
        {
            // Recombine with the winner
            if ( uniform01() < RECOMBINATION_RATE )
            {
                debug(Breed) writefln("Recombining %d", i);
                (*loser)[i] = (*winner)[i];
            }

            // Check if the loser is perfect
            if ( fitness(*loser) == 0 )
            {
                break;
            }

            // Mutate
            if ( uniform01() < MUTATION_RATE )
            {
                debug(Breed) writefln("Mutating %d", i);
                (*loser)[i] = !(*loser)[i];
            }

            // Check if the loser is perfect
            if ( fitness(*loser) == 0 )
            {
                break;
            }
        }
    }

    /**
     * Evaluate the fitness of a creature.
     *
     * The fitness is the combined error factor of the sum pile and the product pile.
     * The lower the number, the better the fitness.
     *
     * Params:
     *      creature = The creature to evaluate
     *
     * Returns:
     *      The fitness of the creature
     */

    static double fitness ( Creature creature )
    {
        import std.math;
        debug(Fitness) import std.stdio;

        auto sum = 0,
             prod = 1;

        foreach ( n, gene; creature )
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

        debug(Fitness) writefln("Sum: %d, Error: %f", sum, sum_error);
        debug(Fitness) writefln("Product: %d, Error: %f", prod, prod_error);
        debug(Fitness) writefln("Total error: %f", total_error);

        return total_error;
    }

    /**
     * Print the given perfect creature
     *
     * Params:
     *      creature = The perfect creature
     *      generation = The number of generations it took
     *
     */

    void printSolution ( Creature creature, uint generation )
    {
        import std.algorithm;
        import std.stdio;

        writefln("Solution found after %d generations!", generation);

        uint[] sum_pile, prod_pile;

        foreach ( i, gene; creature )
        {
            if ( gene )
            {
                prod_pile ~= i + 1;
            }
            else
            {
                sum_pile ~= i + 1;
            }
        }

        auto prod = reduce!((a, b) => a * b)(1, prod_pile),
             sum = reduce!((a, b) => a + b)(0, sum_pile);

        writefln("Product pile: %s", prod_pile);
        writefln("Product: %d", prod);
        writefln("Sum pile: %s", sum_pile);
        writefln("Sum: %d", sum);
    }

    /**
     * Check if the current population has a perfect creature, one that has solved the problem.
     *
     * Returns:
     *      The index of the first perfect creature found, -1 if none was found.
     */

    int hasPerfectIndex ( )
    {
        foreach ( i, creature; this.population )
        {
            if ( fitness(creature) == 0 )
            {
                return i;
            }
        }

        return -1;
    }

    /**
     * Randomly initialize the population.
     */

    void initPopulation ( )
    {
        import std.random;

        foreach ( ref creature; this.population )
        {
            foreach ( ref gene; creature )
            {
                gene = uniform(0, 2) == 1;
            }
        }
    }
}

void main ( )
{
    auto genetic = new GeneticCards();
    genetic.run();
}
