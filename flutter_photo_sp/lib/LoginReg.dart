import 'package:flutter/material.dart';
import 'package:CMSC190_WildlifeMarkerJCGCabanlong/DialogBox.dart';
import 'Authenticate.dart';
import 'DialogBox.dart';



class LoginReg extends StatefulWidget
{

  LoginReg
  ({

      this.auth,
      this.onSignedIn,
  });

  final AuthImplementation auth;
  final VoidCallback onSignedIn;

  State<StatefulWidget> createState()
  {
    return _LoginRegState();
  }

}


enum FormType
  {
    login,
    register
  }

class _LoginRegState extends State<LoginReg>
{

  DialogBox dialogBox = new DialogBox();

  final formKey = new GlobalKey<FormState>();
  FormType _formType = FormType.login;
  String _email = "";
  String _password = "";


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

  void validateAndSubmit() async
    {
        if(validateAndSave())
          {
              try
                {
                    if(_formType == FormType.login)
                        {
                            String userId = await widget.auth.SignIn(_email, _password);
                           // dialogBox.information(context, "Congratulations ", "Your account has been logged in successfully");
                            print("login User ID = " + userId);
                        }
                    else
                        {
                          String userId = await widget.auth.SignUp(_email, _password);
                         // dialogBox.information(context, "Congratulations ", "Your account has been created successfully");
                          print("register User ID = " + userId);
                        }

                    widget.onSignedIn();
                }
              catch(e)
                {
                    dialogBox.information(context, "Error = ", e.toString());
                    print("Error: " + e.toString());
                }
          }
    }

  void moveToRegister()
  {
      formKey.currentState.reset(); //remove data from email and password field
      setState(()
      {
          _formType = FormType.register;
      });

  }

  void moveToLogin()
  {
    formKey.currentState.reset(); //remove data from email and password field
    setState(()
    {
      _formType = FormType.login;
    });

  }



  @override
  Widget build(BuildContext context)
  {
    // TODO: implement build
    return new Scaffold
      (
        resizeToAvoidBottomInset: true,
        appBar: new AppBar
          (
            title: new Text("Wildlife Marker")
          ),
          body: new Container
            (
              margin: EdgeInsets.all(15.0),

              child: new Form
                (
                  key: formKey,

                  child: new Column
                    (

                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: createInputs() + createButtons(),
                    ),
                ),
            ),

      );
  }




  List<Widget> createInputs()
    {
      return
        [
//            SizedBox(height: 10.0,),
            logo(),
//            SizedBox(height: 10.0,),

            new TextFormField
              (
                decoration: new InputDecoration(labelText: 'Email'),

                validator: (value)
                  {
                    return value.isEmpty ? 'Email required' : null;
                  },

                onSaved: (value)  //catch input
                  {
                    return _email= value;
                  },

              ),

            SizedBox(height: 10.0,),

            new TextFormField
              (
                decoration: new InputDecoration(labelText: 'Password'),
                obscureText: true, //hides password
                validator: (value)
                  {
                    return value.isEmpty ? 'Password is required' : null;
                  },

                onSaved: (value)
                  {
                    return _password= value;
                  },

              ),

            SizedBox(height: 20.0,),
        ];
    }

    Widget logo()
    {
      return new Hero
        (
          tag: 'hero',

            child: new CircleAvatar
              (
                backgroundColor: Colors.transparent,
                radius: 80.0,
                child: Image.asset('images/bio.jpg'),
              )
        );
    }


  List<Widget> createButtons()
  {
   if(_formType == FormType.login)
     {
       return
         [
           new RaisedButton
             (
             child: Text("Login", style:new TextStyle(fontSize: 20.0)),
             textColor: Colors.white,
             color: Colors.green,
             onPressed: validateAndSubmit,
           ),

           new FlatButton
             (
             child: new Text("Not have an Account? Create here", style:new TextStyle(fontSize: 14.0)),
             textColor: Colors.red,
             onPressed: moveToRegister,
           ),

         ];
     }

   else
       {
         return
         [
           new RaisedButton
             (
             child: new Text("Register", style:new TextStyle(fontSize: 20.0)),
             textColor: Colors.white,
             color: Colors.green,
             onPressed: validateAndSubmit,
           ),

           new FlatButton
             (
             child: new Text("Already have an account? Login here", style:new TextStyle(fontSize: 14.0)),
             textColor: Colors.red,
             onPressed: moveToLogin,
           ),

         ];
       }


  }

}