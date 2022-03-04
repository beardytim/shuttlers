import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hbcbc/data.dart';
import 'package:hbcbc/model/expense.dart';
import 'package:hbcbc/model/member.dart';
import 'package:hbcbc/ui/dialog/add_expenditure.dart';
import 'package:hbcbc/ui/dialog/add_member.dart';
import 'package:hbcbc/ui/widgets/member_card.dart';
import 'package:hbcbc/ui/widgets/expense_card.dart';
import 'package:hbcbc/ui/widgets/member_card_admin.dart';
import 'package:hbcbc/utils/pretty.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  Stream<QuerySnapshot>? membersStream;
  Stream<QuerySnapshot>? ledgerStream;

  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  @override
  void initState() {
    super.initState();

    this.user = auth.currentUser;
    auth.authStateChanges().listen((usr) {
      setState(() {
        this.user = usr;
      });
    });

    //tabcontroller
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController!.addListener(_handleTabIndex);

    //firestore streams
    //members orded by name
    membersStream = FirebaseFirestore.instance
        .collection(memberRef)
        .orderBy('name')
        .snapshots();
    //ledgers with category 1 will be shown here and ordered by date
    ledgerStream = FirebaseFirestore.instance
        .collection(ledgerRef)
        .orderBy('date', descending: true)
        .where('category', isEqualTo: 1)
        .snapshots();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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

  Future<void> _changePasswordDialog(BuildContext context) async {
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
                      // if persistance causing issues with the signedIn bool could just sign out before anyone logs in?!
                      //await auth.signOut();

                      await auth.currentUser!
                          .updatePassword(_passwordController.text);
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
        });
  }

  Future<void> _passwordDialog(BuildContext context) async {
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
                    // if persistance causing issues with the signedIn bool could just sign out before anyone logs in?!
                    //await auth.signOut();
                    await auth.signInWithEmailAndPassword(
                        email: "tim.simmonds1@gmail.com",
                        password: _passwordController.text);
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

  Widget build(BuildContext context) {
    Column _buildMembers() {
      return Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: membersStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
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
              stream: ledgerStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
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
          child: _tabController!.index == 0
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection(overviewRef)
                            .doc("0")
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<DocumentSnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Text(
                              'Something went wrong...',
                              style: TextStyle(color: Colors.white),
                            );
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
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
                  )
                  // child: FutureBuilder<DocumentSnapshot>(
                  //   future: FirebaseFirestore.instance
                  //       .collection(overviewRef)
                  //       .doc('0')
                  //       .get(),
                  //   builder: (BuildContext context,
                  //       AsyncSnapshot<DocumentSnapshot> snapshot) {
                  //     if (snapshot.hasError) {
                  //       return Text('something went wrong...');
                  //     }
                  //     if (snapshot.connectionState == ConnectionState.done) {
                  //       Map<String, dynamic> data =
                  //           snapshot.data!.data() as Map<String, dynamic>;
                  //       return Text(
                  //         'Bank: ${prettyMoney(data['bank'])}',
                  //         style: TextStyle(color: Colors.white),
                  //       );
                  //     }
                  //     return Text(
                  //       'Loading',
                  //       style: TextStyle(color: Colors.white),
                  //     );
                  //   },
                  // ),

                  )
              : null,
        ),
        shape: user != null ? CircularNotchedRectangle() : null,
        color: Colors.blue,
      );
    }

    FloatingActionButton _bottomFAB() {
      return _tabController!.index == 0
          ? FloatingActionButton(
              onPressed: () {
                _openAddMemberDialog();
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

    return Scaffold(
      appBar: AppBar(
        title: Text("hbcbc"),
        actions: [
          user == null
              ? IconButton(
                  onPressed: () async {
                    _passwordDialog(context);
                    // try {
                    //   // if persistance causing issues with the signedIn bool could just sign out before anyone logs in?!
                    //   //await auth.signOut();
                    //   await auth.signInWithEmailAndPassword(
                    //       email: "tim.simmonds1@gmail.com",
                    //       password: "TIMISCOOL");
                    // } catch (e) {
                    //   print(e);
                    // }
                    //await auth.currentUser().then((value) => print(value.email));
                  },
                  icon: Icon(Icons.login),
                )
              : IconButton(
                  onPressed: () async {
                    try {
                      await auth.signOut();
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
                    _changePasswordDialog(context);
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
