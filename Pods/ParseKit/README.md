## ParseKit

ParseKit is a Mac OS X Framework written by Todd Ditchendorf in Objective-C and released under the Apache 2 Open Source License. ParseKit is suitable for use on iOS or Mac OS X. ParseKit is an Objective-C is heavily influced by [ANTLR](http://www.antlr.org/) by Terence Parr and ["Building Parsers with Java"](http://www.amazon.com/Building-Parsers-Java-Steven-Metsker/dp/0201719622) by Steven John Metsker. Also, ParseKit depends on [MGTemplateEngine](http://mattgemmell.com/2008/05/20/mgtemplateengine-templates-with-cocoa) by Matt Gemmell for its templating features.

The ParseKit Framework offers 3 basic services of general interest to Cocoa developers:

1.  **[String Tokenization](http://parsekit.com/tokenization.html)** via the Objective-C PKTokenizer and PKToken classes.
2.  **High-Level Language Parsing via Objective-C** - An Objective-C parser-building API (the PKParser class and sublcasses).
3.  **[Objective-C Parser Generation via Grammars](http://itod.github.io/ParseKitMiniMathExample/)** - Generate an Objective-C source code for parser for your custom language using a BNF-style grammar syntax (similar to yacc or ANTLR). While parsing, the parser will provide callbacks to your Objective-C code.

More about ParseKit can be found on [ParseKit.com](http://parsekit.com/)