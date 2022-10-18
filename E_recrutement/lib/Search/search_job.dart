import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_recrutement/Jobs/jobs_screen.dart';
import 'package:flutter/material.dart';

import '../widgets/job_widget.dart';

class SearchJob extends StatefulWidget {
  const SearchJob({Key? key}) : super(key: key);

  @override
  State<SearchJob> createState() => _SearchJobState();
}

class _SearchJobState extends State<SearchJob> {

  final TextEditingController _searchQueryController = TextEditingController();
  String searchQuery = 'Search query';

  Widget _buildSearchField(){
    return TextField(
      controller: _searchQueryController,
      autocorrect: true,
      decoration: InputDecoration(
        hintText: 'Search for job...',
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
        //bottomNavigationBar: BottomNavigationBarForApp(indexNum: 1),
        backgroundColor: Colors.transparent,
        appBar: AppBar(
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
          leading: IconButton(
            onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>JobScreen()));
            },
            icon: Icon(Icons.arrow_back),
          ),
          title: _buildSearchField(),
          actions: _buildActions(),
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
          .collection('jobs')
          .where('jobTitle', isGreaterThanOrEqualTo: searchQuery)
          .where('recruitment', isEqualTo: true)
          .snapshots(),
          builder: (Context, AsyncSnapshot snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return const Center(child: CircularProgressIndicator(),);
            }
            else if(snapshot.connectionState == ConnectionState.active){
              if(snapshot.data?.docs.isNotEmpty == true) {
                return ListView.builder(
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (BuildContext context, int index){
                      return JobWidget(
                          jobTitle: snapshot.data?.docs[index]['jobTitle'],
                          jobDescription: snapshot.data?.docs[index]['jobDescription'],
                          jobId: snapshot.data?.docs[index]['jobId'],
                          uploadedBy: snapshot.data?.docs[index]['uploadedBy'],
                          userImage: snapshot.data?.docs[index]['userImage'],
                          name: snapshot.data?.docs[index]['name'],
                          recruitment: snapshot.data?.docs[index]['recruitment'],
                          email: snapshot.data?.docs[index]['email'],
                          location: snapshot.data?.docs[index]['location']
                      );
                    }
                );
              }
              else  {
                Center(
                  child: Text('Empty List',
                    style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),),
                );
              }
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
