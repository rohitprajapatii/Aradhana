import 'package:flutter/material.dart';
import 'package:html/parser.dart';

String parseHtmlString(String htmlString) {
  var document = parse(htmlString);

  String parsedString = parse(document.body.text).documentElement.text;

  return parsedString;
}

showSnackBarError(BuildContext context, String message) {
  //Fluttertoast.showToast(msg: message, gravity: ToastGravity.TOP);

  final snackBar = SnackBar(
      backgroundColor: Colors.red,
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ));
  Scaffold.of(context).showSnackBar(snackBar);
}
