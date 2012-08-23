# WrapInModule

This is a Ruby gem I created to house the functionality to be able to wrap
various things inside modules. The primary focus of it was to be able to load a
Ruby file in using a module as namespace for all the top level Constants,
Methods, Classes, Modules, etc. This does the same for any sub ruby scripts
that are required as well.

## Installation

Add this line to your application's Gemfile:

    gem 'wrap_in_module'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wrap_in_module

## Usage:

**program.rb:**

    require 'wrap_in_module'
    module MyModule
    WrapInModule::wrap_file(MyModule, "my-script.rb")
    p MyModule::VALUE
    MyModule.run

**my-script.rb:**

    VALUE = [1,2,3]
    def run
      puts "#{self} running."
    end

**output:**

    $ ruby program.rb
    [1, 2, 3]

## Detailed Usage

`WrapInModule::wrap_file(_module, file_path)` wraps the file specified by
*file_path* under the specified *_module*.  All the top-level constants and
top-level methods that are defined in the file at *file_path* and its dependent
local files (see below) are scoped in the same module, and are thereby
available to the calling program.

The file located at *file_path* can load or require other files with *load* and
*require*, as usual. These methods, in the *_module* context, add some behavior
to the *Kernel* *load* and *require* methods: Within the *_module* context they
first search for files relative to the *file_path*'s dir. Files loaded in this
way ("dependent local files") are treated like the file located at *file_path*:
top-level definitions are added to the module.

Both *load* and *require* fall back to the Kernel versions if the file is not
found locally. Hence, other ruby libraries can be loaded and required as usual,
assuming their names do not conflict with local file names.  Definitions from
those files go into the usual scope (typically global). The normal ruby *load*
and *require* behavior can be forced by calling `Kernel.load` and
`Kernel.require`.

A `WrapInModule` wrapped file immitates the way the top-level ruby
context works, so a ruby file that was originally intended to be run from the
top level, defining top-level constants and top-level methods, can also be run
as a module, and its top-level constants and top-level methods are wrapped in
the modules scope. The difference between this behavior and simply wrapping the
loaded definitions in an _anonymous_ module using `Kernel.load(main_file,
true)` is that the top-level methods and top-level constants defined in the
module are accessible using the *_module*.

The top-level definitions of a `WrapInModule` module can be accessed after it
has been loaded, as follows:

`module.meth`

- Call a method defined using `def meth` or `def self.meth` in the specified
  file.

`module::K`

- Access a class, module, or constant defined using `K = val` in the specified
  file.

## History

This is largely based on an older script called **script.rb**  written by Joel
VanderWerf and released under the Ruby license in 2004. I found issues with the
way **script.rb** was doing things, specifically with respect to creating a
module like object rather than an actual module. This caused problems with
libraries such as ActiveModel and validations, etc. Therefore, I rewrote it to
work with normal modules.

Lots of props have to go out to Joel VanderWerf for writing **script.rb** in
the first place. It would have taken me a lot longer to accomplish this if I
didn't have Joel's **script.rb** ruby file to go off of.

Thanks Joel

It also looks that Joel was originally inspired by Nobu Nokada's suggestion in
http://ruby-talk.org/62727, in a thread (started in http://ruby-talk.org/62660)
about how to use ruby script files as specifications of objects.

## Legal Information

This project is licensed under the MIT license which can be seen in the
provided LICENSE file.

Copyright (c) 2012 ReachLocal, Inc.

This project was based on script.rb which is usable under the Ruby license.
Copyright (C)2004 Joel VanderWerf. Questions to
mailto:vjoel@users.sourceforge.net.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
