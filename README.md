# Dirk - a view engine for dart inspired by C# ASP Razor

Under development.

## Installation

The package is in its early stage, so I decided not push it to `pub.dev` yet. As soon as I make it more battle tested, I will reconsider that.

Add 
```
dev_dependencies:
  build_runner: ^1.11.1
  dirk:
    git:
      url: git://github.com/denisbakhtin/dirk.git
```

## Usage

Normally `dirk` operates on a `lib/views` folder, this can be configured, but not tested yet. 
There are some conventions: 
- all views must have a `.dirk.html` extention
- the main layout file should be named `layout.dirk.html` and contain a `@renderBody()` placeholder, where the rendered view will be inserted
- partial files must begin with `_` underscore

For more info check the syntax section. Use the [example](https://github.com/denisbakhtin/dirk/tree/main/example) as a brief howto.

Finally, run `pub run build_runner build` for a one-time code generation, or `pub run build_runner watch` for building on the fly.

## Syntax

The syntax resembles ASP Razor for those, who are familiar with it. Currently not all features (and I doubt they will ever be) implemented, because the goal is
to have a lightweight template engine, that supports generic code instructions interpolated in html. This does not mean other features won't be added, so fire an
issue if you have a good suggestion.

Basically all code instructions begin with `@` symbol. To escape it, use double `@@`, for example: `email@@gmail.com`.

`@import 'dart:math';` tells the engine to import any available library or dart file.
`@model TodoClass;` states that the type of the view model is `TodoClass` and you can reference it in your code as a `model` variable.
`@someObject.withMethod("abc")` is a simple expression. If the method returns `void`, use the complex expression.
`@(someObject.toInt() + anotherObject.toInt())` is another for of expression with parenthesis for grouping code.
```
@{
  var i = 1;
  var m = 2;
  var sum = i + m;
  youCanEvenCallSomeHeavyComputationTaskButThisIsNotBestPractice(sum);
}
```
An example of complex expression. Unlike the simple ones it does not return any result to the html page.
```

@if (i > 10) {
  <p>Tell them the truth.</p>
}
```
That is a basic `if` statement.
```
@for (var i = 0; i < 10; i++) {
  <div>Line @i of 10</div>
}
```
Loop block.
`@renderPartial("_header", "Awesome Website")` renders the `_header.dirk.html` partial with String parameter in place. Atm the partial has to be in the same folder, but this is a WIP and easily fixed.

## Note for the brave

Dart is a beautiful language. The absence of type reflection for AOT binaries forces some moderate code generation to make things convenient. So learn and love `build_runner`, it is a nice 
tool to have and master.

### Note for advanced users

At moment, all views are generated into one lexical scope as simple functions. You can always inspect the `lib/views/views.dart` file if something goes wrong, as well as `.dart_tool/build/generated/.../lib/views` for per view intermediate result.

#### Note for grammar academics

Some wording is totally wrong.