import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:socialapp/modeller/kullanici.dart';

class FireStoreServisi {
  final Firestore _firestore = Firestore.instance;
  final DateTime zaman = DateTime.now();

  Future<void> kullaniciOlustur({id, email, kullaniciAdi, fotoUrl = ""}) async {
    await _firestore.collection("kullanicilar").document(id).setData({
      "kullaniciAdi": kullaniciAdi,
      "email": email,
      "fotoUrl": fotoUrl,
      "hakkinda": "",
      "olusturulmaZamani": zaman
    });
  }

  Future<Kullanici> kullaniciGetir(id) async {
    DocumentSnapshot doc =
        await _firestore.collection("kullanicilar").document(id).get();
    if (doc.exists) {
      Kullanici kullanici = Kullanici.dokumandanUret(doc);
      return kullanici;
    }
    return null;
  }

  Future<int> takipciSayisi(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("takipciler")
        .document(kullaniciId)
        .collection("kullanicininTakipcileri")
        .getDocuments();
    return snapshot.documents.length;
  }

  Future<int> takipEdilenSayisi(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("takipedilenler")
        .document(kullaniciId)
        .collection("kullanicininTakipleri")
        .getDocuments();
    return snapshot.documents.length;
  }
}
