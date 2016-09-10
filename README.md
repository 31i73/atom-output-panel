# output-panel package

A bottom output panel for hosting processing and displaying output

![A screenshot of your package](https://f.cloud.github.com/assets/69169/2290250/c35d867a-a017-11e3-86be-cd7c5bf3ff9b.gif)

## Commands:

`output-panel:show` - Show the panel  
`output-panel:hide` - Hide the panel  
`output-panel:toggle` - Toggle the panel  
`output-panel:run` - TODO: prompt the user to run a program in the panel  
`output-panel:stop` - Stop any program currently running in the panel  
`core:cancel` - Hide the panel  

## Service: `output-panel`

Returns an object with the following functions:

`run(show, path:String, ?args:String[], ?options)` - Run a process in the panel (this will `stop()` any existing, first)

> `show` - If `true` will immediately display the panel. if `"auto"` will automatically display the panel if the program displays output. if `false` will leave the panel in its current state.

> `path` - The path to the program to execute

> `args` - Optional. An array of arguments to pass to the program

> `options` - Optional. An options object compatible with `child_process.spawn()`

Returns a `child_process` compatible object of the running process

`stop()` - Stop and process currently running in the panel

`show()` - Display the panel

`hide()` - Hide the panel

`toggle()` - Toggle the panel

`print(line:String)` - Print a `line` of text to the panel

`clear()` - Clear the panel
