require "wrap_in_module/version"

module WrapInModule
  # NOTE: The following is rewrite of script.rb v0.3. I had some issues with
  # script.rb v0.3 so I rewrote large portions of it to work with existing
  # modules rather than define pho modules.
  # For more information please refer to http://redshift.sourceforge.net where
  # I acquired the script-0.3.tar

  # A module which is an instance of the Script class encapsulates in its scope
  # the top-level methods, top-level constants, and instance variables defined in
  # a ruby script file (and its subfiles) loaded by a ruby program. This allows
  # use of script files to define objects that can be loaded into a program in
  # much the same way that objects can be loaded from YAML or Marshal files.
  #
  # See intro.txt[link:files/intro_txt.html] for an overview.
  #
  class MissingFile < LoadError; end

  def self.wrap_file(_module, _file_path)
    _module.extend ::WrapInModule::LoadInModuleMethods
    _module.module_eval do
      # The file with which the Script was instantiated.
      attr_reader :__main_file

      # The directory in which main_file is located, and relative to which
      # #load searches for files before falling back to Kernel#load.
      attr_reader :__dir
      
      # A hash that maps <tt>filename=>true</tt> for each file that has been
      # required locally by the script. This has the same semantics as <tt>$"</tt>,
      # alias <tt>$LOADED_FEATURES</tt>, except that it is local to this script.
      attr_reader :__loaded_features

      @__main_file = File.expand_path(_file_path)
      @__dir = File.dirname(@__main_file)
      @__loaded_features = {}
      load_in_module(@__main_file)
    end
  end

  module LoadInModuleMethods
    # Loads _file_ in this module's context. Note that <tt>\_\_FILE\_\_</tt> and
    # <tt>\_\_LINE\_\_</tt> work correctly in _file_.
    # Called by #load and #require; not normally called directly.
    def load_in_module(__file__)
      module_eval("@__script_scope ||= binding\n" + IO.read(__file__),
        File.expand_path(__file__), 0)
        # start numbering at 0 because of the extra line.
        # The extra line does nothing in sub-script files.
    rescue Errno::ENOENT
      if /#{__file__}$/ =~ $!.message # No extra locals in this scope.
        # raise MissingFile, $!.message
        raise ::WrapInModule::MissingFile, $!.message
      else
        raise
      end
    end

    # This is so that <tt>def meth...</tt> behaves like in Ruby's top-level
    # context. The implementation simply calls
    # <tt>Module#module_function(name)</tt>.
    def method_added(name) # :nodoc:
      module_function(name)
    end
    
    attr_reader :__script_scope

    # Gets list of local vars in the script. Does not see local vars in files
    # loaded or required by that script.
    def __local_variables
      eval("local_variables", __script_scope)
    end
    
    # Gets value of local var in the script. Does not see local vars in files
    # loaded or required by that script.
    def __local_variable_get(name)
      eval(name.to_s, __script_scope)
    end


    # Loads _file_ into this Script. Searches relative to the local dir, that is,
    # the dir of the file given in the original call to
    # <tt>Script.load(file)</tt>, loads the file, if found, into this Script's
    # scope, and returns true. If the file is not found, falls back to
    # <tt>Kernel.load</tt>, which searches on <tt>$LOAD_PATH</tt>, loads the file,
    # if found, into global scope, and returns true. Otherwise, raises
    # <tt>LoadError</tt>.
    #
    # The _wrap_ argument is passed to <tt>Kernel.load</tt> in the fallback case,
    # when the file is not found locally.
    #
    # Typically called from within the main file to load additional sub files, or
    # from those sub files.
    
    def load(file, wrap = false)
      begin
        load_in_module(File.join(@__dir, file))
        true
      rescue ::WrapInModule::MissingFile
        super
      end
    end

    # Analogous to <tt>Kernel#require</tt>. First tries the local dir, then falls
    # back to <tt>Kernel#require</tt>. Will load a given _feature_ only once.
    #
    # Note that extensions (*.so, *.dll) can be required in the global scope, as
    # usual, but not in the local scope. (This is not much of a limitation in
    # practice--you wouldn't want to load an extension more than once.) This
    # implementation falls back to <tt>Kernel#require</tt> when the argument is an
    # extension or is not found locally.
    
    def require(feature)
      begin
        unless @__loaded_features[feature]
          @__loaded_features[feature] = true
          file = File.join(@__dir, feature)
          file += ".rb" unless /\.rb$/ =~ file
          load_in_module(file)
        end
      rescue ::WrapInModule::MissingFile
        @__loaded_features[feature] = false
        super
      end
    end
  end
end
