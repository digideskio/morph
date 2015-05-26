require 'spec_helper'

describe Morph::DockerUtils do
  describe ".create_tar" do
    it "should preserve the symbolic link" do
      tar = Dir.mktmpdir do |dest|
        FileUtils.ln_s "scraper.rb", File.join(dest, "link.rb")
        Morph::DockerUtils.create_tar(dest)
      end

      Dir.mktmpdir do |dir|
        Morph::DockerUtils.in_directory(dir) do
          File.open("test.tar", "w") {|f| f << tar}
          # Quick and dirty
          `tar xf test.tar`
          File.symlink?("link.rb").should be_truthy
          File.readlink("link.rb").should == "scraper.rb"
        end
      end
    end
  end

  describe ".fix_modification_times" do
    it do
      Dir.mktmpdir do |dir|
        FileUtils.touch(File.join(dir, "foo"))
        FileUtils.mkdir_p(File.join(dir, "bar"))
        FileUtils.touch(File.join(dir, "bar", "twist"))
        Morph::DockerUtils.fix_modification_times(dir)
        File.mtime(dir).should == Time.new(2000,1,1)
        File.mtime(File.join(dir, "foo")).should == Time.new(2000,1,1)
        File.mtime(File.join(dir, "bar")).should == Time.new(2000,1,1)
        File.mtime(File.join(dir, "bar", "twist")).should == Time.new(2000,1,1)
      end
    end
  end

  describe ".copy_directory_contents" do
    it "should copy a file in the root of a directory" do
      Dir.mktmpdir do |source|
        Dir.mktmpdir do |dest|
          File.open(File.join(source, "foo.txt"), "w") {|f| f << "Hello"}
          Morph::DockerUtils.copy_directory_contents(source, dest)
          expect(File.read(File.join(dest, "foo.txt"))).to eq "Hello"
        end
      end
    end

    it "should copy a directory and its contents" do
      Dir.mktmpdir do |source|
        Dir.mktmpdir do |dest|
          FileUtils.mkdir(File.join(source, "foo"))
          File.open(File.join(source, "foo", "foo.txt"), "w") {|f| f << "Hello"}
          Morph::DockerUtils.copy_directory_contents(source, dest)
          expect(File.read(File.join(dest, "foo", "foo.txt"))).to eq "Hello"
        end
      end
    end

    it "should copy a file starting with ." do
      Dir.mktmpdir do |source|
        Dir.mktmpdir do |dest|
          File.open(File.join(source, ".foo.txt"), "w") {|f| f << "Hello"}
          Morph::DockerUtils.copy_directory_contents(source, dest)
          expect(File.read(File.join(dest, ".foo.txt"))).to eq "Hello"
        end
      end
    end
  end
end