import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shuttlers/model/expense.dart';
import 'package:shuttlers/model/member.dart';
import 'package:shuttlers/passwords.dart';
import 'package:shuttlers/ui/dialog/add_expenditure.dart';
import 'package:shuttlers/ui/dialog/add_member.dart';
import 'package:shuttlers/ui/widgets/member_card.dart';
import 'package:shuttlers/ui/widgets/expense_card.dart';
import 'package:shuttlers/ui/widgets/member_card_admin.dart';
import 'package:shuttlers/utils/auth.dart';
import 'package:shuttlers/utils/pretty.dart';

import '../../utils/store.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  Store store = Store();
  Auth auth = Auth();

  FirebaseAuth authOld = FirebaseAuth.instance;
  User? user;

  @override
  void initState() {
    super.initState();

    //this.user = auth.currentUser;
    auth.auth.authStateChanges()
      ..listen((event) {
        setState(() {
          this.user = event;
        });
      });
    // authOld.authStateChanges().listen((usr) {
    //   setState(() {
    //     this.user = usr;
    //   });
    // });

    //tabcontroller
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController!.addListener(_handleTabIndex);
  }

  @override
  void dispose() {
    _tabController!.removeListener(_handleTabIndex);
    _tabController!.dispose();
    super.dispose();
  }

  void _handleTabIndex() {
    setState(() {});
  }

  _openAddMemberDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddMemberDialog()),
    );
  }

  _openAddExpenditureDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddExpenditureDialog()),
    );
  }

  Future<void> changePasswordDialog(BuildContext context) async {
    TextEditingController _currentPasswordController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();
    TextEditingController _passwordControllerConfirm = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                obscureText: true,
                controller: _currentPasswordController,
                decoration: InputDecoration(hintText: 'Enter Password'),
              ),
              TextFormField(
                obscureText: true,
                controller: _passwordController,
                decoration: InputDecoration(hintText: 'Enter New Password'),
              ),
              TextFormField(
                obscureText: true,
                controller: _passwordControllerConfirm,
                decoration: InputDecoration(hintText: 'Confirm New Password'),
              )
            ],
          ),
          actions: [
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                });
              },
            ),
            TextButton(
              child: Text('CHANGE'),
              onPressed: () async {
                setState(() {});

                if (_passwordController.text ==
                    _passwordControllerConfirm.text) {
                  try {
                    await auth.changePassowrd(
                      //email: email,
                      password: _currentPasswordController.text,
                      newPassword: _passwordController.text,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Password changed!")));
                  } catch (e) {
                    print(e);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Something went wrong.")));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Passwords didn't match!")));
                }

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> passwordDialog(BuildContext context) async {
    TextEditingController _passwordController = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Login'),
            content: TextField(
              obscureText: true,
              controller: _passwordController,
              decoration: InputDecoration(hintText: 'Enter Password'),
            ),
            actions: [
              TextButton(
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              TextButton(
                child: Text('LOGIN'),
                onPressed: () async {
                  setState(() {});
                  try {
                    //email is stored in a string in passwords.dart
                    await authOld.signInWithEmailAndPassword(
                        email: email, password: _passwordController.text);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text("Logged in!")));
                  } catch (e) {
                    print(e);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text("Login failed.")));
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Column _buildMembers() {
    return Column(
      children: <Widget>[
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: store.membersStream(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData)
                return Center(
                  child: CircularProgressIndicator(),
                );
              return ListView(
                children: snapshot.data!.docs.map((document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  return user != null
                      ? MemberCardAdmin(
                          Member.fromMap(data, document.id),
                        )
                      : MemberCard(Member.fromMap(data, document.id));
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Column _buildExpenditure() {
    return Column(
      children: <Widget>[
        Expanded(
          child: StreamBuilder(
            stream: store.ledgerStream(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView(
                children: snapshot.data!.docs.map((document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  return ExpenseCard(
                    Ledger.fromMap(data),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  BottomAppBar _buildBottom() {
    return BottomAppBar(
      child: SizedBox(
        height: 40,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: StreamBuilder<DocumentSnapshot>(
                stream: store.overviewStream(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text(
                      'Something went wrong...',
                      style: TextStyle(color: Colors.white),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text(
                      'Loading',
                      style: TextStyle(color: Colors.white),
                    );
                  }
                  Map<String, dynamic> data =
                      snapshot.data!.data() as Map<String, dynamic>;
                  return Text(
                    'Bank ${prettyMoney(data['bank'])}',
                    style: TextStyle(color: Colors.white),
                  );
                }),
          ),
        ),
      ),
      shape: user != null ? CircularNotchedRectangle() : null,
      color: Theme.of(context).primaryColor,
    );
  }

  FloatingActionButton _bottomFAB() {
    return _tabController!.index == 0
        ? FloatingActionButton(
            onPressed: () {
              _openAddMemberDialog();
              //_openAddMemberFlow();
            },
            child: Icon(Icons.person_add, size: 20.0),
          )
        : FloatingActionButton(
            onPressed: () {
              _openAddExpenditureDialog();
            },
            child: Icon(Icons.add, size: 20.0),
          );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shuttlers"),
        actions: [
          user == null
              ? IconButton(
                  onPressed: () async {
                    passwordDialog(context);
                  },
                  icon: Icon(Icons.login),
                )
              : IconButton(
                  onPressed: () async {
                    try {
                      await authOld.signOut();
                    } catch (e) {
                      print(e);
                    }
                  },
                  icon: Icon(Icons.logout),
                ),
          user == null
              ? Container()
              : IconButton(
                  onPressed: () async {
                    changePasswordDialog(context);
                  },
                  icon: Icon(Icons.update)),
        ],
        elevation: 5.0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Members"),
            Tab(text: "Expenditure"),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(5.0),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildMembers(),
            _buildExpenditure(),
          ],
        ),
      ),
      floatingActionButton: user != null ? _bottomFAB() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: _buildBottom(),
    );
  }
}
