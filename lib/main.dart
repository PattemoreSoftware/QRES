import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(QRESApplication());
}

class RE {
  String id;
  String vmaClass;
  String description;
  String shortDescriptionRegulation;
  String wetland;
  String structureCategory;

  RE(this.id, this.vmaClass, this.description, this.shortDescriptionRegulation,
      this.wetland, this.structureCategory);
}

class QRESApplication extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QRES',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: REList(title: 'QRES'),
    );
  }
}

class REList extends StatefulWidget {
  REList({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _REList createState() => _REList();
}

class REDisplay extends StatelessWidget {
  final RE re;
  final List<RE> res;
  final int index;

  const REDisplay(this.re, this.res, this.index);

  Widget getREDisplayWidget(RE re) {
    return Center(
      child: ListView(children: <Widget>[
        Container(
            padding: EdgeInsets.all(20),
            child: Text(
              re.id,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            )),
        Container(padding: EdgeInsets.all(20), child: Text(re.vmaClass)),
        Container(
            padding: EdgeInsets.all(20), child: Text(re.structureCategory)),
        Container(
            padding: EdgeInsets.all(20),
            child: Text(re.shortDescriptionRegulation)),
        Container(padding: EdgeInsets.all(20), child: Text(re.description)),
        Container(padding: EdgeInsets.all(20), child: Text(re.wetland)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = PageController(initialPage: index);
    List<Widget> pages = new List<Widget>();
    for (int i = 0; i < res.length; i++) {
      pages.add(getREDisplayWidget(res[i]));
    }
    return Scaffold(
        backgroundColor: Colors.yellowAccent,
        appBar: AppBar(
            title: Center(child: Column(children: <Widget>[Text("QRES")])),
            backgroundColor: Colors.redAccent),
        body: PageView(controller: controller, children: pages));
  }
}

class _REList extends State<REList> {
  Future<String> jsonData;

  dynamic parsedJson;
  var searchTerm = "";
  List<RE> res;

  void _searchChanged(search) {
    setState(() {
      searchTerm = search;
    });
  }

  _REList() {
    jsonData = rootBundle.loadString("assets/data.json");
  }

  List<RE> convertJsonToREList(json) {
    List<RE> result = new List<RE>();
    for (int i = 0; i < json["Rows"].length; i++) {
      result.add(RE(
          json["Rows"][i]["Fields"][0],
          json["Rows"][i]["Fields"][2],
          json["Rows"][i]["Fields"][7],
          json["Rows"][i]["Fields"][9],
          json["Rows"][i]["Fields"][18],
          json["Rows"][i]["Fields"][19]));
    }
    return result;
  }

  dynamic filterREToSearchTerm(res, search) {
    List<RE> preFilter = new List<RE>();
    for (int i = 0; i < res.length; i++) {
      bool keep = false;
      List<String> split = search.split(" ");
      split.remove(" ");
      split.remove("");
      if(split.where((element) => ! element.contains(new RegExp(r'[A-z]'))).length == 0){
        keep = true;
      }
      for (int j = 0; j < split.length; j++) {
        if (res[i].id.contains(split[j])) {
          keep = true;
        }
      }
      if (keep) {
        preFilter.add(res[i]);
      }
    }
    //double.tryParse(s) != null
    List<RE> result = new List<RE>();
    for (int i = 0; i < preFilter.length; i++) {
      bool keep = false;
      List<String> split = search.split(" ");
      split.remove(" ");
      split.remove("");
      if(split.where((element) => element.contains(new RegExp(r'[A-z]'))).length == 0){
        keep = true;
      }
      for (int j = 0; j < split.length; j++) {
        if(split[j].contains(new RegExp(r'[A-z]'))) {
          if (preFilter[i].description.toLowerCase().contains(
              split[j].toLowerCase())) {
            keep = true;
          }
        }
      }
      if (keep) {
        result.add(preFilter[i]);
      }
    }
    return result;
  }

  Widget getReList() {
    return FutureBuilder(
      future: jsonData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (parsedJson == null) {
            parsedJson = json.decode(snapshot.data);
          }
          if (res == null) {
            res = convertJsonToREList(parsedJson);
          }
          List<RE> filteredRes = filterREToSearchTerm(res, searchTerm);
          List<Widget> listItems = new List<Widget>();
          for (int i = 0; i < filteredRes.length; i++) {
            listItems.add(Container(
                padding: EdgeInsets.only(bottom: 5),
                child: Material(
                    color: Colors.yellowAccent,
                    child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    REDisplay(filteredRes[i], filteredRes, i)),
                          );
                        },
                        child: Column(
                          children: <Widget>[
                            Center(child: SizedBox(height: 20, width: 20)),
                            Center(
                                child: Text(filteredRes[i].id,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Center(child: SizedBox(height: 5, width: 20)),
                            Center(
                                child: Text(
                                    filteredRes[i].shortDescriptionRegulation)),
                            Center(child: SizedBox(height: 20, width: 20)),
                          ],
                        )))));
          }

          return ListView(
              padding: EdgeInsets.only(),
              children: listItems,
              addAutomaticKeepAlives: true);
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: Material(
                  color: Colors.redAccent,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.cloud_download),
                        Center(
                            child: Text("One second while we load re data...."))
                      ],
                    ),
                  )));
        } else {
          return Text("Error!");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.brown,
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Center(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      showAboutDialog(
                          context: context,
                          applicationName: "QRES",
                          applicationVersion: "1.0",
                          applicationIcon:
                              Image(image: AssetImage('assets/icon.png')),
                          applicationLegalese:
                              "QRES is an offline viewer and search tool for the Queensland Government's RE description database. QRES aims to faithfully reproduce that data but for critical purposes we recommend that check data against the original source - https://apps.des.qld.gov.au/regional-ecosystems/");
                    },
                    child: Text(
                      "About",
                    ),
                  ),
                  Text("QRES"),
                  Center(
                    child: new InkWell(
                        child: new Text(
                          'REDD version 11.1',
                          style: TextStyle(fontSize: 7),
                        ),
                        onTap: () => launch(
                            'https://apps.des.qld.gov.au/regional-ecosystems/')),
                  ),
                ]),
          ),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Material(
                  color: Colors.lightBlueAccent,
                  child: TextField(
                      onChanged: (search) {
                        _searchChanged(search);
                      },
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          hintText: "Search for RE number and/or descriptive text and/or botanical name",
                          hintStyle: TextStyle(fontSize: 8,),
                          contentPadding: EdgeInsets.all(0),
                          fillColor: Colors.yellow))),
              Expanded(child: getReList()),
            ],
          ),
        ));
  }
}
