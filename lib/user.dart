import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class User{
  String ID;
  String nom;
  String prenom;
  String num1;
  String num2;
  String num3;

  User() {

  }


  bool valide(){
    bool retour = false;
    if(this.ID != null && this.nom != null && this.prenom != null && this.num1 != null && this.num2 != null && this.num3 != null) {
      if(this.ID != '' && this.nom != '' && this.prenom != '' && this.num1 != '' && this.num2 != '' && this.num3 != '') {
        retour = true;
      }
    }
    return retour;
  }

  write() async {
    String text = this.ID + ";" + this.nom + ";" + this.prenom + ";" + this.num1 + ";" + this.num2 + ";" + this.num3;

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/config.txt');
    await file.writeAsString(text);
    var url = 'https://smart-cycle.herokuapp.com/addPhones/'+this.ID+
        '?phone1=' + this.num1 +
        '&phone2=' + this.num2 +
        '&phone3=' + this.num3;

    final response = await http.get(url);

    if (response.statusCode == 200) {
      print("envoi OKKKK");
    } else {
      print("envoi KO");
    }
    print(url);

  }

  Future<User> read()  async {
    User user = new User();

    String text;
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/config.txt');
      text = await file.readAsString();
      var list = text.split(";");
      user.ID = list[0];
      user.nom = list[1];
      user.prenom = list[2];
      user.num1 = list[3];
      user.num2 = list[4];
      user.num3 = list[5];
      print(text);

    } catch (e) {
      print("Couldn't read file");
    }
    return user;
  }

}