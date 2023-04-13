import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class User {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String avatar;
  final String createdAt;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.avatar,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      avatar: json['avatar'],
      createdAt: json['created_at'],
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<dynamic>> _futureData;

  Future<List<dynamic>> fetchData() async {
    final response =
        await http.get(Uri.parse('https://reqres.in/api/users?page=2'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> usersData = responseData['data'];

      return usersData;
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    _futureData = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: CustomAppBar(title: 'Zigy'),
        body: FutureBuilder<List<dynamic>>(
          future: _futureData,
          builder:
              (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  final user = User.fromJson(snapshot.data![index]);
                  return UserCard(user: user);
                },
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('${snapshot.error}'));
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final User user;

  const UserCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDetailsScreen(user: user),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.lightBlue[100],
            border: Border.all(
              color: Colors.blue[900]!,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            leading: CircleAvatar(
              radius: 30.0,
              backgroundImage: NetworkImage(user.avatar),
            ),
            title: Text(
              user.fullName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(user.email),
            trailing: Icon(Icons.arrow_forward),
          ),
        ),
      ),
    );
  }
}

class UserDetailsScreen extends StatelessWidget {
  final User user;

  const UserDetailsScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.fullName),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                radius: 60.0,
                backgroundImage: NetworkImage(user.avatar),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Name: ${user.fullName}',
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Email: ${user.email}',
                style: const TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 16.0),
              Text(
                'ID: ${user.id}',
                style: const TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Created At: ${user.createdAt}',
                style: const TextStyle(fontSize: 18.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 28.0,
          color: Colors.black,
          letterSpacing: 1.5,
        ),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search),
          color: Colors.black,
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings),
          color: Colors.black,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
