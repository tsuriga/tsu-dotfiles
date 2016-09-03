# Atom editor setup

```
"*":
  core:
    disabledPackages: [
      "markdown-preview"
    ]
    themes: [
      "atom-dark-ui"
      "firewatch-syntax"
    ]
  "custom-title":
    template: '''<%= fileName %><% if (projectPath) { %> - <%= projectPath %><% } %> - Atom <%= atom.getVersion() %>'''
  editor:
    showIndentGuide: true
    showInvisibles: true
    softWrap: true
    tabLength: 4
  "markdown-preview-plus":
    useGitHubStyle: true
  minimap:
    displayMinimapOnLeft: false
    plugins:
      "minimap-autohide": true
      "minimap-autohideDecorationsZIndex": 0
  "tree-view":
    hideVcsIgnoredFiles: true
  welcome:
    showOnStartup: false
  whitespace:
    ensureSingleTrailingNewline: false
```

## Packages

- minimap
- minimap-autohide
- custom-title
- markdown-preview-plus
- tab-title
- auto-detect-indentation
- trailing-spaces

## Themes

- firewatch
