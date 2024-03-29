direc = File.dirname(__FILE__)

require 'rubygems'
require 'pry'
require "#{direc}/../lib/pry-doc"
require "#{direc}/test_helper"
require "#{direc}/gem_with_cext/gems/sample"
require 'bacon'
require 'set'
require 'fileutils'

puts "Testing pry-doc version #{PryDoc::VERSION}..."
puts "Ruby version: #{RUBY_VERSION}"

describe PryDoc do

  describe "core C methods" do
    it 'should look up core (C) methods' do
      obj = Pry::MethodInfo.info_for(method(:puts))
      obj.source.should.not == nil
    end

    it 'should look up core (C) instance methods' do
      Module.module_eval do
        obj = Pry::MethodInfo.info_for(instance_method(:include))
        obj.source.should.not == nil
      end
    end

    it 'should look up core (C) class method (by Method object)' do
      Module.module_eval do
        obj = Pry::MethodInfo.info_for(Dir.method(:glob))
        obj.source.should.not == nil
      end
    end

    it 'should look up core (C) class method (by UnboundMethod object)' do
      Module.module_eval do
        obj = Pry::MethodInfo.info_for(class << Dir; instance_method(:glob); end)
        obj.source.should.not == nil
      end
    end
  end

  describe "eval methods" do
    it 'should return nil for eval methods' do
      eval("def hello; end")
      obj = Pry::MethodInfo.info_for(method(:hello))
      obj.should == nil
    end
  end

  describe "pure ruby methods" do
    it 'should look up ruby methods' do
      obj = Pry::MethodInfo.info_for(C.new.method(:message))
      obj.should.not == nil
    end

    it 'should look up ruby instance methods' do
      obj = Pry::MethodInfo.info_for(C.instance_method(:message))
      obj.should.not == nil
    end
  end

  describe "Ruby stdlib methods" do
    it "should look up ruby stdlib method" do
      obj = Pry::MethodInfo.info_for(Set.instance_method(:union))
      obj.should.not == nil
    end
  end

  describe "C ext methods" do

    it "should lookup C ext methods" do
      obj = Pry::MethodInfo.info_for(Sample.instance_method(:unlink))
      obj.should.not == nil
    end

    it "should lookup aliased C ext methods" do
      obj = Pry::MethodInfo.info_for(Sample.instance_method(:remove))
      obj.should.not == nil
    end

    it "should lookup C ext instance methods even when its owners don't have any ruby methods" do
      obj = Pry::MethodInfo.info_for(Sample::A::B.instance_method(:unlink))
      obj.should.not == nil
    end

    it "should lookup C ext class methods even when its owners don't have any ruby methods" do
      obj = Pry::MethodInfo.info_for(Sample::A::B.method(:unlink))
      obj.should.not == nil
    end
  end

  describe "C stdlib methods" do
    it "should return nil for C stdlib methods" do
      obj = Pry::MethodInfo.info_for(Readline.method(:readline))
      obj.should == nil
    end
  end

  describe ".aliases" do
    it "should return empty array if method does not have any alias" do
      aliases = Pry::MethodInfo.aliases(Sample.instance_method(:some_meth))
      aliases.should == []
    end

    it "should return aliases of a (C) method" do
      orig = Sample.instance_method(:unlink)
      copy = Sample.instance_method(:remove)

      aliases = Pry::MethodInfo.aliases(orig)
      aliases.should == [copy]

      aliases = Pry::MethodInfo.aliases(copy)
      aliases.should == [orig]
    end

    it "should return aliases of a ruby method" do
      C.class_eval { alias msg message }

      orig = C.instance_method(:message)
      copy = C.instance_method(:msg)

      aliases = Pry::MethodInfo.aliases(orig)
      aliases.should == [copy]

      aliases = Pry::MethodInfo.aliases(copy)
      aliases.should == [orig]
    end

    it "should return aliases of protected method" do
      orig = Sample.instance_method(:unlink_1)
      copy = Sample.instance_method(:remove_1)

      aliases = Pry::MethodInfo.aliases(orig)
      aliases.should == [copy]
    end

    it "should return aliases of private method" do
      orig = Sample.instance_method(:unlink_2)
      copy = Sample.instance_method(:remove_2)

      aliases = Pry::MethodInfo.aliases(orig)
      aliases.should == [copy]
    end
  end

end

