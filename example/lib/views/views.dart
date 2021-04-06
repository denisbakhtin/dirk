// Generated by Dirk Generator, don't modify by hand

// ignore_for_file: unused_import, unused_local_variable
import 'package:dirk/sanitize.dart';

String IndexView({Map<String, dynamic> viewData = const {}}) {
  String res = '';
  viewData = Map.from(viewData);

  res += ''' <h1>Product catalog</h1> <small>''';
  res += '''${sanitize((15 + 12).toString())}''';
  res += ''' quality items</small> <h5>We recommend</h5> ''';
  for (var i = 0; i < 5; i++) {
    res += ''' <p class="highlight">Impressive product ''';
    res += '''${sanitize(i + 1)}''';
    res += '''</p> ''';
  }
  return LayoutTwoView(res, viewData: viewData);
}

String LayoutView(String model, {Map<String, dynamic> viewData = const {}}) {
  String res = '';
  viewData = Map.from(viewData);
  res += '''<html> ''';
  res += '''${PartialHeaderView("Awesome Website", viewData: viewData)}''';
  res += ''' <body> ''';
  res += '''${PartialSharedMenuView(viewData: viewData)}''';
  res += ''' <div class="container"> ''';
  res += '''${model}''';
  res +=
      ''' </div> <footer class="page-footer"> All rights reserved 2021. </footer> </body> </html>''';
  return res;
}

String LayoutTwoView(String model, {Map<String, dynamic> viewData = const {}}) {
  String res = '';
  viewData = Map.from(viewData);
  res += '''<html> ''';
  res +=
      '''${PartialHeaderView("Really Awesome Website", viewData: viewData)}''';
  res += ''' <body> ''';
  res += '''${PartialSharedMenuView(viewData: viewData)}''';
  res += ''' <div class="container"> ''';
  res += '''${model}''';
  res +=
      ''' </div> <footer class="page-footer"> All rights reserved 2021. Updated template. </footer> </body> </html> ''';
  return res;
}

String SharedNestedView({Map<String, dynamic> viewData = const {}}) {
  String res = '';
  viewData = Map.from(viewData);
  res += '''<p>This is a shared view</p>''';
  return LayoutView(res, viewData: viewData);
}

String PartialSharedMenuView({Map<String, dynamic> viewData = const {}}) {
  String res = '';
  viewData = Map.from(viewData);
  res +=
      '''<nav class="navbar navbar-light bg-light"> <a class="navbar-brand" href="#">Navbar</a> <ul class="navbar-nav"> <li class="nav-item active"> <a class="nav-link" href="#">Home <span class="sr-only">(current)</span></a> </li> <li class="nav-item"> <a class="nav-link" href="#">Products</a> </li> </ul> </nav>''';
  return res;
}

String ShowView({Map<String, dynamic> viewData = const {}}) {
  String res = '';
  viewData = Map.from(viewData);
  viewData['MetaDescription'] = 'Product page description';
  res +=
      ''' <h1>Details page example</h1> <p>An ecommerce product detail page design can often make or break a sale.</p> ''';
  print('Show Hello');
  res += ''' <ul> ''';
  for (var i = 0; i < 10; i++) {
    res += ''' <li> Product feature number ''';
    res += '''${sanitize(i + 1)}''';
    res += '''. ''';
    if (i == 9) {
      res += ''' No one can resist. ''';
    }
    res += ''' </li> ''';
  }
  res += ''' </ul> <!-- Stop XSS exploits in the World Wide Web!! --> ''';
  var s = '<a href="javascript:alert();">evil link</a>';
  res += ''' This expression must be sanitized: ''';
  res += '''${sanitize(s)}''';
  return LayoutView(res, viewData: viewData);
}

String PartialHeaderView(String model,
    {Map<String, dynamic> viewData = const {}}) {
  String res = '';
  viewData = Map.from(viewData);
  res += ''' <head> <title>Best deals | ''';
  res += '''${sanitize(model)}''';
  res += '''</title> <meta name="description" content="''';
  res += '''${sanitize(viewData['MetaDescription'])}''';
  res += '''"> </head> ''';
  return res;
}
