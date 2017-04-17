{CompositeDisposable} = require 'atom'

module.exports = ProcessPanel =
	process: null
	panel: null
	subscriptions: null

	activate: ->
		@subscriptions = new CompositeDisposable
		@subscriptions.add atom.commands.add 'atom-workspace', 'output-panel:show': => @show()
		@subscriptions.add atom.commands.add 'atom-workspace', 'output-panel:hide': => @hide()
		@subscriptions.add atom.commands.add 'atom-workspace', 'output-panel:toggle': => @toggle()
		@subscriptions.add atom.commands.add 'atom-workspace', 'output-panel:run': => {
			#TODO:prompt for something to run
		}
		@subscriptions.add atom.commands.add 'atom-workspace', 'output-panel:stop': => @stop()
		@subscriptions.add atom.commands.add 'atom-workspace', 'core:cancel': => @hide()

	deactivate: ->
		@panel?.destroy()
		@subscriptions.dispose()

	show: -> new Promise (fulfill) =>
		if !@panel
			{Panel} = require './view/Panel'

			@panel = new Panel
			@panel.onDidDestroy => @panel = null

		(atom.workspace.open @panel, searchAllPanes: true).then =>
			if @panel then @_onItemResize @panel, => @panel?.resize()
			fulfill()

	hide: ->
		atom.workspace.hide @panel if @panel

	toggle: ->
		if !@panel || !atom.workspace.hide @panel then @show()

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

	provideOutputPanel: ->
		isVisible: => return @panel!=null
		run: @run.bind this
		stop: @stop.bind this
		show: @show.bind this
		hide: @hide.bind this
		toggle: @toggle.bind this
		print: (line) =>
			@show().then =>
				@panel?.print line
		clear: =>
			@panel?.clear()
