## Sindarin by example

In this chapter, we illustrate Sindarin through several examples.
We show how to debug code with Sindarin, and how to implement breakpoints as an example exercise.

### Debugging with Sindarin

To debug a piece of code with Sindarin, we simply call the `debug:` interface of the Sindarin debugger on a block containing the code we want to debug (for example, in a playground).
In the following, we debug a single line of code by executing the following script:
```Smalltalk
sindarin := SindarinDebugger debug: [ OrderedCollection new add: 1 ].
````
The result of the call to `debug:` returns an instance of the Sindarin debugger that we store in a local variable. 
We then interact with this variable to observe and manipulate our execution.
We can print the result of the following instruction:
```Smalltalk
sindarin node sourceCode.
```
We then observe the following result: `"'OrderedCollection new'"`.
This indicates that we are about to execute the first message send from the code contained in the block closure.
Let us step this code:
```Smalltalk
sindarin step.
```
Printing the source code again shows `"'self new: 10'"`: we stepped into the execution of the `new` method of `OrderedCollection`.
Let us step over this instruction: 

```Smalltalk
sindarin stepOver.
```
We now see that the source code about to be executed is `"'^ self new: 10'"`: we executed the `new:10` message send (without stepping into it) and are about to return to the caller.
Let us step over the execution a bit faster:

```Smalltalk
sindarin stepOver: 2.
```
The source code about to be executed is now the full instruction from the block: ` "'OrderedCollection new add: 1'"`. 
We have stepped over the `add: 1` message send and are about to return the full result of the execution.
With one new `stepOver` we obtain the source code `"'Processor terminateRealActive'"`, which means the process is being terminated, and one more step over raises an exception indicating that the debugged execution finished.

The full script example gives this, in a playground:
```Smalltalk
sindarin := SindarinDebugger debug: [ OrderedCollection new add: 1 ].
sindarin node sourceCode "'OrderedCollection new'".
sindarin step.
sindarin node sourceCode. "'self new: 10'"
sindarin stepOver. 
sindarin node sourceCode. "^ self new: 10'"
sindarin stepOver: 2.
sindarin node sourceCode.  "'OrderedCollection new add: 1'" 
sindarin stepOver.
sindarin node sourceCode.  "'Processor terminateRealActive'"
sindarin stepOver "==> execution finished exception"
```

### Simple breakpoint example

Let us implement a method breakpoint, that will break the execution when it reaches the `addLast:` method executed somewhere in the control flow of the `OrderedCollection` code.
We do this using the `stepUntil:` interface, that steps the execution bytecode by bytecode until a particular condition is satisfied.
The condition is written as a block of Pharo code using the Sindarin API:

```Smalltalk
sindarin := SindarinDebugger debug: [ OrderedCollection new add: 1 ].
sindarin stepUntil: [
	sindarin isMessageSend and: [sindarin selector = #addLast:]].
sindarin node sourceCode. "'array size'"
```
We first test if we are in the context of a message send, using `isMessageSend`. 
We must satisfy this condition before trying to access the `selector` of the message being sent, else we might not be in such context and an exception will be raised.

The `sourceCode` interface returns `"'array size'"`, i.e., the next instruction to be executed, supposedly within the body of the `addLast:` method but we do not have enough information.
This interface is not really adapted to visualize the actual executing source code. 
For a better perspective, we can inspect the `sindarin` variable, which opens a minimal debugger that allows us to visualize the debugged code (fig. *@fig:sindarin-inspector@*). This minimal debugger exposes the Sindarin API through a graphical user interface, as well as views on the debugged execution and its state.

![The Sindarin minimal debugger.](graphics/sindarin-inspector.drawio.png label=fig:sindarin-inspector)


### Variable breakpoint example

```Smalltalk
sindarin := SindarinDebugger debug: [ OrderedCollection new add: 1 ].
sindarin stepUntil: [ 
	sindarin isAssignment and: [
		sindarin assignmentVariableName = 'lastIndex' ] ].
sindarin node sourceCode.  "'lastIndex := firstIndex - 1'"
```
fig. *@fig:sindarin-var-bp-first-hit@*
![Variable breakpoint first hit.](graphics/sindarin-var-bp-first-hit.drawio.png label=fig:sindarin-var-bp-first-hit)

fig. *@fig:sindarin-var-bp-second-hit@*
![Variable breakpoint second hit.](graphics/sindarin-var-bp-second-hit.drawio.png label=fig:sindarin-var-bp-second-hit)

### Sindarin in the debugger