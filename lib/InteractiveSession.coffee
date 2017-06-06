{Emitter} = require 'atom'

class @InteractiveSession
	constructor: (main) ->
		@main = main
		@pty = @main.pty
		if !@main.interactiveSessions.length
			@main.panel?.setInteractive true
		@main.interactiveSessions.push this

	discard: ->
		index = @main.interactiveSessions.indexOf this
		@main.interactiveSessions.splice index, 1
		if !@main.interactiveSessions.length
			@main.panel?.setInteractive false
