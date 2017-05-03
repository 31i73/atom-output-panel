# output-panel package

A bottom output panel for running processes and displaying output

![Output Panel screenshot](http://i.imgur.com/e57nAJp.png)

## Commands:

`output-panel:show` - Show the panel  
`output-panel:hide` - Hide the panel  
`output-panel:toggle` - Toggle the panel  
`output-panel:run` - TODO: prompt the user to run a program in the panel  
`output-panel:stop` - TODO: Stop any program currently running in the panel  
`core:cancel` - Hide the panel  

## Service: `output-panel`

Returns an object with the following functions:

`run(show, path:String, ?args:String[], ?options)` - Run a process in the panel (this will `stop()` any existing, first)

> `show` - If `true` will immediately display the panel. if `"auto"` will automatically display the panel if the program displays output. if `false` will leave the panel in its current state.

> `path` - The path to the program to execute

> `args` - Optional. An array of arguments to pass to the program

> `options` - Optional. An options object compatible with `child_process.spawn()`

Returns a `child_process` compatible object of the running process

`stop()` - Stop any process currently running in the panel

`show()` - Display the panel

`hide()` - Hide the panel

`toggle()` - Toggle the panel

`print(line:String, ?newline=true)` - Print a `line` of text to the panel, followed by an optional `newline` (default)

`clear()` - Clear the panel

`getInteractiveSession()` - Returns an `InteractiveSession` for retrieving user input. This session must be freed with `discard` when no longer used.

### InteractiveSession

`discard()` - Free this session

`pty` - The pty instance of this session (see https://www.npmjs.com/package/node-pty for more details)
