# Sindarin Debugger Methods That Access the Value Stack

Based on analysis of the Pharo image, the following methods in `SindarinDebugger` access the **value stack** (not the call stack).

Note: Sindarin works with two stacks:
- **Value stack**: Operands and intermediate computation values within a method context
- **Call stack**: Chain of method frames/contexts (accessed via `sender` and `stack` command)

## Direct Stack Top Access

### `topStack`
- **Implementation**: `^ self context top`
- **Purpose**: Returns the top value on the execution stack
- **Usage**: Direct access to the stack top element

## Positional Value Stack Access

### `assignmentValue`
- **Purpose**: Returns the value about to be assigned
- **Implementation**: Uses `context at: currentContextStackSize` 
- **Stack Access**: Reads from the **value stack** at a calculated position (not top)

### `messageReceiver`
- **Purpose**: Returns the receiver of a message about to be sent
- **Implementation**: Accesses the value stack using `currentContextStackSize` to compute offset
- **Stack Access**: Reads from the **value stack** at a calculated position (not top)

### `currentContextStackSize`
- **Purpose**: Returns the current stack size
- **Implementation**: `^ self context basicSize`
- **Stack Access**: Queries context stack size

### `stack`
- **Purpose**: Returns the call stack (method frames)
- **Implementation**: `^ self debugSession stack`
- **Stack Access**: Returns the **call stack** (not value stack)

## Related Stack Manipulation Methods

Methods that also access stack top context but were identified earlier as pop methods:
- `skipMessageNodeWith:` - pops stack after skipping
- `skipAssignmentNodeWith:` - manages stack during skip
- `cleanStack` - explicitly pops remaining values

## Summary

**Value Stack Access:**
- **`topStack`** - Direct access to value stack top via `context top`
- **`assignmentValue`** - Positional access to value stack via `context at: currentContextStackSize`
- **`messageReceiver`** - Positional access to value stack via calculated offset
- **`currentContextStackSize`** - Returns the value stack size

**Call Stack Access:**
- **`stack`** - Returns the call stack (chain of method contexts)
