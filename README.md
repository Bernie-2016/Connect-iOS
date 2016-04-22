# Connect

[![CI Status](https://img.shields.io/circleci/project/Bernie-2016/Connect-iOS/master.svg)](https://circleci.com/gh/Bernie-2016/Connect-iOS/tree/master)
[![codebeat badge](https://codebeat.co/badges/32b76d16-5a6d-4340-9417-8cc32f0a704a)](https://codebeat.co/projects/github-com-bernie-2016-connect-ios)

Mobile application for getting involved and keeping up with Bernie.

Tracker backlog: https://www.pivotaltracker.com/n/projects/1414740

Invision mocks: https://projects.invisionapp.com/share/ZH66QVQWJ

Slack channel (you can request access [here](https://docs.google.com/forms/d/1pmxGTX17qPkZV49iuLh3rN-Mj_Z6w6M_XtUJMZCMIP4/viewform)): https://codersforsanders.slack.com/messages/bernie-app/details/

# Setting up build environment

This app will compile with Xcode 7.0. It is bootstrapped using Carthage.

## Install carthage

Via [Homebrew](http://brew.sh/):

* `$ brew install carthage`

## Install dependencies

* `$ cd src/Connect && carthage bootstrap --platform ios`

You should now be able to run tests in Xcode by lightly depressing the key combination "⌘+u"

# Contributing

## Making changes

In order to make changes, you need to get your development environment set up, make your changes on a fork of the Connect repository and then issue a pull request.  Please follow the advice below to ensure that your contribution will be readily accepted.

### Make your changes

* Create a branch for your changes (optional, but highly encouraged)
* Write tests for your changes
* Make your tests pass by implementing your changes
* Ensure _all_ tests still pass
* Push your changes up to your fork at github

### Make a pull request

When you have finished making your changes and testing them, go to your forked repo on github and issue a pull request for the branch containing your changes.  Please keep in mind the following before submitting your pull request:

* We favor pull requests with very small, single commits with a single purpose.  If you have many changes, they'll be more readily received as separate pull requests
* Please include tests.  They help us understand your intent and prevent future changes from breaking your work.  Changes without tests are usually ignored
* Please ensure all tests pass before making a pull request.  Your contribution shouldn't break the app for other users
* Please ensure all trailing whitespace characters are removed from your changes.

You may find the rake task `am_i_done_yet` helpful with regards to this. Please note that this requires the installation of `swiftlint`:

```
$ brew install swiftlint
```

The rake task itself can be run by issuing the following command:

```
$ rake am_i_done_yet
```

This will check for uncommitted changes, remove trailing white space, unfocus the specs and finally run the specs. It will inform you if your code looks good-to-go!  
