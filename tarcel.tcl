#! /usr/bin/env tclsh
# A utility to package files into a 'tarcel'.
#
# Copyright (C) 2015 Lawrence Woodman <lwoodman@vlifesystems.com>
#
# Licensed under an MIT licence.  Please see LICENCE.md for details.
#

set ThisScriptDir [file dirname [info script]]
set LibDir [file join $ThisScriptDir lib]

if {![namespace exists ::tarcel::tvfs]} {
  source [file join $LibDir parameters.tcl]
  source [file join $LibDir xplatform.tcl]
  source [file join $LibDir tar.read.tcl]
  source [file join $LibDir tararchive.read.tcl]
}

source [file join $LibDir version.tcl]
source [file join $LibDir compiler.tcl]
source [file join $LibDir config.tcl]
source [file join $LibDir tar.write.tcl]
source [file join $LibDir tararchive.write.tcl]


proc handleParameters {parameters} {
     set usage "Usage: tarcel.tcl command \[option\] ...\ncommands:\n"
  append usage "    wrap \[options\] <.tarcel filename>   - Wrap files using .tarcel file\n"
  append usage "    info <tarcel filename>    - Information about tarcel file\n"
  append usage "\n\n"
  append usage "    wrap options:\n"
  append usage "      -o          - Output filename\n"

  if {[llength $parameters] < 2} {
    puts stderr "Error: invalid number of arguments\n"
    puts stderr $usage
    exit 1
  }

  lassign $parameters command
  set commandArgs [lrange $parameters 1 end]

  switch $command {
    wrap {
      set switchesWithValue {-o}
      lassign [::tarcel::parameters::getSwitches $switchesWithValue \
                                                 {} \
                                                 {*}$commandArgs] \
              switches \
              argsLeft
      if {[llength $argsLeft] != 1} {
        puts stderr "Error: invalid number of arguments\n"
        puts stderr $usage
        exit 1
      }
      set dotTarcelFilename [lindex $argsLeft end]

      if {[dict exists $switches -o]} {
        wrap $dotTarcelFilename [dict get $switches -o]
      } else {
        wrap $dotTarcelFilename
      }
    }

    info {
      if {[llength $commandArgs] != 1} {
        puts stderr "Error: invalid number of arguments\n"
        puts stderr $usage
        exit 1
      }
      lassign $commandArgs tarcelFilename
      getInfo $tarcelFilename
    }

    default {
      puts stderr "Error: invalid command: $command\n"
      puts stderr $usage
      exit 1
    }
  }
}


proc wrap {dotTarcelFilename {outputFilename {}}} {
  set startDir [pwd]
  cd [file dirname $dotTarcelFilename]
  set config [::tarcel::Config new]
  try {
    set configSettings [$config load [file tail $dotTarcelFilename]]
  } on error {result options} {
    puts stderr "Error in $dotTarcelFilename: $result"
    exit 1
  }

  if {$outputFilename eq {}} {
    if {[dict exists $configSettings outputFilename]} {
      set outputFilename [dict get $configSettings outputFilename]
      puts "Output filename: $outputFilename"
    } else {
      puts stderr "Error: no output filename specified"
      exit 1
    }
  }

  if {[file exists $outputFilename]} {
    puts stderr "Error: output file already exists: $outputFilename"
    exit 1
  }

  lassign [compiler::compile $configSettings] startScript tarball
  cd $startDir
  set fd [open $outputFilename w]
  puts -nonewline $fd $startScript
  fconfigure $fd -translation binary
  puts -nonewline $fd $tarball
  close $fd
}


proc getInfo {tarcelFilename} {
  try {
    set tarball [::tarcel::tar::extractTarballFromFile $tarcelFilename]
    uplevel 1 [::tarcel::tar::getFile $tarball lib/commands.tcl]
    set info [::tarcel::commands::info $tarball]
    displayInfo $tarcelFilename $info
  } on error {} {
    puts stderr "Error: invalid tarcel file: $tarcelFilename"
    exit 1
  }
}


proc displayInfo {tarcelFilename info} {
  puts "Information for tarcel: $tarcelFilename"
  puts "Created with tarcel.tcl version: [dict get $info tarcel_version]\n"
  if {[dict exists $info homepage]} {
    puts "  Homepage: [dict get $info homepage]"
  }
  if {[dict exists $info version]} {
    puts "  Version: [dict get $info version]"
  }
  puts "  Files:"
  foreach filename [dict get $info filenames] {
    puts "    $filename"
  }
}


proc main {parameters} {
  set startDir [pwd]
  handleParameters $parameters
  cd $startDir
}


main $argv
