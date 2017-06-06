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
				@main.pty?.write data

		@terminal.attachCustomKeydownHandler (event) =>
			# ctrl-a
			if event.key=='a' and event.ctrlKey and !event.shiftKey and !event.altKey
				event.preventDefault()
				event.stopPropagation()
				@selectAll()
				return false

			# ctrl-c / ctrl-insert
			else if (
				event.key=='c' and event.ctrlKey and !event.shiftKey and !event.altKey ||
				event.key=='Insert' and event.ctrlKey and !event.shiftKey and !event.altKey
			) and window.getSelection().toString()
				event.preventDefault()
				event.stopPropagation()
				@main.copy()
				return false

			# ctrl-v / shift-insert
			else if (
				event.key=='v' and event.ctrlKey and !event.shiftKey and !event.altKey||
				event.key=='Insert' and !event.ctrlKey and event.shiftKey and !event.altKey
			)
				event.preventDefault()
				event.stopPropagation()
				@main.paste()
				return false

		@terminal.open @body

		if @main.interactiveSessions.length
			@setInteractive true

		@resize()

	getTitle: -> 'Output'
	getDefaultLocation: -> 'bottom'

	resize: (height) ->
		size = @terminal.proposeGeometry()
		@terminal.resize size.cols||80, size.rows||8
		@main.pty?.resize size.cols||80, size.rows||8

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

	selectAll: ->
		range = document.createRange()
		range.selectNodeContents (@body.getElementsByClassName 'xterm-rows')[0]
		selection = window.getSelection()
		selection.removeAllRanges()
		selection.addRange range

	copy: ->
		selection = window.getSelection()
		selected = selection.toString()
		selected = selected.replace /\xa0/g, ' '
		selected = selected.replace /\s+(\n|$)/g,'$1'
		atom.clipboard.write selected
		selection.removeAllRanges() #clear all selections for neatness

	setInteractive: (set) ->
		if @is_interactive = set
			@terminal.setOption 'cursorBlink', true
			@terminal.showCursor()
		else
			@terminal.setOption 'cursorBlink', false
			# @terminal.hideCursor() # function apparently does not exist..
