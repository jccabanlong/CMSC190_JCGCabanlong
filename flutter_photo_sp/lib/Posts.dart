import 'package:flutter/material.dart';



class Posts
  {
    String image, description, date, time, uploaderId;  //add user id
    double imageLatitude, imgLongitude;

    Posts(this.image, this.description, this.date, this.time, this.uploaderId, this.imgLongitude, this.imageLatitude);

  }