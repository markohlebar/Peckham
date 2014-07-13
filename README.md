Peckham
=======

Xcode plugin that simplifies adding #import-s. 

![Peckham.gif](https://raw.githubusercontent.com/markohlebar/Peckham/develop/Misc/Peckham.gif)

### Installation Guide

- clone the repository or download .zip
- open **MHImportBuster.xcworkspace** 
- build **Peckham** target
- restart Xcode

### User guide

- **⌘ + ctrl + P** to invoke the popup
- start typing the keyword of your import
- press **RETURN** or double click to add an import

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

- check issues section
- branch from develop and PR to develop 
- use gitflow for creating a feature branch

### Dependencies

- **XcodeEditor** https://github.com/jasperblues/XcodeEditor
- **ParseKit** https://github.com/itod/parsekit

### License

MIT, see LICENSE
