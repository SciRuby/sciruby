SciRuby is a collaborative effort to bring scientific computation to Ruby. If you want to help, please do so!

This guide covers way in which you can contribute.

## How to help

There are various ways in which you can improve SciRuby. Coding and documentation are the two primary possibilities, but you can also contribute to one of ours subprojects (listed below) and participate in the [mailing list][mailing-list] -- suggesting ideas and changes is very important!

Apart from adding features and functionality, you can also create tests (we use RSpec), guides on how to do something using SciRuby, document the libraries and help find and fix bugs.

Start by visiting our [issue tracker] if you want to start contributing, there's probably something with which you can help.

## Projects

SciRuby is an umbrella for many other projects in Ruby. There's not much hierarchy or anything, but we believe that the most important one at the time is [NMatrix][nmatrix], as it's very hard to create some scientific library that doesn't need a good numerical linear algebra library to deal with vectors and matrices.

So, the SciRuby subprojects are, in no particular order:

- [NMatrix][nmatrix]: A fast numerical linear algebra library
- [Statsample][statsample]: A suite for basic and advanced statistics
- [Distribution][distribution]: Diverse statistical distributions. Uses C (statistics2/GSL) or Java extensions when available.
- [Integration][integration]: Integration methods.
- [Minimization][minimization]: Various minimization algorithms in pure Ruby.

## Documentation

Documentation is something most developers don't want to create, but everyone likes to use (well, most of the time). We can't possibly have a big community without proper guides and API docs.

Our current idea is to write guides (that can be initially created as blog posts, for example) and put them into a single place -- the [sciruby.com][sciruby] website. This enables people to start using the library without much friction.

For API documentation, we're using the [RDoc format][rdoc] in the source code. It works with both Ruby and C, so we should be able to have a very good coverage. We want to put the whole API documentation in one single place; again, the [sciruby.com][sciruby] website.

If you solved a problem or created an application that uses SciRuby or its subprojects, please say so in our mailing list and send us a pull request!

## Conclusion

Before commiting any code, you *MUST* read our {Contributor Agreement}[http://github.com/SciRuby/sciruby/wiki/Contributor-Agreement]. This is meant to protect both us and the users of SciRuby, as there are lots of scientific packages (or code found in books) that aren't so "open" as we would like them to be.

[mailing-list]: https://groups.google.com/forum/?fromgroups#!forum/sciruby-dev
[sciruby]: http://sciruby.com
[nmatrix]: https://github.com/sciruby/nmatrix
[statsample]: https://github.com/SciRuby/statsample
[distribution]: https://github.com/SciRuby/distribution
[integration]: https://github.com/SciRuby/integration
[minimization]: https://github.com/SciRuby/minimization
[rdoc]: http://rdoc.rubyforge.org/