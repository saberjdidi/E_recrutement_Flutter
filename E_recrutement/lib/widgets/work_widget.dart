import 'package:e_recrutement/Search/profile_company.dart';
import 'package:e_recrutement/Services/global_methods.dart';
import 'package:e_recrutement/Services/global_variables.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class WorkWidget extends StatefulWidget {
  final String userId;
  final String userName;
  final String userEmail;
  final String phoneNumber;
  final String userImageUrl;

  const WorkWidget({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.phoneNumber,
    required this.userImageUrl
  });

  @override
  State<WorkWidget> createState() => _WorkWidgetState();
}

class _WorkWidgetState extends State<WorkWidget> {

  void _mailTo() async {

    var mailUrl = 'mailto: ${widget.userEmail}';

    if(await canLaunchUrlString(mailUrl)){
     await launchUrlString(mailUrl);
    }
   else {
     GlobalMethod.showErrorDialog(error: 'An error has occured', context: context);
     throw 'error occuror';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white10,
      elevation: 8,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
        onTap: (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfileCompanyScreen(userId: widget.userId)));
        },
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        leading: Container(
          padding: EdgeInsets.only(right: 12.0),
          decoration: BoxDecoration(
              border: Border(
                  right: BorderSide(width: 1)
              )
          ),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
              radius: 20,
              // ignore: prefer_if_null_operators
              child: Image.network(widget.userImageUrl==null ? userProfileImage : widget.userImageUrl)
          ),
        ),
        title: Text(
          widget.userName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18
          ),
        ),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Visite Profile',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.grey
              ),
            ),
            SizedBox(height: 8.0,),
            Text(
              '${widget.userEmail}',
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.mail_outline,
            size: 30,
            color: Colors.grey,
          ), onPressed: () {
          _mailTo();
        },
        ),
      ),
    );
  }
}
