{Emitter} = require 'atom'

class @Panel
	constructor: ->
		@emitter = new Emitter()

		@element = document.createElement 'div'
		@element.classList.add 'output-panel', 'tool-panel'

		@body = document.createElement 'div'
		@body.classList.add 'panel-body'

		@element.appendChild @body

		XTerm = require 'xterm'

		@terminal = new XTerm {
			cursorBlink: false
			visualBell: true
			convertEol: true
			termName: 'xterm-256color'
			scrollback: 1000,
			rows: 8
		}

		@terminal.open @body
		@terminal.end = -> {}

		@resize()

	getTitle: -> 'Output'
	getDefaultLocation: -> 'bottom'

	resize: (height) ->
		width = @element.clientWidth
		if !height
			height = @element.clientHeight

		rect = @terminal.viewport.charMeasureElement.getBoundingClientRect()

		cols = Math.floor width/rect.width
		rows = Math.floor height/rect.height

		@terminal.resize cols||80, rows||8

	destroy: ->
		@emitter.emit 'destroyed'
		@element.remove()

	getElement: ->
		@element

	clear: ->
		@terminal.reset()

	print: (line) ->
		@terminal.writeln line
