## Details of the API, with examples

### Manipulation of the debugged process
| Command | Description |
|---------|------------|
| `step` | Executes the next instruction. |
| `push: aValue` | Pushes `aValue` into the value stack. |
| `pop` | Pops and returns a value from the value stack. |
| `moveTo: aNode` | Moves (skips) the execution up to `aNode`. |
| `isFinished` | Tells if the debugged process has terminated. |

### Method-level reifications of the current context
| Command | Description |
|---------|------------|
| `selector` | The selector of the executing method. |
| `receiver` | The object executing the method. |
| `arguments` | The arguments of the executing method. |
| `temporaries` | The temporary variables for the executing method. |
| `sender` | The sender of the current context. |

### Submethod-level reifications of the current context
| Command | Description |
|---------|------------|
| `messageReceiver` | The receiver of the message about to be sent. |
| `messageSelector` | The selector of the message about to be sent. |
| `messageArguments` | The arguments of the message about to be sent. |
| `assignedValue` | The value about to be assigned. |
| `assignedVarName` | The variable name about to be assigned to. |

### Tools
| Command | Description |
|---------|------------|
| `stepOver` | Executes over the next instruction. |
| `stepUntil: P` | Steps the execution until the predicate `P` is true. |
| `continue` | Steps until the execution is interrupted or completed. |
| `isMessageSend` | Returns `true` if the next instruction is a message send. |
| `isAssignment` | Returns `true` if the next instruction is an assignment. |
| `break` | Returns a configurable breakpoint object. |

### Variants: some syntactic sugar
| Command | Description |
|---------|------------|
| `stepOver: n` | Executes over the next instruction. |
| `node` | Steps the execution until the predicate `P` is true. |
| `continue` | Steps until the execution is interrupted or completed. |
| `isMessageSend` | Returns `true` if the next instruction is a message send. |
| `isAssignment` | Returns `true` if the next instruction is an assignment. |
