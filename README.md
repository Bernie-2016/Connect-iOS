# BernieApp

Mobile application for getting involved and keeping up with Bernie.

Tracker backlog: https://www.pivotaltracker.com/n/projects/1414740

Slack channel (you can request access [here](https://docs.google.com/forms/d/1pmxGTX17qPkZV49iuLh3rN-Mj_Z6w6M_XtUJMZCMIP4/viewform)): https://codersforsanders.slack.com/messages/bernie-app/details/

# Setting up build environment

This app will compile with Xcode 6.4. It is bootstrapped using Carthage for project file purity reasons.

## Install carthage

* `brew install carthage`

## Install dependencies

* `carthage bootstrap --platform ios`

You should now be able to run tests in Xcode by pressing "CMD+u"

# Contributing

## Making changes

In order to make changes, you need to get your development environment set up, make your changes on a fork of the BernieiOS repository and then issue a pull request.  Please follow the advice below to ensure that your contribution will be readily accepted.

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

