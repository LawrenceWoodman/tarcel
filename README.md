tarcel
======
A Tcl packaging tool

Tarcel allows you to combine a number of files together to create a single tarcel file that can ben run by tclsh, wish, or can be sourced into another tcl script.  This makes it easy to distribute your applications as a single file.  In addition it allows you to easily create Tcl modules made-up of several files including shared libraries, and then take advantage of the extra benefits that Tcl modules provide such as faster loading time.

Requirements
------------
*  Tcl 8.6
*  [configurator](https://github.com/LawrenceWoodman/configurator_tcl) module

Definition of Terms
-------------------
<dl>
  <dt>tarcel</dt>
  <dd>A file that has been packaged with the tarcel script.  This is pronounced to rhyme with parcel.</dd>
  <dt>.tarcel</dt>
  <dd>The file that describes how to create the <em>tarcel</em> file.  Pronounced 'dot tarcel'.</dd>
  <dt>tarcel.tcl</dt>
  <dd>The packaging tool script.</dd>
</dl>

Usage
-----
Tarcel is quite easy to use and implements just enough functionality to work for the tasks it has been put to so far.

### Creating a package ###
To create a <em>tarcel</em> file you begin by creating a <em>.tarcel</em> file to describe how to package the <em>tarcel</em> file.  See below for what to put in this file.  You then use the <em>wrap</em> command of <em>tarcel.tcl</em> to create the package.

To create a <em>tarcel</em> called <em>t.tcl</em> out of <em>tarcel.tcl</em> and its associated files using <em>tarcel.tarcel</em> run:

    $ tclsh tarcel.tcl wrap -o t.tcl tarcel.tarcel

The <em>.tarcel</em> file may specifiy the output filename, in which case you don't need to supply `-o outputFilename`.

### Getting Information About a Package ###
To find out some information about a package use the <em>info</em> command of <em>tarcel.tcl</em>.  For the example above, to look at <em>t.tcl</em> run:

    $ tclsh tarcel.tcl info t.tcl

### Defining a .tarcel File ###
To begin with it is worth looking at the <em>tarcel.tarcel</em> file supplied in the repo.  This <em>.tarcel</em> file is used to wrap <em>tarcel.tcl</em>.

A <em>.tarcel</em> file is a Tcl script which has the following Tcl commands available to it:

* file (only supports subcommands: dirname, join and tail)
* foreach
* glob
* if
* lassign
* list
* llength
* lsort
* regexp
* regsub
* set
* string

In addition it has the following commands to control packaging:
<dl>
  <dt>config set varName value</dt>
  <dd>Sets variables such as <em>version</em>, <em>homepage</em> and <em>init</em>.  The latter is used to set the initialization code for the package to load the rest of the code.</dd>

  <dt>error msg</dt>
  <dd>Quit processing a <em>.tarcel</em> with an error message.</dd>

  <dt>fetch importPoint files</dt>
  <dd>Gets the specified <em>files</em> and places them all at the directory specified by <em>importPoint</em> in the package.  The relative directory structure of the files will not be preserved.</dd>

  <dt>import importPoint files</dt>
  <dd>Gets the specified <em>files</em> and places them at the directory specified by <em>importPoint</em> in the package relative to their original directory structure.</dd>

  <dt>find module [requirement] ...</dt>
  <dd>Find the location of a Tcl module.  You can also specify the version requirements for the module.</dd>

  <dt>get packageLoadCommands packageName</dt>
  <dd>Returns the commands to load the package from <code>package ifneeded</code>.</dd>

  <dt>tarcel destination .tarcelFile [arg] ...</dt>
  <dd>Use the <em>.tarcelFile</em> file to package some other code and include the resulting <em>tarcel</em> file at destination in the calling <em>tarcel</em> file.  If you pass any further arguments, then the Tcl variable <code>args</code> will be set with these.</dd>
</dl>

Contributions
-------------
If you want to improve this program make a pull request to the [repo](https://github.com/LawrenceWoodman/tarcel) on github.  Please put any pull requests in a separate branch to ease integration and add a test to prove that it works.

Licence
-------
Copyright (C) 2015, Lawrence Woodman <lwoodman@vlifesystems.com>

This software is licensed under an MIT Licence.  Please see the file, LICENCE.md, for details.
