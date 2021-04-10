import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Json Editor',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _fileContent = '';
  Map _config = {};

  void _pickFile() async {
    final typeGroup = XTypeGroup(
      label: 'text',
      extensions: ['json'],
    );
    final file = await FileSelectorPlatform.instance.openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) {
      return;
    }
    _fileContent = await file.readAsString();
    _config = json.decode(_fileContent);
    setState(() {});
  }

  Widget _buildGroup(MapEntry entry) {
    final title = entry.key.toString();
    if (entry.value is Map) {
      return MapGroupTile(title: title, map: entry.value);
    } else if (entry.value is List) {
      return ListGroupTile(title: title, list: entry.value);
    } else {
      return Title(title + ' - UNKNOWN GROUP YPE');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text(
            'Choose File',
          ),
          onPressed: _pickFile,
        ),
      ),
      child: ListView(
        children: _config.entries.map(_buildGroup).toList(),
      ),
    );
  }
}

class Title extends StatelessWidget {
  const Title(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
    );
  }
}

class MapGroupTile extends StatelessWidget {
  const MapGroupTile({required this.title, required this.map});

  final String title;
  final Map map;

  @override
  Widget build(BuildContext context) {
    return CupertinoFormSection.insetGrouped(
      header: Text(title),
      children: map.entries
          .map((entry) => CupertinoTextFormFieldRow(
                placeholder: entry.value.toString(),
                prefix: Text(entry.key.toString()),
              ))
          .toList(),
    );
  }
}

class FieldTile extends StatelessWidget {
  const FieldTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: CupertinoTheme.of(context).textTheme.textStyle,
            ),
          ),
          SizedBox(height: 8),
          CupertinoTextField(
            placeholder: value,
          ),
        ],
      ),
    );
  }
}

class ListGroupTile extends StatelessWidget {
  const ListGroupTile({required this.title, required this.list});

  final String title;
  final List list;

  Widget _buildContent(value) {
    if (value is Map) {
      return SizedBox(
        width: 300,
        child: CupertinoFormSection.insetGrouped(
          children: value.entries
              .map((entry) => CupertinoTextFormFieldRow(
                    prefix: Text(entry.key.toString()),
                    placeholder: entry.value.toString(),
                  ))
              .toList(),
        ),
      );
    } else {
      return CupertinoTextFormFieldRow(placeholder: value.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoColors.systemGroupedBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.center,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13.0,
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
              ),
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            children: list.map((value) => _buildContent(value)).toList(),
          )
        ],
      ),
    );
  }
}
