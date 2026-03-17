[| serverSocket port|

port := Smalltalk platform environment at: 'PHARO_CLI_PORT'.
serverSocket := Socket newTCP.
serverSocket listenOn: port asNumber backlogSize: 10.

[ true ] whileTrue: [
    | data result clientSocket |
    [
        serverSocket waitForConnectionFor: 6000 .
        clientSocket := serverSocket accept.
        data := clientSocket receiveData asString.
        result := OpalCompiler new source: data; evaluate.
        clientSocket sendData: result printString.
   	    clientSocket close.
		clientSocket := nil.
    ] on: Exception do: [:e |
		clientSocket ifNotNil: [
			clientSocket sendData: e printString.
			clientSocket close.
			 ] ifNil: [
				Transcript show: e printString.
			 ]
 ]]
] forkAt: Processor userBackgroundPriority.
