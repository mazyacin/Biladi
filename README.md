# Biladi


https://github.com/user-attachments/assets/c471ed2d-e37e-49cf-a522-365ee9ed3bf4



**Biladi is an example of a template i made to make tourist apps** 

It comes with a **fully working example for Algeria (APK format)**, but the template itself is very customizable   – you can rebrand it for any **city, region, or even culinary**  in just an **Hour**


This project started as a tourist app for Algeria, but evolved into a template that anyone can use to create their own tourist guide app.
---
**Key Features:**
- Full tourist guide structure **places**, **descriptions**, **images**
- finish quest button,and hear story button with saving when you close the app
- Easy to rebrand for your Country– change the some code and your done
- Works on **Android** and **IOS**



---
---<img width="1080" height="1920" alt="0050" src="https://github.com/user-attachments/assets/30544c8d-32d1-42ce-8f0a-0d8f8dfd3e35" />



---

**you can make a version of this app for your idea , Here are the Steps to do that **: 

**Step 1**: idea , get assets which are images and audio ,images you can get them from google and the audio you either make them with your own sound 
or you can go to voicertool.com which has text to speech  for free and you can choose which sound ( the one im using is Brian)

**Step 2**: the theme its good to get reference from your countries flag for example if you are French you should use blue, also make a slang word to put in the Biladi Text place

**Step 3** : this step explain the code ,firstly we have the QuestCard class which is the thing that makes all of this simple this is a class that lets you call QuestCard()and get

parameters to fill in and they are : 1 Id used for identifying this questCard from the other and for the buttons , 2 Title this is what shows up on the screen you can put in for 
example "the Eiffel tower", 3 imageUrl this is where you show the image  you put the path of your image make sure is 16/9 to show all of the image , 4 Gpsurl u basically so put in the google 
map URL here ,5 Location this is a small text that shows up bellow the image you put the name of location of this landmark and tap to go to the google map url ,6 Iscompleted this 
is for the complete button you put the Id inside it  it checks if you already completed the quest, 7 isAudioPlaying this is for the audio button you also put in it the id it checks 
if audio is playing,8 onComplete this toggles the completion status  put in Id,9 onListen this toggles the audio button  put in Id and audio path, i also uploaded a  picture to 
give you an example of a filled QuestCard

**Step 4** : the Icon for the app this is what shows up when you are about to enter the app on phone , you can make it whatever you want just make sure its 1024x1024 pixels

**Step 5**: your done just run "flutter build apk --released" to get the .apk and .ipa  ,you will find them in the "/build"folder
---
**NOTE**: to use the source code you need an IDE that works with flutter SDK which is a framework to make mobile apps these IDEs are VsCode and Android studio(**Note that android studio only compiles for android devices in .APK format**) then install flutter SDK and your ide then make a new flutter project and replace the pubspec.yaml and pubspec.lock with the ones in this repo then run **flutter clean flutter pub get** command then replace the source code in the /lib folder with the source code from this repo and add
