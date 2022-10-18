import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_recrutement/widgets/work_widget.dart';
import 'package:flutter/material.dart';

import '../api/firebase_api.dart';
import '../model/user_model.dart';
import '../widgets/bottom_nav_bar.dart';

class AllWorksScreen extends StatefulWidget {
  const AllWorksScreen({Key? key}) : super(key: key);

  @override
  State<AllWorksScreen> createState() => _AllWorksScreenState();
}

class _AllWorksScreenState extends State<AllWorksScreen> {

  final TextEditingController _searchQueryController = TextEditingController();
  String searchQuery = 'Search query';
  List<User> listUser = List<User>.empty(growable: true);

  Widget _buildSearchField(){
    return TextField(
      controller: _searchQueryController,
      autocorrect: true,
      decoration: InputDecoration(
        hintText: 'Search for companies...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white),
      ),
      style: TextStyle(color: Colors.white, fontSize: 16.0 ),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  List<Widget> _buildActions(){
    return <Widget>[
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: (){
          _clearSearchQuery();
        },
      )
    ];
  }

  void _clearSearchQuery(){
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery('');
    });
  }
  void updateSearchQuery(String newQuery){
    setState(() {
      searchQuery = newQuery;
      debugPrint('search query : $searchQuery');
    });
  }

  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
  getData() async {
    FirebaseFirestore.instance.collection('users')
    .where('name', isGreaterThanOrEqualTo: searchQuery)
     .snapshots().listen((event) {
      event.docs.forEach((element) {
        print('id : ${element.id}');
        print('name ${element.data()['name']}');
        var model = User();
        model.id = element.data()['id'];
        model.name = element.data()['name'];
        model.email = element.data()['email'];
        model.location = element.data()['location'];
        model.userImage = element.data()['userImage'];
        model.phoneNumber = element.data()['phoneNumber'];
        model.createdAt = element.data()['createdAt'];
        listUser.add(model);
        listUser.forEach((element) {
          print('user : ${model.name} - ${model.email} - ${model.phoneNumber}');
        });
      });
    });
  }
  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.deepOrange.shade300, Colors.blueAccent],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [0.2, 0.9]
          )
      ),
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBarForApp(indexNum: 1),
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          //title: const Text('All Works Screen'),
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.deepOrange.shade300, Colors.blueAccent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: [0.2, 0.9]
                )
            ),
          ),
          automaticallyImplyLeading: false,
          title: _buildSearchField(),
          actions: _buildActions(),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseApi().getUsers(searchQuery),
          //FirebaseFirestore.instance.collection('users').where('name', isGreaterThanOrEqualTo: searchQuery).snapshots(),
          builder: (context, AsyncSnapshot snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return const Center(child: CircularProgressIndicator(),);
            }
            else if(snapshot.hasData){
              if(snapshot.data!.docs.isNotEmpty) {
                //listUser = snapshot.data!.docs.map((doc) => User.fromJson(doc.data() as Map<String, dynamic>)).toList();
                //first method
               return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index){
                      return WorkWidget(
                          userId: snapshot.data!.docs[index]['id'],
                          userName: snapshot.data!.docs[index]['name'],
                          userEmail: snapshot.data!.docs[index]['email'],
                          phoneNumber: snapshot.data!.docs[index]['phoneNumber'],
                          userImageUrl: snapshot.data!.docs[index]['userImage']
                      );
                    }
                );
                //second method
               /* return ListView.builder(
                    itemCount: listUser.length,
                    itemBuilder: (BuildContext context, int index){
                      return WorkWidget(
                          userId: listUser[index].id!,
                          userName: listUser[index].name!,
                          userEmail: listUser[index].email!,
                          phoneNumber: listUser[index].phoneNumber!,
                          userImageUrl: listUser[index].userImage!
                      );
                    }
                ); */
              }
              else  {
                Center(
                  child: Text('Empty List',
                    style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),),
                );
              }
            }
            else if(snapshot.hasError){
              return Center(
                child: Text('An error has occured',
                  style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),),
              );
            }
            return Center(
              child: Text('Something went wrong',
                style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),),
            );
          },
        ),
      ),
    );
  }
}
