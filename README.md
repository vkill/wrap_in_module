# WrapInModule

This is a Ruby gem I created to house the functionality to be able to wrap
various things inside modules. The primary focus of it was to be able to load a
ruby file in using a module as namespace for all the top level Constants,
Methods, Classes, Modules, etc. This does the same for any sub ruby scripts
that are required as well.

I found this functionality in a ruby script, supprisingly called script.rb
written by Joel VanderWerf released under the Ruby license in 2004. I have
simply wrapped his script inside a gem so that this functionality can be easily
accessed. The following is the description provided with Joel's script with my
gem namespacing.

`WrapInModule::Script` is a subclass of Module. A module which is an instance
of the `WrapInModule::Script` class encapsulates in its scope the top-level
methods, top-level constants, and instance variables defined in a ruby script
file (and its dependent files) loaded by a ruby program. This allows use of
script files to define objects that can be loaded into a program in much the
same way that objects can be loaded from YAML or Marshal files.

## Installation

Add this line to your application's Gemfile:

    gem 'wrap_in_module'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wrap_in_module

## Synopsis

**program.rb:**

    require 'wrap_in_module'
    my_script = WrapInModule::Script.load("my-script.rb")
    p my_script::VALUE
    my_script.run

**my-script.rb:**

    VALUE = [1,2,3]
    def run
      puts "#{self} running."
    end

**output:**

    $ ruby program.rb
    [1, 2, 3]
    #<Script:/tmp/my-script.rb> running.

## Usage

`WrapInModule::Script` modules are instantiated with
<tt>WrapInModule::Script.new(main_file)</tt> or the alias
<tt>WrapInModule::Script.load(main_file)</tt>. All the top-level constants and
top-level methods that are defined in the +main_file+ and its dependent local
files (see below) are scoped in the same Script module, and are thereby
available to the calling program.

The +main_file+ can load or require other files with +load+ and +require+, as
usual. These methods, in the `WrapInModule::Script` context, add some behavior
to the +Kernel+ +load+ and +require+ methods:
<tt>WrapInModule::Script#load</tt> and <tt>WrapInModule::Script#require</tt>
first search for files relative to the +main_file+'s dir. Files loaded in this
way ("dependent local files") are treated like the script file itself:
top-level definitions are added to the script module that is returned by +load+
or +require+.

Both <tt>WrapInModule::Script#load</tt> and
<tt>WrapInModule::Script#require</tt> fall back to the Kernel versions if the
file is not found locally. Hence, other ruby libraries can be loaded and
required as usual, assuming their names do not conflict with local file names.
Definitions from those files go into the usual scope (typically global). The
normal ruby +load+ and +require+ behavior can be forced by calling
<tt>Kernel.load</tt> and <tt>Kernel.require</tt>.

A `WrapInModule::Script` immitates the way the top-level ruby context works, so
a ruby file that was originally intended to be run from the top level, defining
top-level constants and top-level methods, can also be run as a
`WrapInModule::Script`, and its top-level constants and top-level methods are
wrapped in the script's scope.  The difference between this behavior and simply
wrapping the loaded definitions in an _anonymous_ module using
<tt>Kernel.load(main_file, true)</tt> is that the top-level methods and
top-level constants defined in the script are accessible using the
`WrapInModule::Script` instance.

The top-level definitions of a `WrapInModule::Script` can be accessed after it
has been loaded, as follows:

<tt>script.meth</tt>

- Call a method defined using <tt>def meth</tt> or <tt>def self.meth</tt> in
  the script file.

<tt>script::K</tt>

- Access a class, module, or constant defined using <tt>K = val</tt> in the
  script file.

An "input" can be passed to the script before loading. Simply call
`WrapInModule::Script.new` (or `WrapInModule::Script.load`) with a block. The
block is passed a single argument, the `WrapInModule::Script` module, and
executed before the files are loaded into the Script's scope. Setting a
constant in this block makes the constant available to the script during
loading. For example:

    script = Script.load("my-script.rb") { |script| script::INPUT = 3 }

Note that all methods defined in the script file are both instance methods of
the module and methods of the module instance (the effect of
<tt>Module#module_function</tt>). So <tt>include</tt>-ing a Script module in a
class will give instances of the class all the methods and constants defined in
the script, and they will reference the instance's instance variables,
rather than the Script module's instance variables.

The Script class was inspired by Nobu Nokada's suggestion in
http://ruby-talk.org/62727, in a thread (started in http://ruby-talk.org/62660)
about how to use ruby script files as specifications of objects.

## Legal and Contact Information

Usable under the Ruby license. Copyright (C)2004 Joel VanderWerf. Questions to
mailto:vjoel@users.sourceforge.net.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
