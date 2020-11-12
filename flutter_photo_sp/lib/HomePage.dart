import 'package:flutter/material.dart';
import 'Authenticate.dart';
import 'UploadPhoto.dart';
import 'Posts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';


class HomePage extends StatefulWidget
  {

      HomePage
      ({
          this.auth,
          this.onSignedOut,

      });

      final AuthImplementation auth;
      final VoidCallback onSignedOut;


      @override
      State<StatefulWidget> createState()
      {
          return _HomePageState();
      }
  }



  class _HomePageState extends State<HomePage>
    {
      final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
      List<Posts> postsList = [];
      String uploaderIdValue;
//      String uid;


      @override
  void initState()
      {
        super.initState();
        DatabaseReference postsReference = FirebaseDatabase.instance.reference().child("Posts"); // source from database
        postsReference.once().then((DataSnapshot snap)
          async{
              var KEYS = snap.value.keys; //save unique key number of each post to KEY
              var DATA = snap.value;

              getCurrentUser();
//              print(uid);
//              uploaderIdValue = getCurrentUser();

              postsList.clear();  //makes sure every opening of the posts in homepage is fresh and update

              for(var eachKey in KEYS)
                {

                      Posts posts = new Posts
                        (
                          DATA[eachKey]['image'],
                          DATA[eachKey]['description'],
                          DATA[eachKey]['date'],
                          DATA[eachKey]['time'],
                          DATA[eachKey]['uploaderId'],
                          DATA[eachKey]['imgLatitude'],
                          DATA[eachKey]['imgLongitude'],
                        );
                      await getCurrentUser(); //fetches current user id
                      if(posts.uploaderId == uploaderIdValue){  // checks if current user owns which image post
//                        print(uploaderIdValue); // check if uploaderIdValue gets the actual firebase uid from firebase
//                        print(posts.uploaderId);  // check jf posts.uploaderId gets the image user id data
                        postsList.add(posts); // posts image to homepage if image user id is same as current user id
                      }
                }

                setState(()
                  {
                      print('Length : $postsList.length');
                      //getCurrentUser();
                  });
          });
      }

      void _logOutUser() async
        {
            try
              {
                  await widget.auth.signOut();
                  widget.onSignedOut();
              }
            catch(e)
              {
                  print(e.toString());
              }
        }


      Future<void> getCurrentUser() async // function for getting current user id, for checking against user id saved per image
      {
        User user = await _firebaseAuth.currentUser;
         final uid = user.uid;
         uploaderIdValue = uid;

      }


        @override
        Widget build(BuildContext context) {

          return new Scaffold
            (
                  appBar: new AppBar
                    (
                        title: new Text('Home'),
                    ),

                  body: new Container     //posts will be put here
                    (
                        child: postsList.length == 0 ? new Text("You have no post yet") : new ListView.builder
                          (
                            itemCount: postsList.length,
                            itemBuilder: (_, index)
                              {
                                return PostsUI(postsList[index].image, postsList[index].description, postsList[index].date, postsList[index].time);
                              }
                          ),
                    ),

                    bottomNavigationBar: new BottomAppBar
                      (
                          color: Colors.blue,

                          child: new Container
                            (
                                margin: const EdgeInsets.only(left: 50.0, right: 50.0),
                                child: new Row
                                  (
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,

                                      children: <Widget>
                                      [
                                          new IconButton
                                            (
                                              icon: new Icon(Icons.assignment_return),
                                              iconSize: 40,
                                              color: Colors.white,
                                              onPressed: _logOutUser,
                                            ),

                                          new IconButton
                                            (
                                              icon: new Icon(Icons.add_a_photo),
                                              iconSize: 40,
                                              color: Colors.white,
                                              onPressed: ()
                                                {
                                                    Navigator.push
                                                      (
                                                        context, MaterialPageRoute(builder: (context)
                                                          {
                                                              return new PhotoUploadPage();
                                                          })
                                                      );
                                                },
                                            ),

                                      ],
                                  ),
                            ),
                      ),

            );
        }

        Widget PostsUI(String image, String description, String date, String time)
          {
              return new Card
                (
                    elevation: 10.0,
                    margin : EdgeInsets.all(15.0),

                    child: new Container
                      (
                         padding: new EdgeInsets.all(14.0),

                          child: new Column
                            (
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>//for displaying time
                                  [
                                      new Row   // single row to display date and time
                                        (
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>
                                          [
                                            new Text
                                              (
                                              date,
                                              style: Theme.of(context).textTheme.subtitle,
                                              textAlign: TextAlign.center,
                                            ),

                                            new Text
                                              (
                                              time,
                                              style: Theme.of(context).textTheme.subtitle,
                                              textAlign: TextAlign.center,
                                            )

                                          ],
                                        ),

                                        SizedBox(height: 10.0,),

                                        new Image.network(image, fit: BoxFit.cover),  //image here

                                        SizedBox(height: 10.0,),  //space

                                        new Text
                                          (
                                          description,
                                          style: Theme.of(context).textTheme.subhead,
                                          textAlign: TextAlign.center,
                                        )



                                  ],
                            ),



                      ),
                );
          }
    }