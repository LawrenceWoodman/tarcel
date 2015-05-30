# Tar archive
#
# Copyright (C) 2015 Lawrence Woodman <lwoodman@vlifesystems.com>
#
# Licensed under an MIT licence.  Please see LICENCE.md for details.
#

namespace import ::tarcel::tar

::oo::class create TarArchive {
  variable files

  constructor {} {
    set files [dict create]
  }


  # tarball begins immediately after first ^z (0x1a)
  method load {filename} {
    if {[::tvfs::exists $filename]} {
      set contents [::tvfs::read $filename]
    } else {
      set fd [open $filename r]
      set contents [read $fd]
      close $fd
    }

    set tarball [regsub "^(.*?\u001a)(.*)$" $contents {\2}]
    set filenames [tar getFilenames $tarball]

    foreach filename $filenames {
      dict set files $filename [tar getFile $tarball $filename]
    }
  }


  method importFiles {_files importPoint} {
    foreach filename $_files {
      if {![my IsValidImportFilename $filename]} {
        return -code error "can't import file: $filename"
      }
      set importedFilename [
        my RemoveDotFromFilename [file join $importPoint $filename]
      ]
      set fd [open $filename r]
      set contents [read $fd]
      close $fd
      dict set files $importedFilename $contents
    }
  }


  method fetchFiles {_files importPoint} {
    foreach filename $_files {
      if {![my IsValidFetchFilename $filename]} {
        return -code error "can't fetch file: $filename"
      }
      set importedFilename [
        my RemoveDotFromFilename [file join $importPoint [file tail $filename]]
      ]
      set fd [open $filename r]
      set contents [read $fd]
      close $fd
      dict set files $importedFilename $contents
    }
  }


  method importContents {contents filename} {
    dict set files $filename $contents
  }


  method export {} {
    tar create $files
  }


  method ls {} {
    dict keys $files
  }


  method exists {filename} {
    dict exists $files $filename
  }


  method read {filename} {
    dict get $files $filename
  }


  ######################
  # Private methods
  ######################

  method Write {dir filename contents} {
    file mkdir [file join $dir [file dirname $filename]]
    set finalFilename [file join $dir $filename]
    set fd [open $finalFilename w]
    puts -nonewline $fd $contents
    close $fd
  }


  method RemoveDotFromFilename {filename} {
    set splitFilename [file split $filename]
    set outFilename [list]

    foreach e $splitFilename {
      if {$e ne "."} {
        lappend outFilename $e
      }
    }

    return [file join {*}$outFilename]
  }


  method IsValidImportFilename {filename} {
    if {![file isfile $filename]} {
      return 0
    }

    set splitFilename [file split $filename]

    foreach e $splitFilename {
      if {$e eq ".."} {
        return 0
      }
    }

    return 1
  }


  method IsValidFetchFilename {filename} {
    if {![file isfile $filename]} {
      return 0
    }

    return 1
  }

}
