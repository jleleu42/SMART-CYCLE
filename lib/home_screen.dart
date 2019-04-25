import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:latlong/latlong.dart';
import 'user.dart';
import 'package:sms/sms.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.title}) : super(key: key);
  final String title;
  String infos = "";
  String url = "";

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return HomeScreenState();
  }

}

class HomeScreenState extends State<HomeScreen> {

  int titles = 0;
  ScrollController _controller = new ScrollController();
  var lat='0.0';
  var lon='0.0';
  var ID;



  @override
  void initState() {
    super.initState();
    locationEvents.receiveBroadcastStream().listen(_onEvent, onError: _onError);
    demandePerm();
  }

  void demandePerm() {

  }

  void _sendUrl(String lat, String lon) async {
    var url = 'https://smart-cycle.herokuapp.com/add?id='+myUser.ID+
        '&latitude=' + lat.toString() +
        '&longitude=' + lon.toString();

    final response = await http.get(url);

    if (response.statusCode == 200) {
      print("envoi OKKKK");
    } else {
      print("envoi KO");
    }
    print(url);
    titles+=1;
  }

  //quand update localisation
  void _onEvent(Object event) {
    setState(() {
      //titles.add(event);
      //_controller.jumpTo(_controller.position.maxScrollExtent);
      var tmp = event.toString();
      tmp = tmp.substring(1);
      tmp = tmp.substring(0, tmp.length -1);
      var list = tmp.split(" ");
      lat = list[0].substring(0, list[0].length -1);
      lon = list[1];
      _sendUrl(lat, lon);
    });
  }

  void _onError(Object error) {
    print(error);
  }

  User myUser = new User();
  String btnStart = 'Start Backgound Location Monitoring';
  String btnStop = 'Location montitoring not running';
  bool monitoring = false;
  int log = 0;

  @override
  Widget build(BuildContext context) {
    if(log==0) {
      if (!myUser.valide()) {
        myUser.read().then((User u) {
          myUser = u;
          setState(() {
            if (myUser.valide()) {
              log = 2;
            }
            else {
              getID();
              log = 1;
            }
            new HomeScreenState();
          });
        });
      }
    }


    print(myUser.nom);
    print(log);
    if(log==1){
      return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Smart Cycle'),
            ),
            body: Container(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new Text("Votre identifiant unique est le :"),
                      new TextField(
                        enabled: false,
                        decoration: InputDecoration(labelText: "ID"),
                        keyboardType: TextInputType.phone,
                        controller: new TextEditingController(text: myUser.ID),
                      ),
                      new Text("Entrez votre nom :"),
                      new TextField(
                        decoration: const InputDecoration(labelText: 'Nom'),
                        keyboardType: TextInputType.text,
                        onChanged : (v) {myUser.nom = v;},
                        controller: new TextEditingController(text: myUser.nom),
                      ),
                      new Text("Entrez votre prénom :"),
                      new TextField(
                        decoration: const InputDecoration(labelText: 'Prénom'),
                        keyboardType: TextInputType.text,
                        onChanged : (v) {myUser.prenom = v;},
                        controller: new TextEditingController(text: myUser.prenom),
                      ),
                      new Text("Entrez le numéro du contact 1 :"),
                      new TextField(
                        decoration: const InputDecoration(labelText: 'Numéro 1'),
                        keyboardType: TextInputType.phone,
                        onChanged : (v) {myUser.num1 = v;},
                        controller: new TextEditingController(text: myUser.num1),
                      ),
                      new Text("Entrez le numéro du contact 2 :"),
                      new TextField(
                        decoration: const InputDecoration(labelText: 'Numéro 2'),
                        keyboardType: TextInputType.phone,
                        onChanged : (v) {myUser.num2 = v;},
                        controller: new TextEditingController(text: myUser.num2),
                      ),
                      new Text("Entrez le numéro du contact 3 :"),
                      new TextField(
                        decoration: const InputDecoration(labelText: 'Numéro 3'),
                        keyboardType: TextInputType.phone,
                        onChanged : (v) {myUser.num3 = v;},
                        controller: new TextEditingController(text: myUser.num3),
                      ),
                      new RaisedButton(
                        child: Text("Valider le formulaire"),
                        onPressed: () {
                          //if(true){
                          if(myUser.valide()){
                            print("+++" + myUser.num3);
                            myUser.write();
                            log = 2;
                            print("ok bon log = true");
                            setState((){
                              new HomeScreenState();
                            });
                          }
                          else{
                            print("Erreur login");
                          }
                        },
                      ),
                    ]
                )
            )
        ),
      );
    }

    //if(log == 2){
      return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Smart Cycle'),
            ),
            body: Container(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: <Widget>[
                            Center(
                              child: RaisedButton(
                                  child: Text(monitoring ? "Traceur activé" : "Démarrer le traceur"),
                                  onPressed: () {
                                    if(!monitoring){
                                      locationUpdateService("startLocationService");
                                    }
                                  }
                              ),
                            ),
                            Center(
                              child: RaisedButton(
                                  child: Text(monitoring ? "Arrêter le traceur" : "Traceur en arrêt"),
                                  onPressed: () {
                                    if(monitoring){
                                      locationUpdateService("stopLocationService");
                                      // on reinitialise la liste deslocalisations
                                      titles = 0;
                                    }
                                  }
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(titles.toString(),style: TextStyle(color: Colors.black, fontSize: 33,fontWeight: FontWeight.w500)),
                      ),
                      Expanded(
                        flex: 4,
                        child: _myMap(),

                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: RaisedButton(
                            color: Colors.orangeAccent,
                            elevation: 4.0,
                            splashColor: Colors.redAccent,
                            child: Text("Envoyer un SMS d'urgence"),
                            onPressed: () {
                              sendSms(myUser);
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: RaisedButton(
                            color: Colors.deepOrange,
                            elevation: 4.0,
                            splashColor: Colors.redAccent,
                            child: Text("Appeler les urgences"),
                            onPressed: _launchURL,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: RaisedButton(
                            child: Text("Modifier mes paramètres"),
                            onPressed: () {
                              log = 1;
                              print("ok bon log = flase");
                              setState((){
                                new HomeScreenState();
                              });
                            },
                          ),
                        ),
                      )
                    ]
                )
            )
        ),
      );
    //}
  }

  Widget _myMap() {
    return new FlutterMap(
      layers: [
        new TileLayerOptions(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
        ),
        new MarkerLayerOptions(
          markers: [
            new Marker(
              width: 60.0,
              height: 60.0,
              point: new LatLng(double.parse(lat), double.parse(lon)),
              builder: (ctx) =>
              new Container(
                child: IconButton(
                  icon: Icon(Icons.location_on),
                  color: Colors.red,
                  iconSize: 45.0,
                  onPressed: () {
                    print('Marker tapped');
                  },
                ),
              ),
            ),
          ],
        ),
      ],
      options: new MapOptions(
        center: new LatLng(double.parse(lat), double.parse(lon)),
        zoom: 15.0,
      ),
    );

  }

  static const platform = const MethodChannel('com.payload.flutterbackgroundresources/background_location_methods');
  static const locationEvents = const EventChannel("com.payload.flutterbackgroundresources/background_location_events");

  Future<void> locationUpdateService(String method) async {
    platform.setMethodCallHandler((MethodCall call) async {
      print(call.arguments);
    });
    await platform.invokeMethod(method).then((data){
       switch (data.toString()) {
         case "started":
           setState(() {
             monitoring = true;
           });
           break;
         case "stopped":
           setState(() {
             monitoring = false;
           });
           break;
       }
    });
  }

  void sendSms(User u){
    var listNum = [u.num1,u.num2,u.num3];

    listNum.forEach((e){
      SmsSender sender = new SmsSender();
      SmsMessage message = new SmsMessage(e, u.prenom + " " + u.nom + " a un problème.\r\nLatitude : " + lat + "\r\nLongitude : " + lon + "\r\nhttps://smart-cycle.herokuapp.com/map/"+myUser.ID);
      message.onStateChanged.listen((state) {
        if (state == SmsMessageState.Sent) {
          Toast.show("SMS envoyé à " + e, context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
        } else if (state == SmsMessageState.Delivered) {
          Toast.show("SMS délivré au FAI pour " + e, context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
        }
      });
      sender.sendSms(message);
    });
  }


  _launchURL() async {
    var url = "tel://" + myUser.num1 ;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  getID() async {

    locationUpdateService("startLocationService");
    locationUpdateService("stopLocationService");
    var url = 'https://smart-cycle.herokuapp.com/id';

    final response = await http.get(url);

    if (response.statusCode == 200) {
      print("envoi OKKKK");
    } else {
      print("envoi KO");
    }
    print(response.body);
    ID = response.body;
    myUser.ID = ID;
    print("Le site dit : " + ID);
    setState(() {
      new HomeScreenState();
    });
  }
}