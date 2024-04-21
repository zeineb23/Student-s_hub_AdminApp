import 'package:flutter/material.dart';
import 'package:flutter_application_6/components/list.dart';

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CollectionViewer(collectionName: 'admins');
  }
}
