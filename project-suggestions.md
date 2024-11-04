# Project Suggestions

These projects are intentionally open-ended.  They are intended as an
opportunity for you to showcase your mastery of the learning goals:

* Parallel algorithmic reasoning.

* Parallel cost models.

* Judging the suitability of the language/tool for the problem at
  hand.

* Applied data-parallel programming.

This means that you are free to diverge from the project descriptions
below, or come up with your own ideas, as long as they provide a
context in which you can demonstrate the course contents.

You are *not* judged on whether e.g. Futhark or ISPC or whatever
language you choose happens to be a good fit or run particularly fast
for whatever problem you end up picking, but you *are* judged on how
you evaluate its suitability.

## Porting PBBS benchmarks

The [Problem Based Benchmark
Suite](https://cmuparlay.github.io/pbbsbench/) is a collection of
benchmark programs written in parallel C++. We are interested in
porting them to a high-level parallel language (e.g. Futhark). Some of
the benchmarks are relatively trivial; others are more difficult. It
might be a good idea for a project to combine a trivial benchmark with
a more complex one. The [list of benchmarks is
here](https://cmuparlay.github.io/pbbsbench/benchmarks/index.html).
The ones listed as *Basic Building Blocks* are all pretty
straightforward. Look at the others and pick whatever looks
interesting (but talk to us first - some, e.g. rayCast, involve no
interesting parallelism, and so are not a good DPP project).
Particularly interesting to Troels are the ones related to
computational geometry:

* [delaunayRefine](https://cmuparlay.github.io/pbbsbench/benchmarks/delaunayRefine.html)
* [delaunayTriangulation](https://cmuparlay.github.io/pbbsbench/benchmarks/delaunayTriangulation.html)
* [rangeQuery2d](https://cmuparlay.github.io/pbbsbench/benchmarks/rangeQuery2d.html)
