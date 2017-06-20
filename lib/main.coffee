{CompositeDisposable} = require 'atom'
Pty = null

if process.platform!='win32'
	try
		Pty = require 'node-pty'
	catch
		Pty = null

{InteractiveSession} = require './InteractiveSession'

module.exports =
	process: null
	panel: null
	subscriptions: null

	activate: ->
		@subscriptions = new CompositeDisposable
		@subscriptions.add atom.commands.add 'atom-workspace', 'output-panel:show': => @show()
		@subscriptions.add atom.commands.add 'atom-workspace', 'output-panel:hide': => @hide()
		@subscriptions.add atom.commands.add 'atom-workspace', 'output-panel:toggle': => @toggle()
		# @subscriptions.add atom.commands.add 'atom-workspace', 'output-panel:run': => {
		# 	#TODO:prompt for something to run
		# }
		# @subscriptions.add atom.commands.add 'atom-workspace', 'output-panel:stop': => @stop()
		@subscriptions.add atom.commands.add 'atom-workspace', 'core:cancel': => @hide()

		@subscriptions.add atom.commands.add '.output-panel .terminal', 'core:copy': (event) =>
			event.stopPropagation()
			@copy()

		@subscriptions.add atom.commands.add '.output-panel .terminal', 'core:paste': (event) =>
			event.stopPropagation()
			@paste()

		@subscriptions.add atom.commands.add '.output-panel .terminal', 'core:select-all': (event) =>
			event.stopPropagation()
			@selectAll()

		@interactiveSessions = []

		@pty = Pty?.open {
			name: 'xterm-256color'
			cols: 80
			rows: 8
		}

		@pty?.on 'data', (data) =>
			@print data, false

	deactivate: ->
		@panel?.destroy()
		@subscriptions.dispose()

	_create: -> new Promise (fulfill) =>
		if !@panel
			{Panel} = require './view/Panel'

			@panel = new Panel this
			@panel.onDidDestroy => @panel = null

		atom.workspace.open @panel, searchAllPanes: true
			.then =>
				if @panel then @_onItemResize @panel, => @panel?.resize()
				fulfill()

	show: -> new Promise (fulfill) =>
		return @_create()

	hide: ->
		atom.workspace.hide @panel if @panel

	toggle: ->
		if !@panel || !atom.workspace.hide @panel then @show()

	print: (data, newline = true) ->
		if @panel # print if panel exists, but to not neccasarily show (in case of minimisation)
			@panel.print data, newline
		else #but if it doesn't exist then spawn a new one (and show it), before printing the text
			@_create().then => @panel?.print data, newline

	copy: -> @panel?.copy()

	paste: ->
		if @panel and @panel.is_interactive
			@pty?.write atom.clipboard.read()

	selectAll: -> @panel?.selectAll()

	_onItemResize: (item, callback) ->
		observer = null

		if wrapper = item.element.closest '.atom-dock-content-wrapper'
			observer = new MutationObserver => callback()
			observer.observe wrapper, attributes: true

		windowCallback = => callback()
		window.addEventListener 'resize', windowCallback

		if pane = atom.workspace.paneForItem item
			pane.observeFlexScale => item.resize()
			pane.onDidRemoveItem (event) =>
				if event.item == item
					observer?.disconnect()
					window.removeEventListener 'resize', windowCallback
					if !event.removed
						setTimeout =>
							@_onItemResize event.item, callback
						,1

	run: (show, path, args, options) ->
		@initialise()
		@stop()

		{spawn} = require 'cross-spawn'
		@process = spawn path, args||[], options||{}

		@process.stdout.setEncoding 'utf8'
		@process.stdout.pipe @panel.terminal

		@process.stderr.setEncoding 'utf8'
		@process.stderr.pipe @panel.terminal

		# @process.stdin.setEncoding 'utf-8'
		# @panel.terminal.on 'data', (data) =>
		# 	@process.stdin.write data

		if(show==true)
			@show()

		else if(show=='auto')
			firstOutput = =>
				@process.stdout.removeListener 'data', firstOutput
				@process.stderr.removeListener 'data', firstOutput
				@show()

			@process.stdout.on 'data', firstOutput
			@process.stderr.on 'data', firstOutput

		return @process

	stop: ->
		if @process!=null
			@process.kill()
			@process = null

	getInteractiveSession: ->
		return new InteractiveSession this

	provideOutputPanel: ->
		isVisible: => return @panel!=null
		run: @run.bind this
		stop: @stop.bind this
		show: @show.bind this
		hide: @hide.bind this
		toggle: @toggle.bind this
		print: @print.bind this
		clear: =>
			@panel?.clear()
		getInteractiveSession: @getInteractiveSession.bind this
