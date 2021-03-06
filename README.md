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

Normally `dirk` operates on a `lib/views` folder, this can be configured, but not tested. 
There are some conventions: 
- all views must have a `.dirk.html` extention
- the default layout file should be named `layout.dirk.html` and contain a `@renderBody()` placeholder, where the rendered view will be inserted
- any alternative layout name must follow the pattern `layout*.dirk.html`
- partial files must begin with `_` underscore

For more info check the syntax section. Use the [example](https://github.com/denisbakhtin/dirk/tree/main/example) as a brief howto.

Finally, run `pub run build_runner build` for a one-time code generation, or `pub run build_runner watch` for building on the fly.

## Syntax

The syntax resembles ASP Razor for those, who are familiar with it. Currently not all features (and I doubt they will ever be) implemented, because the goal is
to have a lightweight template engine with support for generic code instructions interpolated in html. This does not mean other features won't be added, so fire an
issue if you have a good suggestion.

Basically all code instructions begin with `@` symbol. To escape it, use double `@@`, for example: `email@@gmail.com`.

`@import 'dart:math';` tells the engine to import any available library or dart file.

`@layout layout_second;` tells the engine to use the `layout_second.dirk.html` as a layout for this view. If omitted, the default one is used instead.

`@type TodoClass;` states that the type of the view model is `TodoClass` and it can be referenced in your code as a `model` variable.

`@someObject.doSomeThing("abc")` is a simple expression. If the method returns `void`, use the complex expression.

`@(someObject.toInt() + anotherObject.toInt())` is another form of expression with grouping parentheses.

```
@{
  var i = 1;
  var m = 2;
  var sum = i + m;
  youCanEvenCallSomeHeavyComputationTaskButThisIsNotBestPractice(sum);
}
```
An example of complex expression. Every line must be a valid dart statement. Unlike the above forms it does not return any result to the html page.

```
@if (i > 10) {
  <p>Tell them the truth.</p>
} else {
	<p>Soothe their nerves.</p>
}
```
That is a basic `if` statement.

```
@for (var i = 1; i <= 10; i++) {
  <div>Line @i of 10</div>
}
```
Loop block.

`@renderPartial("_header", "Awesome Website")` renders the `_header.dirk.html` partial with String parameter in place.

Besides using a strictly typed model to pass parameters to view function, there is a possibility to store values in a dynamic `Map<String, dynamic>` `viewData` variable. E.g.: in your server controller call `IndexView(myIndexViewModel, viewData: {'Title': 'Welcome to my example web site'});`, or inside your view write `@{viewData['Title'] = 'Welcome!';}`, what allows you to reference `@viewData['Title']` anywhere in your `index.dirk.html` file or layout and partials. This is handy for setting SEO meta tags and other contextual vars that are common to most your views.

## Example

This is the formatted output of `IndexView()` function produced by [index.dirk.html](https://github.com/denisbakhtin/dirk/blob/main/example/lib/views/index.dirk.html) view:
```
<html>
  <head>
    <title>Best deals | Awesome Website</title>
  </head>
  <body>
    <nav class="navbar navbar-light bg-light">
      <a class="navbar-brand" href="#">Navbar</a> 
      <ul class="navbar-nav">
        <li class="nav-item active"> 
          <a class="nav-link" href="#">Home <span class="sr-only">(current)</span></a> 
        </li>
        <li class="nav-item"> <a class="nav-link" href="#">Products</a> </li>
      </ul>
    </nav>
    <div class="container">
      <h1>Product catalog</h1>
      <small>27 quality items</small> 
      <h5>We recommend</h5>
      <p class="highlight">Impressive product 1</p>
      <p class="highlight">Impressive product 2</p>
      <p class="highlight">Impressive product 3</p>
      <p class="highlight">Impressive product 4</p>
      <p class="highlight">Impressive product 5</p>
    </div>
    <footer class="page-footer"> All rights reserved 2021. </footer>
  </body>
</html>
```

## Note for the brave

Dart is a beautiful language. The absence of type reflection for AOT binaries forces some moderate code generation to make things convenient. So learn and love `build_runner`, it is a nice 
tool to have and master. The advantage is - generated views are compiled with your main program and I believe are as fast as they can be (but there is always a room for optimization).

### Note for advanced users

At moment, all views are generated into one lexical scope as simple functions. You can always inspect the `lib/views/views.dart` file if something goes wrong, as well as `.dart_tool/build/generated/.../lib/views` for per view intermediate result.

#### Note for grammar senpai

Some wording is totally wrong.

## To be done

* More intelligent expression parsing to allow something like `@viewData['title'], now one has to use `@(viewData['title'])
* Allow single `@` usage in text context
* Add comments
* Add `else if` parse
* Add some kind of plugin for vscode, vim, emacs
