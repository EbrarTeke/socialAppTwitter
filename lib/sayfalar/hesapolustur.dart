import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/servisler/firestore.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

class HesapOlustur extends StatefulWidget {
  @override
  _HesapOlusturState createState() => _HesapOlusturState();
}

class _HesapOlusturState extends State<HesapOlustur> {
  final _formAnahtari = GlobalKey<FormState>();
  final _scaffoldAnahtari = GlobalKey<FormState>();
  final _globalKey = GlobalKey<ScaffoldMessengerState>();
  bool yukleniyor = false;
  String kullaniciAdi, email, sifre;

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _globalKey,
      child: Scaffold(
        key: _scaffoldAnahtari,
        appBar: AppBar(
          title: Text("Hesap Oluştur"),
        ),
        body: ListView(
          children: <Widget>[
            yukleniyor
                ? LinearProgressIndicator()
                : SizedBox(
                    height: 0.0,
                  ),
            SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formAnahtari,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      autocorrect: true,
                      decoration: InputDecoration(
                        hintText: "Kullanıcı adınızı girin",
                        labelText: "Kullanıcı Adı",
                        errorStyle: TextStyle(fontSize: 16.0),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (girilendeger) {
                        if (girilendeger.isEmpty) {
                          return "Kullanıcı adı boş bırakılamaz!";
                        } else if (girilendeger.trim().length < 4 ||
                            girilendeger.trim().length > 10) {
                          return "Girilen değer en az4 ve en fazla 10 karakter olabilir!";
                        }
                        return null;
                      },
                      onSaved: (girilenDeger) => kullaniciAdi = girilenDeger,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Email adresinizi girin",
                          labelText: "Email",
                          errorStyle: TextStyle(fontSize: 16.0),
                          prefixIcon: Icon(Icons.mail),
                        ),
                        validator: (girilendeger) {
                          if (girilendeger.isEmpty) {
                            return "Email alanı boş bırakılamaz!";
                          } else if (!girilendeger.contains("@")) {
                            return "Girilen değer mail formatında olmalıdır!";
                          }
                          return null;
                        },
                        onSaved: (girilenDeger) => email = girilenDeger),
                    SizedBox(
                      height: 10.0,
                    ),
                    TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Şifrenizi girin",
                          labelText: "Şifre",
                          errorStyle: TextStyle(fontSize: 16.0),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (girilendeger) {
                          if (girilendeger.isEmpty) {
                            return "Şifre alanı boş bırakılamaz!";
                          } else if (girilendeger.trim().length < 4) {
                            return "Şifre 4 karakterden az olamaz!";
                          }
                          return null;
                        },
                        onSaved: (girilenDeger) => sifre = girilenDeger),
                    SizedBox(
                      height: 50.0,
                    ),
                    Container(
                      width: double.infinity,
                      child: FlatButton(
                        onPressed: _kullaniciOlustur,
                        child: Text(
                          "Hesap Oluştur",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _kullaniciOlustur() async {
    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);
    var _formState = _formAnahtari.currentState;
    if (_formState.validate()) {
      _formState.save();
      setState(() {
        yukleniyor = true;
      });
      try {
        Kullanici kullanici =
            await _yetkilendirmeServisi.mailIleKayit(email, sifre);
        if (kullanici != null) {
          FireStoreServisi().kullaniciOlustur(
              id: kullanici.id, email: email, kullaniciAdi: kullaniciAdi);
        }
        Navigator.pop(context);
      } catch (hata) {
        setState(() {
          yukleniyor = false;
        });
        uyariGoster(hataKodu: hata.code);
      }
    }
  }

  uyariGoster({hataKodu}) {
    String hataMesaji;

    if (hataKodu == "ERROR_INVALID_EMAIL ") {
      hataMesaji = "Girdiğiniz mail adresi geçersizdir";
    } else if (hataKodu == "ERROR_EMAIL_ALREADY_IN_USE") {
      hataMesaji = "girdiğiniz mail kayıtlıdır.";
    } else if (hataKodu == "ERROR_WEAK_PASSWORD") {
      hataMesaji = "Daha zor bir şifre tercih edin";
    }
    var snackBar = SnackBar(content: Text(hataMesaji));
    //_globalKey?.currentState?.showSnackBar(snackBar);
    //_scaffoldAnahtari.currentState.showSnackBar(snackBar);
  }
}
