import 'package:flutter/material.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(SearchableDropdownApp());
}

class SearchableDropdownApp extends StatefulWidget {
  @override
  _SearchableDropdownAppState createState() => _SearchableDropdownAppState();
}

List<String> localData = [
  'One',
  'Two',
  'Three',
  'Four',
  'Five',
  'Six',
  'Seven',
  'Eight',
  'Nine',
  'Ten',
];

class _SearchableDropdownAppState extends State<SearchableDropdownApp> {
  Map<String, String> selectedValueMap = Map();
  @override
  void initState() {
    selectedValueMap['local'] = null;
    selectedValueMap['server'] = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Exemplo de DropDown com filtro'),
        ),
        body: SingleChildScrollView(
          child: Container(
            height: 571,
            width: double.infinity,
            color: Colors.white.withOpacity(0.4),
            child: Container(
              padding: EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Text(
                      'Dropdown com dados locais:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  getSearchableDropdown(localData, "local"),
                  Container(
                      child: Text(
                    'Dropdown com Api:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )),
                  FutureBuilder<List>(
                    future: getServerData(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return getSearchableDropdown(snapshot.data, "server");
                      } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                      }
                      return CircularProgressIndicator();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getSearchableDropdown(List<String> listData, mapKey) {
    List<DropdownMenuItem> items = [];
    for (int i = 0; i < listData.length; i++) {
      items.add(DropdownMenuItem(
        child: Text(
          listData[i],
        ),
        value: listData[i],
      ));
    }
    return SearchableDropdown(
      items: items,
      value: selectedValueMap[mapKey],
      isCaseSensitiveSearch: false,
      hint: Text('Select One'),
      searchHint: Text(
        'Select One',
        style: TextStyle(fontSize: 20),
      ),
      onChanged: (value) {
        setState(() {
          selectedValueMap[mapKey] = value;
        });
      },
    );
  }

  Future<List> getServerData() async {
    String url = 'https://restcountries.eu/rest/v2/all';

    final response =
        await http.get(url, headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      print(response.body);
      List<dynamic> responseBody = json.decode(response.body);
      List<String> countries = List();
      for (int i = 0; i < responseBody.length; i++) {
        countries.add(responseBody[i]['name']);
      }
      return countries;
    } else {
      print("error from server : $response");
      throw Exception('Failed to load post');
    }
  }
}
