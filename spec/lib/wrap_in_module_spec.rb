require 'spec_helper'

describe "WrapInModule" do
  it "loads a file with a single top level class" do
    module FooMod; end
    WrapInModule::Script.new(FooMod, File.dirname(__FILE__) + '/../example_data/single_top_level_class.rb')
    FooMod::Hoopty.new
  end

  it "loads a file without overwriting existing module definition" do
    module FooMod; BOB="hello there I am bob"; end
    WrapInModule::Script.new(FooMod, File.dirname(__FILE__) + '/../example_data/single_top_level_class.rb')
    FooMod::BOB
  end

  it "loads a file with a top level class that requires another file with a top level class" do
    module FooMod; end
    WrapInModule::Script.new(FooMod, File.dirname(__FILE__) + '/../example_data/top_level_class_requires_another_file.rb')
    FooMod::Doopty.new
    FooMod::Hoopty.new
  end

  it "verify that classes required inside of the top level loaded file are accesible in the non namespaces scope" do
    module FooMod; end
    WrapInModule::Script.new(FooMod, File.dirname(__FILE__) + '/../example_data/top_level_class_requires_another_file.rb')
    a = FooMod::Doopty.new
    a.test_hoopty
  end
end
