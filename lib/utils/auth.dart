import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  get currentUser {
    return auth.currentUser;
  }

  Future<void> signIn({required String email, required String password}) async {
    await auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> changePassowrd({
    //required String email,
    required String password,
    required String newPassword,
  }) async {
    String email = auth.currentUser!.email.toString();
    await auth.signOut();
    await auth.signInWithEmailAndPassword(email: email, password: password);
    await auth.currentUser!.updatePassword(newPassword);
  }
}
