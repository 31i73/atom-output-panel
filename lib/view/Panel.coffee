{Emitter} = require 'atom'

class @Panel
	constructor: (main) ->
		@main = main
		@is_interactive = false
		@emitter = new Emitter()

		@element = document.createElement 'div'
		@element.classList.add 'output-panel', 'tool-panel'

		@body = document.createElement 'div'
		@body.classList.add 'panel-body'

		@element.appendChild @body

		XTerm = require 'xterm'
		XTerm.loadAddon 'fit'

		@terminal = new XTerm {
			cursorBlink: false
			visualBell: true
			convertEol: true
			termName: 'xterm-256color'
			scrollback: 1000
			rows: 8
		}

		@terminal.on 'data', (data) =>
			if @is_interactive
				@main.pty.write data

		@terminal.open @body

		if @main.interactiveSessions.length
			@setInteractive true

		@resize()

	getTitle: -> 'Output'
	getDefaultLocation: -> 'bottom'

	resize: (height) ->
		size = @terminal.proposeGeometry()
		@terminal.resize size.cols||80, size.rows||8
		@main.pty.resize size.cols||80, size.rows||8

	destroy: ->
		@element.remove()
		@emitter.emit 'didDestroy'

	onDidDestroy: (callback) ->
		@emitter.on 'didDestroy', callback

	getElement: ->
		@element

	clear: ->
		@terminal.reset()

	print: (line, newline = true) ->
		if newline
			@terminal.writeln line
		else
			@terminal.write line

	setInteractive: (set) ->
		if @is_interactive = set
			@terminal.setOption 'cursorBlink', true
			@terminal.showCursor()
		else
			@terminal.setOption 'cursorBlink', false
			# @terminal.hideCursor() # function apparently does not exist..
