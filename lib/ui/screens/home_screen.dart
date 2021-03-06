import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:shuttlers/ui/screens/ledger_screen.dart';
import 'package:shuttlers/ui/screens/member_screen.dart';
import 'package:shuttlers/utils/pretty.dart';
import 'package:shuttlers/utils/store.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  MenuItem currentItem = MenuItems.members;

  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
      style: DrawerStyle.Style1,
      menuScreen: Builder(
        builder: (context) => MenuScreen(
          currentItem: currentItem,
          onSelectedItem: (item) {
            setState(() => currentItem = item);
            ZoomDrawer.of(context)!.close();
          },
        ),
      ),
      mainScreen: getScreen(),
      showShadow: true,
      angle: -12.0,
      backgroundColor: Theme.of(context).primaryColor,
      slideWidth: MediaQuery.of(context).size.width * 0.65,
    );
  }

  Widget getScreen() {
    switch (currentItem) {
      case MenuItems.members:
        return MemberScreen();
      case MenuItems.ledger:
        return LedgerScreen();
      default:
        return MemberScreen();
    }
  }
}

class MenuItem {
  final String title;
  final IconData icon;
  const MenuItem(this.title, this.icon);
}

class MenuItems {
  static const members = MenuItem('Members', Icons.people);
  static const ledger = MenuItem('Expenditure', Icons.list_alt_outlined);

  static const all = <MenuItem>[
    members,
    ledger,
  ];
}

class MenuScreen extends StatefulWidget {
  final MenuItem currentItem;
  final ValueChanged<MenuItem> onSelectedItem;

  const MenuScreen(
      {Key? key, required this.currentItem, required this.onSelectedItem})
      : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  Store store = Store();

  @override
  void initState() {
    auth.authStateChanges().listen((usr) {
      setState(() {
        this.user = usr;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage('icon/icon.png'),
                      radius: 50,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Shuttlers',
                      // style: Theme.of(context).textTheme.headline5,
                    )
                  ],
                ),
              ),
              Spacer(flex: 2),
              ...MenuItems.all.map(buildMenuItem).toList(),
              Spacer(flex: 2),
              ListTile(
                minLeadingWidth: 20,
                leading: Icon(Icons.account_balance),
                title: StreamBuilder<DocumentSnapshot>(
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
              ListTile(
                minLeadingWidth: 20,
                leading: user == null ? Icon(Icons.login) : Icon(Icons.logout),
                title: user == null ? Text("Login") : Text("Logout"),
                onTap: () async {
                  user == null
                      ? await passwordDialog(context)
                      : await auth.signOut();
                  //setState(() {});
                  ZoomDrawer.of(context)!.toggle();
                },
              ),
              user == null
                  ? Container()
                  : ListTile(
                      minLeadingWidth: 20,
                      leading: Icon(Icons.password),
                      title: Text('Change Password'),
                      onTap: () async {
                        await _changePasswordDialog(context);
                        ZoomDrawer.of(context)!.toggle();
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMenuItem(MenuItem item) => ListTile(
        selectedTileColor: Colors.black26,
        selectedColor: Colors.white,
        selected: widget.currentItem == item,
        minLeadingWidth: 20,
        leading: Icon(item.icon),
        title: Text(item.title),
        onTap: () => widget.onSelectedItem(item),
      );

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
                  try {
                    await auth.signInWithEmailAndPassword(
                        email: 'tim.simmonds1@gmail.com',
                        password: _passwordController.text);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text("Logged in!")));
                  } catch (e) {
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
}
