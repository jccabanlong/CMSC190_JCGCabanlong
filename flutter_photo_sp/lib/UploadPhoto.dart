import 'package:flutter/material.dart';
import 'package:CMSC190_WildlifeMarkerJCGCabanlong/HomePage.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:location_and_image_picker/utils.dart';
import 'dart:io';
import 'HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exif/exif.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:location_and_image_picker/fullpage_location_and_pic_picker.dart';
// import 'package:flutter_geofire/flutter_geofire.dart';



class PhotoUploadPage extends StatefulWidget
  {
      State<StatefulWidget> createState()

        {
            return _UploadPhotoPageState();
        }
  }


class _UploadPhotoPageState extends State<PhotoUploadPage>
    {
      final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
      Map<String, String> _getValue = new Map();
      String pathToReference = "url";
      File sampleImage;
      final formKey = new GlobalKey<FormState>();
      String _myValue;  //variable for storing photo description
      String url; //for photo url
      String uploaderId = "uninitialized";
      bool _imgHasLocation;
      double imgLatitude;
      double imgLongitude;




      getImage(BuildContext Context) async
        {
          var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery); //lets user pick image in the gallery
          printExifOf(tempImage.path);
          setState(() {
              sampleImage =tempImage;
              imgLatitude=0.0;
              imgLongitude=0.0;
          _checkGPSData(sampleImage);
          printExifOf(sampleImage.path);
//              imgLocation = geo.point(latitude: 12.960632, longitude: 77.641603);
              print(uploaderId.toString());
              print('after this must be the geotag');
//            printExif
          });
          Navigator.of(context).pop();  // pop context to close widget dialog
        }
      _openCamera(BuildContext context) async{
        var picture = await ImagePicker.pickImage(source: ImageSource.camera);
        printExifOf(picture.path);
        setState((){
          // imageFile =  picture;
          sampleImage = picture;
          imgLatitude=0.0;
          imgLongitude=0.0;
          _checkGPSData(sampleImage);
          printExifOf(sampleImage.path);
//              imgLocation = geo.point(latitude: 12.960632, longitude: 77.641603);
          print(uploaderId.toString());
          print('after this must be the geotag');
        });
        Navigator.of(context).pop();  // pop context to close widget dialog
        // Navigator.of(context, rootNavigator: true).pop();
      }

      Future<void> _showDialogs(BuildContext context){
        return showDialog(context: context, builder:(BuildContext context){
          getCurrentUser();
          return AlertDialog(
            title: Text("Choose"),
            content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    GestureDetector(
                      child: Text("Gallery"),
                      onTap: (){
                        getImage(context);
                      },
                    ),
                    Padding(padding: EdgeInsets.all(8.0)),
                    GestureDetector(
                      child: Text("Camera"),
                      onTap: (){
                        _openCamera(context);
                      },
                    )
                  ],
                )
            ),
          );
        }
        );}

        bool validateAndSave()
          {
            final form = formKey.currentState;

            if(form.validate())
              {
                form.save();
                return true;
              }
            else
              {
                return false;
              }
          }

      Future <void> _checkGPSData(File file) async {
        File toCheck = file;
        Map<String, IfdTag> imgTags = await readExifFromBytes( File(toCheck.path).readAsBytesSync() );

        if (imgTags.containsKey('GPS GPSLongitude')) {
          setState(() {
            _imgHasLocation = true;

            for (String key in imgTags.keys) {
              print("$key (${imgTags[key].tagType}): ${imgTags[key]}");
            }
            exifGPSToLatLong(imgTags);
            print("results after invoking checkgps and exif to geotag");
            print(imgLatitude.toString());
            print(imgLongitude.toString());
          });
        }

      }


      void exifGPSToLatLong(Map<String, IfdTag> tags) {

        final latitudeValue = tags['GPS GPSLatitude'].values.map<double>( (item) => (item.numerator.toDouble() / item.denominator.toDouble()) ).toList();
        final latitudeSignal = tags['GPS GPSLatitudeRef'].printable;


        final longitudeValue = tags['GPS GPSLongitude'].values.map<double>( (item) => (item.numerator.toDouble() / item.denominator.toDouble()) ).toList();
        final longitudeSignal = tags['GPS GPSLongitudeRef'].printable;

        double latitude = latitudeValue[0]
            + (latitudeValue[1] / 60)
            + (latitudeValue[2] / 3600);

        double longitude = longitudeValue[0]
            + (longitudeValue[1] / 60)
            + (longitudeValue[2] / 3600);

        if (latitudeSignal == 'S') latitude = -latitude;
        if (longitudeSignal == 'W') longitude = -longitude;

            this.imgLatitude = latitude;  //set the latitude and longitude variables after computing for lat and long
            this.imgLongitude = longitude;
//          this.imgLocation.latitude = latitude;
//          this.imgLocation.longitude = longitude;
      }


     void printExifOf(String path) async {
        Map<String, IfdTag> data = await readExifFromBytes(await new File(path).readAsBytes());

        if (data == null || data.isEmpty) {
          print("No EXIF information found\n");
          return;
        }

        if (data.containsKey('JPEGThumbnail')) {
          print('File has JPEG thumbnail');
          data.remove('JPEGThumbnail');
        }
        if (data.containsKey('TIFFThumbnail')) {
          print('File has TIFF thumbnail');
          data.remove('TIFFThumbnail');
        }

        for (String key in data.keys) {
          print("$key (${data[key].tagType}): ${data[key]}");
        }
          // save the IMAGE LAT-LONG to geopoint data variable here
      }




      void uploadChoiceImage() async
            {

              if(validateAndSave())
                {
//                    _checkGPSData();
                    final Reference postImageRef = FirebaseStorage.instance.ref().child("Upload Images");  // folder for posted

                    var timeKey = new DateTime.now();   // names every upload to corresponding time

                    final UploadTask uploadTask = postImageRef.child(timeKey.toString() + ".jpg:").putFile(sampleImage); // name of the file depends on given timekey

                    var ImageUrl = await (await uploadTask.whenComplete(() => null)).ref.getDownloadURL();  //store image url to ImageUrl

                    url = ImageUrl.toString();  //converts value of ImageUrl to string then saves it to variable 'url'
                    // String pathToReference = "url";   // trial for using geofire
                    // Geofire.initialize(pathToReference);  //trial for using geofire

                    // bool response = await Geofire.setLocation(new DateTime.now().millisecondsSinceEpoch.toString(), imgLatitude, imgLongitude);


                    print("Image URL = " + url);  // show url on console


                    goToHomePage();

                    saveToDatabase(url);  // pass url to saving function

                }
            }

      Future<void> getCurrentUser() async // function for getting current user id, for checking against user id saved per image
          {
        User user = await FirebaseAuth.instance.currentUser;
        final uid = user.uid;
        uploaderId = uid;
      }

    Future saveToDatabase (url)
      async{
          var databaseKey = new DateTime.now();
          var formatDate = new DateFormat('MMM d, yyyy');   //format for date
          var formatTime = new DateFormat('EEEE, hh:mm aaa'); //format for time

          String date = formatDate.format(databaseKey); //save date
          String time = formatTime.format(databaseKey); //save time
          DatabaseReference ref = FirebaseDatabase.instance.reference();
//          _checkGPSData();
//          GeoFirePoint locationShot = _imgLocation;


          print(uploaderId); //if uploaderid has been saved, should print right here
          var data =
            {
                "image": url,   //url value
                "description" : _myValue, //description
                "date"  : date,
                "time"  : time,
                "uploaderId" : uploaderId,  //uploader id for tracking owner per post
                "imgLatitude" : imgLatitude,  //latitude for geolocation
                "imgLongitude" : imgLongitude,  //longitude for geolocation
            };

          ref.child("Posts").push().set(data);  //saves the data to posts
      }





      void goToHomePage()
        {
          Navigator.push
            (
                context,
                MaterialPageRoute(builder: (context)
                  {
                    return new HomePage();
                  }
                )

            );
        }

      @override
      Widget build(BuildContext context)
      {

        return new Scaffold
          (
          appBar: new AppBar
            (
            title:  new Text("Upload Image"),
            centerTitle: true,
          ),

          body: new Center
            (
            child: sampleImage == null ? Text("Select and Image to upload ") : enableUpload(),    //if null, prompt to select an image
          ),

          floatingActionButton: new FloatingActionButton    // show button for uploading image
            (
            onPressed: (){
              _showDialogs(context);
            },child:  new Icon(Icons.add_a_photo),)
        );
      }

      Widget enableUpload()
      {
        return new Container
          (
          child: new Form
            (
            key: formKey,
            child: Column
              (
              children: <Widget>
              [
                TextFormField   // gets description from user about the photo

                  (
                  decoration: new InputDecoration(labelText: "Give a brief description about your upload"),

                  validator: (value)
                  {
                    return value.isEmpty ? 'Description required' : null;
                  },
                  onSaved: (value)
                  {
                    return _myValue = value;
                  },
                ),

//                SizedBox(height: 15.0,),
                Image.file(sampleImage, height: 310.0, width: 620.0,),
//                SizedBox(height: 15.0,),
                RaisedButton
                  (
                  elevation:  10.0,
                  child: Text("Add a new post"),
                  textColor:  Colors.white,
                  color: Colors.green,

                  onPressed: uploadChoiceImage,
                )





              ],

            ),

          ),
        );
      }


    }