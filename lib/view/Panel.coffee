{Emitter} = require 'atom'

class @Panel
	constructor: ->
		@emitter = new Emitter()

		@element = document.createElement 'div'
		@element.classList.add 'output-panel', 'tool-panel'

		@resizer = document.createElement 'div'
		@resizer.classList.add 'resizer'
		@resizer.addEventListener 'mousedown', =>
			document.body.style['-webkit-user-select'] = 'none'

			onMove = (event) =>
				rect = @resizer.getBoundingClientRect()
				delta = (rect.top + rect.bottom)/2 - event.y
				@resize Math.round @terminal.element.clientHeight+delta

			onRelease = (event) =>
				document.removeEventListener 'mousemove', onMove
				document.removeEventListener 'mouseup', onRelease

			document.addEventListener 'mousemove', onMove
			document.addEventListener 'mouseup', onRelease

		@element.appendChild @resizer

		header = document.createElement 'div'
		header.classList.add 'panel-heading'
		header.textContent = 'Output'
		@element.appendChild header

		closeButton = document.createElement 'button'
		closeButton.classList.add 'btn', 'action-close', 'icon', 'icon-remove-close'
		header.appendChild closeButton

		closeButton.addEventListener 'click', =>
			@emitter.emit 'close'

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

		window.addEventListener 'resize', => @resize()
		@resize()

	resize: (height) ->
		if !height
			height = @terminal.element.clientHeight

		rect = @terminal.viewport.charMeasureElement.getBoundingClientRect()

		cols = Math.floor @terminal.element.clientWidth/rect.width
		rows = Math.floor height/rect.height

		@terminal.resize cols||80, rows||8

	destroy: ->
		@element.remove()

	getElement: ->
		@element

	clear: ->
		@terminal.reset()

	print: (line) ->
		@terminal.writeln line
