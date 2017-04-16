% A sample markdown document with embeded graphviz
%
% 2017-04-16

# Header

## Section A

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent tellus leo, congue eleifend magna nec, tincidunt lacinia turpis. Donec a ipsum sapien. Mauris feugiat quis nisl sit amet varius. Vivamus tristique vitae purus in sollicitudin. Curabitur et turpis ac turpis pharetra tristique.

~~~  graphviz
digraph {
    A;
}
~~~

## Section B

In a dictum lectus. Curabitur accumsan augue sed mollis ullamcorper. Phasellus pellentesque velit non metus convallis, in pretium magna commodo. Duis dapibus dolor bibendum, tempor felis at, malesuada purus.

~~~  graphviz
digraph {
    A -> B;
}
~~~

Duis eu aliquet nisi, vel consectetur nibh. Integer facilisis, risus quis egestas dapibus, elit nibh pharetra dui, consectetur eleifend est tellus a urna. Aliquam vitae consectetur nulla.

~~~  graphviz
digraph Def {

    /** Data definition  */
    node [shape=box,style="filled",fillcolor=peachpuff];

    //-- Data nodes
    card_familly[label="Card familly\n[Heart, Diamond, Spade, Club]"];
    card_value[label="Card value\n[1..King]"];

    card_deck[label="Deck\n[(Heart, 1)..(Heart, King)..(Clubs, King)]"];

    /** Process definition */
    node [shape=ellipse,style="filled",fillcolor=olivedrab1];

    //-- Process nodes
    cartesian_product[label="Cartesian product x"];


    /** Relations */		
    subgraph {
	card_familly -> cartesian_product;
        card_value -> cartesian_product;

        cartesian_product -> card_deck;
    }
}
~~~

Donec felis eros, sodales fermentum tristique sit amet, euismod in neque. Mauris pharetra lobortis magna.
