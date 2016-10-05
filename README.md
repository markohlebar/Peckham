Peckham
=======

[![CI Status](https://travis-ci.org/markohlebar/Peckham.svg)](https://travis-ci.org/markohlebar/Peckham)

Xcode plugin that simplifies adding #import-s. 

### Important

Xcode plugins are no longer supported since Xcode 8. If you're looking for an Xcode App Extension, check out 
### [Import☝️](https://github.com/markohlebar/Import)

![Peckham.gif](/Misc/Peckham.gif)

### Installation Guide

#### Alcatraz

- install [Alcatraz](https://github.com/alcatraz/Alcatraz) and search for **Peckham** 

#### Manual Labour

- clone the repository or download .zip
- open **Peckham.xcodeproj** 
- build **Peckham** target
- restart Xcode

### User guide

- **⌘ + ctrl + P** to invoke the popup
- start typing or paste the keyword of your import
- use **↑** or **↓** keys to navigate
- press **↵** or double click to add an import

### Advanced
- fuzzy search => type `mvc` to find a `ModelViewController`
- copy paste => **⌘ + C** the class name and then **⌘ + V** after opening Peckham

### History

Originally the plugin was supposed to handle adding / removing imports on the fly, which soon proved to be a more difficult task than I originally imagined, and took me on an exploration path of Clang libtooling and other cool stuff. I recently decided that I would instead make a GUI popup for adding an #import which seems to be a better approach to the problem in the first place. The code base contains a lot of parts that were originally meant to parse the code and make a tree (similar to Clang's AST) to find the #import statements in text. Due to performance reasons, this was dumped in favor of regex-es. 

### Roadmap 

There are several things that are to be added to the project
- faster algorithm to find the header files associated with a certain target
- adding frameworks to the selected target build phases as soon as you add an #import in your file
- @import support

### Known Issues 

- the search includes the whole path of the header
- the table cell highlights the wrong piece of string
- user headers are not really handled properly
- there is an issue with header duplication (especially visible with CocoaPods)

### Contributing 

- check [issues](https://github.com/markohlebar/Peckham/issues?state=open) section
- branch from **develop** and PR to **develop** 
- use gitflow for creating a feature branch

### Dependencies

- **XcodeEditor** https://github.com/appsquickly/XcodeEditor
- **PegKit** https://github.com/itod/pegkit

### License

MIT, see LICENSE
