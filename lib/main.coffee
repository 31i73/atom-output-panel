{CompositeDisposable} = require 'atom'

module.exports = ProcessPanel =
	process: null
	panel: null
	atomPanel: null
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

	initialise: ->
		@initialise = => {}

		{Panel} = require './view/Panel'

		@panel = new Panel
		@panel.emitter.on 'close', =>
			@hide()
		@atomPanel = atom.workspace.addBottomPanel item: @panel.getElement(), visible: false

	deactivate: ->
		@subscriptions.dispose()
		@atomPanel?.destroy()
		@panel?.destroy()

	show: ->
		@initialise()
		@atomPanel.show()
		@panel.terminal.emit 'resize'

	hide: ->
		@atomPanel?.hide()

	toggle: ->
		if @atomPanel?.isVisible()
			@hide()
		else
			# @run true, 'ls', ['--color', '-lh']
			@show()

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
			@process.stdout.once 'data', =>
				@show()

		return @process

	stop: ->
		if @process!=null
			@process.kill()
			@process = null

	provideOutputPanel: ->
		isVisible: => return @atomPanel.isVisible()
		run: @run.bind this
		stop: @stop.bind this
		show: @show.bind this
		hide: @hide.bind this
		toggle: @toggle.bind this
		print: =>
			@initialise()
			@panel.print.apply @panel, arguments
		clear: =>
			@initialise()
			@panel.clear.apply @panel, arguments
