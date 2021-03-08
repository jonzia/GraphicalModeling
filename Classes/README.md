# Classes

Classes and enumerations for building probabilistic graphical models.

## Table of Contents

1. [Classes](#classes)
2. [Enumerations](#enumerations)

## Classes

### Factor

**Path:** `Classes/@Factor`

The `Factor` class contains properties and methods for factor nodes -- characterized by their associated probability tables -- in graphical models. The `Factor` class is typically called by the [`Node`](#node) class when creating factor nodes.

| Function | Purpose |
| --- | --- |
| `Factor()` | Class constructor |
| `Factor.getSubtable()` | Get a subtable from a factor table |
| `Factor.makeDistribution()` | Make factor table into probability distribution |
| `Factor.makeFactor()` | Create a factor table |
| `Factor.multiply()` | Perform factor multiplication for two `Factor` or [`Message`](#message) objects |

### Node

**Path:** `Classes/@Node`

The `Node` class contains properties and methods for variable and factor nodes in graphical models. Both variable and factor nodes may be created using the class constructor. At the time of instantiation, the parents of the instantiated node may be provided.

```matlab
parent1 = Node("Parent_1", 'values', {Class.true, Class.false}); parent1 = parent1.define();
parent2 = Node("Parent_2", 'values', {Class.true, Class.false}); parent2 = parent2.define();
child = Node("Child", 'values', {0, 1, 2}); child = child.define();
```

| Function | Purpose |
| --- | --- |
| `Node()` | Class constructor |
| `Node.define()` | Define the node object |
| `Node.evaluate()` | Evaluate a factor or variable node given an array of [`Message`](#message) objects |
| `Node.quantize()` | Set the node value to a quantized version of the input |
| `Node.query()` | Query the value of the node |
| `Node.setConditionals()` | Set the conditional proababilities of the node given a data table |

### Message

**Path:** `Classes/@Message`

The `Message` class contains properties and methods for messages, for use in message-passing algorithms. `Message` objects are typically created by [`Graph`](#graph) when solving graphs.

| Function | Purpose |
| --- | --- |
| `Message()` | Class constructor |
| `Message.createMessage()` | Create a message using factor tables |

### Graph

**Path:** `Classes/@Graph`

The `Graph` class contains properties and methods for graph objects, which are collections of interconnected `Node` objects. This class is used to perform high-level operations such as querying and solving graphs.

| Function | Purpose |
| --- | --- |
| `Graph()` | Class constructor |
| `Graph.eliminate()` | Perform variable elimination on the graph |
| `Graph.query()` | Query nodes in the graph |
| `Graph.solve()` | Recursively solve a factor graph |

### Markov

**Path:** `Classes/@Markov`

The `Markov` class contains properties and methods for hidden Markov models (HMMs). After creating a model with the constructor, synthetic data may be generated, and hidden state inference can be performed using a naïve method or the Viterbi algorithm.

| Function | Purpose |
| --- | --- |
| `Markov()` | Class constructor |
| `Markov.generate()` | Generate synthetic data using a trained HMM |
| `Markov.infer()` | Infer hidden states using a naïve method |
| `Markov.viterbi()` | Infer the optimal sequence of hidden states which explains the data |

## Enumerations

### MessageEval

**Path:** `Classes/MessageEval.m`

Enumeration describing methods of message evaluation.

| Value | Meaning |
| --- | --- |
| sumProduct | Sum-product algorithm |
| maxProduct | Max-product algorithm |
| none | N/A |

### MessageType

**Path:** `Classes/MessageType.m`

Enumeration describing types of messages.

| Value | Meaning |
| --- | --- |
| varToVar | Variable node to variable node |
| varToFac | Variable node to factor node |
| facToVar | Factor node to variable node |

### NodeType

**Path:** `Classes/NodeType.m`

Enumeration describing types of `Node` objects.

| Value | Meaning |
| --- | --- |
| Variable | Variable node |
| Factor | Factor node |
