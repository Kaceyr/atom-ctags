
module.exports =

  editorSubscription: null
  autocomplete: null
  providers: []

  activate:(ctagsCache) ->
    atom.packages.activatePackage("autocomplete-plus")
      .then (pkg) =>
        @autocomplete = pkg.mainModule

        CtagsProvider = (require './ctags-provider')
          .ProviderClass(@autocomplete.Provider, @autocomplete.Suggestion, ctagsCache)

        @editorSubscription = atom.workspaceView.eachEditorView (editorView) =>
          if editorView.attached and not editorView.mini
            provider = new CtagsProvider editorView
            @autocomplete.registerProviderForEditorView provider, editorView
            @providers.push provider
            for view in @autocomplete.autocompleteViews
                fuzzyProvider = view.providers[0]
                if fuzzyProvider and fuzzyProvider.constructor.name == "FuzzyProvider"
                    view.unregisterProvider fuzzyProvider
                    fuzzyProvider.dispose()
                    break


  deactivate: ->
    @editorSubscription?.off()
    @editorSubscription = null
    @providers.forEach (provider) =>
      @autocomplete.unregisterProvider provider

    @providers = []
