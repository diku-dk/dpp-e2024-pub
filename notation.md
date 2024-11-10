# Primer on functional notation

Futhark uses common functional programming notation derived from the
lambda calculus, but this is not of much help if you are not familiar
with this notation.  This brief primer states goes through some of the
basic principles.  If you *do* have prior functional experience, then
[this guide is more for
you](https://futhark.readthedocs.io/en/latest/versus-other-languages.html).

Futhark is written in plain text files, and there are no particularly
advanced tools.  If you use VS Code, there is an extension with basic
support for showing errors and such.  There are also modes for Emacs
and Vim.  The main learning tool is `futhark repl`, where you can
enter expressions (or commands) and see the result.

## Types

Futhark is a statically typed language (like Java and unlike Python),
which means all values must have a known type.  In particular, there
is a variety of built in number types.  Whenever you are operating on
numbers, you must be consistent about which types you are using.  Some
of the most common types are:

* `bool`: boolean.
* `i32`: 32-bit integer.
* `f32`: 32-bit floating-point number.
* `f64`: 64-bit floating-point number.

Types must be compatible.  You cannot add a number of `i32` to a
number of type `f32`.  In such cases you have to convert the types of
the operands using some conversion function (which might involve
rounding).

Functions are also values in Futhark, and like all values they have
types.  For a function that accepts a single `i32` and returns a
single `i32`, we write that it has type `i32 -> i32`.  By looking at
the type of a function we can determine what inputs it accepts and
what results it produces.

## Function application

In mathematics (and most programming languages), we write function
application as `f(x)`.  In Futhark, we don't need the parentheses and
write just `f x`, with a space in between.

For the case of a single-parameter function, `f(x)` also works,
because `(x)` and `x` are interchangeable - we are always free to add
parentheses.  However, things are different for a multi-parameter
function.  In Futhark we must write `f x y` for what we would write as
`f(x,y)` in non-functional languages.

The principle here is that in a functional language, any function
actually accepts only a *single* argument.  A function that seems to
take two arguments actually takes a single argument and then *returns
another* function that takes the "second" argument.  Specifically, `f
x y` actually means first evaluating `f x`, and then applying the
result of that to the "second" argument `y`.  We could write this as
`(f x) y` to make it clear.  Usually this doesn't matter much - even
functional programmers think of `f` as a function "taking two
parameters".  This principle is called *currying* and has some
advantages (not covered here).

What can trip you up is that `f(x,y)` *is* actually valid Futhark
syntax, and it sometimes make sense.  This is read as an application
of the function `f` to the expression `(x,y)`, which is a *tuple*
(pair).  So this is the right thing when applying a function that
takes a *single* argument that just happens to be a tuple.  By
convention, Futhark functions are written in *curried* multi-parameter
style, but if you wish you can define functions that accept tuples
instead.

## Function definition

When defining a function, we specify the type of its argument and
result.  In contrast to C-derived languages such as Java, Futhark puts
the types of things *after* their name, following a colon:

```Futhark
def inc2 (x: i32) : i32 = x + 2
```

The above defines a function `inc2` that has a single parameter (of
type `i32`) and returns a value of type `i32` (written the `:` and
before the `=`).

We can also define a function that accepts multiple parameters:

```Futhark
def inc (x: i32) (y: i32) : i32 = x + 2
```

As discussed above, this function must be applied as `inc 1 2`.  If we
write `inc(1,2)` it would be an error.  The type of the function is as
follows:

```Futhark
i32 -> i32 -> i32
```

This is because the argument `(1,2)` has type `(i32,i32)`, while the
function expects it to have type `i32`.

We can however define functions that accept tuples as arguments, like
this:

```Futhark
def inc_tupled (x: i32, y: i32) : i32 = x + 2
```

The type of `inc_tupled` is `(i32, i32) -> i32`, meaning that
`inc(1,2)` will work.

## Using the REPL

When you are confused about the type of something, the `futhark repl`
command can be used.  After starting the REPL you can ask about the
types of things, using the `:t` command.  For example (the lines with
leading `>` are what *we* type, the rest is the response):

```
> def inc (x: i32) (y: i32) : i32 = x + 2
> :t inc
inc : (x: i32) -> (y: i32) -> i32
> :t inc 1
inc 1 : (y: i32) -> i32
> :t inc 1 2
inc 1 2 : i32
> inc 1 2
3
```

Note how each application to an operand "removes an arrow" from the
type, and at the end we have just the plain number left.  The final
evaluation is shown without using `:t`.  The REPL is a very useful
tool for experimenting with Futhark.
