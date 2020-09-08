# App Home, Fed
Inspired by two of the ideas that dominated the year 2020, staying at home and the economic crisis, this application for iOS aims to help in the distribution of donated food. Its main characteristics are the following:

## Social distancing
Inspired by the COVID-19 pandemic of 2020, this application helps in social distancing by encouraging closer hearts.

## No internet
Many people at risk have no access to the Internet. With this application we can help even these people.

The application has three roles:

**Photo:** In some communities families that need donations hang a cloth on the window. Photographing these houses is the function that characterizes this application. All it takes is one person with internet access to help many who do not have the same access. Easy as taking a photo, the application registers in a central database the photo and location for volunteers to deliver the food basket.

**Donate:** Inform the application how many food baskets are available.

**Deliver:** Volunteers who can pick up the food and take it to those in need.

# About the current state of the application
This application was developed as part of a master in software engineering. It performs all three functions. It needs many corrections and improvements. The implementation decisions were made in a context without flexibility of time and resources, so everything can be changed, excluding simplicity. :-)

This version is using Firebase, so you will need to create a Firebase project with Firestore and Storage. Download GoogleService-Info.plist, change the bundle in Xcode and this should be enough to run the application.

In the Storage service access rules I am using the code below, for security reasons:

```
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
    match /e3ve3r5t1/{allPaths=**} {
    	allow read, write;
    }
  }
}
```
