PEGKit
======

PEGKit is a '[Parsing Expression Grammar](http://bford.info/packrat/)' toolkit for iOS and OS X written by [Todd Ditchendorf](http://celestialteapot.com) in Objective-C and released under the [MIT Open Source License](https://tldrlegal.com/license/mit-license).

**Always use the Xcode Workspace `PEGKit.xcworkspace`, *NOT* the Xcode Project.**

This project includes [TDTemplateEngine](https://github.com/itod/tdtemplateengine) as a Git Submodule. So proper cloning of this project requires the `--recursive` argument:

    git clone --recursive git@github.com:itod/pegkit.git

PEGKit is heavily influenced by [ANTLR](http://www.antlr.org/) by Terence Parr and ["Building Parsers with Java"](http://www.amazon.com/Building-Parsers-Java-Steven-Metsker/dp/0201719622) by Steven John Metsker.

The PEGKit Framework offers 2 basic services of general interest to Cocoa developers:

1. **String Tokenization** via the Objective-C `PKTokenizer` and `PKToken` classes.
1. **Objective-C parser generation via grammars** - Generate source code for an Objective-C parser class from simple, intuitive, and powerful [BNF](http://en.wikipedia.org/wiki/Backus%E2%80%93Naur_Form)-style grammars (similar to yacc or ANTLR). While parsing, the generated parser will provide callbacks to your Objective-C delegate.

The PEGKit source code is available [on Github](http://github.com/itod/parsekit/).

A tutorial for [using PEGKit in your iOS applications is available on GitHub](https://github.com/itod/PEGKitMiniMathTutorial).

##History

PEGKit is a re-write of an earlier framework by the same author called [ParseKit](http://parsekit.com). ParseKit should generally be considered deprecated, and PEGKit should probably be used for all future development.

* ***[ParseKit](http://parsekit.com)*** produces **dynamic**, **non-deterministic** parsers **at runtime**. The parsers produced by ParseKit exhibit poor (exponential) performance characteristics -- although they have some interesting properties which are useful in very rare circumstances.

* ***PEGKit*** produces **static** ObjC source code for **deterministic** ([PEG](http://en.wikipedia.org/wiki/Parsing_expression_grammar)) memoizing parsers **at design time** which you can then compile into your project. The parsers produced by PEGKit exhibit good (linear) performance characteristics.


##Documentation
TODO

###Discard directive

The post-fix `!` operator can be used to discard a token which is not needed to compute a result. 

Example:

    addExpr = atom ('+'! atom)*;
    atom = Number;
 
 The `+` token will not be necessary to calculate the result of matched addition expressions, so we can discard it.
 
###Actions

Actions are small pieces of Objective-C source code embedded directly in a PEGKit grammar rule. Actions are enclosed in curly braces and placed after any rule reference.

In any action, there is a `self.assembly` object available (of type `PKAssembly`) which serves as a **stack** (via the `PUSH()` and `POP()` convenience macros). The assembly's stack contains the most recently parsed tokens (instances of `PKToken`), and also serves as a place to store your work as you compute the result.

Actions are executed immediately after their preceeding rule reference matches. So tokens which have recently been matched are available at the top of the assembly's stack.

Example 1:

    // matches addition expressions like `1 + 3 + 4`
    addExpr  = atom plusAtom*;
    
    plusAtom = '+'! atom
    {
        PUSH_DOUBLE(POP_DOUBLE() + POP_DOUBLE());
    };
    
    atom     = Number
    {
        // pop the double value of token on the top of the stack
        // and push it back as a double value 
        PUSH_DOUBLE(POP_DOUBLE()); 
    };


Example 2:

    // matches or expressions like `foo or bar` or `foo || bar || baz`
    orExpr = item (or item {
        id rhs = POP();
        id lhs = POP();
        MyOrNode *orNode = [MyOrNode nodeWithChildren:lhs, rhs];
        PUSH(orNode);
    })*;
    or    =  'or'! | '||'!;
    item  = Word;


###Rule Actions
* **`@before`** - setup code goes here. executed before parsing of this rule begins.
* **`@after`** - tear down code goes here. executed after parsing of this rule ends.

Rule actions are placed inside a rule -- after the rule name, but before the `=` sign.

Example:

    // matches things like `-1` or `---1` or `--------1`
    
    @extension { // this is a "Grammar Action". See below.
        @property (nonatomic) BOOL negative;
    }
    
    unaryExpr 
    @before { _negative = NO; }
    @after  {
        double d = POP_DOUBLE();
        d = (_negative) ? -d : d;
        PUSH_DOUBLE(d);
    }
        = ('-'! { _negative = !_negative; })+ num;
    num = Number;

###Grammar Actions
PEGKit has a feature inspired by ANTLR called **"Grammar Actions"**. Grammar Actions are a way to do exactly what you are looking for: inserting arbitrary code in various places in your Parser's .h and .m files. They must be placed at the top of your grammar before any rules are listed.

Here are all of the Grammar Actions currently available, along with a description of where their bodies are inserted in the source code of your generated parser:

####**In the .h file:**
* **`@h`** - top of .h file
* **`@interface`** - inside the `@interface` portion of header

####**In the .m file:**
* **`@m`** - top of .m file
* **`@extension`** - inside a private `@interface MyParser ()` class extension in the .m file
* **`@ivars`** - private ivars inside the `@implementation MyParser {}` in the .m file
* **`@implementation`** - inside your parser's `@implementation`. A place for defining methods.
* **`@init`** - inside your parser's `init` method
* **`@dealloc`** - inside your parser's `dealloc` method if ARC is not enabled
* **`@before`** - setup code goes here. executed before parsing begins.
* **`@after`** - tear down code goes here. executed after parsing ends.

(notice that the `@before` and `@after` Grammar Actions listed here are distinct from the `@before` and `@after` which may also be placed in each individual rule.)
