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

/**
 * Iterate until a condition is fulfilled for the current population
 *
 * Template params:
 *      Condition = The condition function
 *      ConditionArgs = The condition function template arguments
 *
 * Params:
 *      iteration = The iteration delegate
 */

template IterateUntil ( alias Condition, ConditionArgs ... )
{
    mixin Condition!(ConditionArgs);

    alias IterateDg = void delegate ( );

    void runIteration ( IterateDg iteration )
    {
        while ( !Condition(this.population) )
        {
            this.generation++;

            iteration();
        }
    }
}

/**
 * Condition function for the IterateUntil template.
 *
 * Checks if the given population has a perfect creature, one with 0 fitness.
 *
 * Template params:
 *      Creature = The creature type
 */

template hasPerfect ( Creature )
{
    bool Condition ( Creature[] population )
    {
        foreach ( creature; population )
        {
            if ( creature.fitness() == 0 )
            {
                return true;
            }
        }

        return false;
    }
}
