# Copyright (c) 2010 - 2011, Ruby Science Foundation
# All rights reserved.
#
# Please see LICENSE.txt for additional copyright notices.
#
# By contributing source code to SciRuby, you agree to be bound by our Contributor
# Agreement:
#
# * https://github.com/SciRuby/sciruby/wiki/Contributor-Agreement
#
# === config.rb
#

module SciRuby
  module Config
    class << self

      # Create a .sciruby directory if it doesn't exist (.sciruby) and chdir to it.
      def dir
        Dir.chdir(Dir.home) do
          FileUtils.mkdir('.sciruby') unless Dir.exists?('.sciruby')
          Dir.chdir '.sciruby' do
            yield if block_given?
          end
        end
      end

      # Create a data dir in the .sciruby directory if it doesn't exist (data/) and chdir to it.
      def data_dir
        dir do
          FileUtils.mkdir('data') unless Dir.exists?('data')
          Dir.chdir 'data' do
            yield
          end
        end
      end

      # Create a data source directory within the .sciruby dir for a given module, e.g., ./sciruby/data/guardian for Guardian.
      def data_source_dir module_name, create=true
        dir_name = module_name.to_s if module_name.is_a?(Symbol)
        dir_name ||= module_name.split('::').tap{ |m| 2.times { m.shift } }.join('::').underscore
        data_dir do
          FileUtils.mkdir(dir_name) if !Dir.exists?(dir_name) && create
          Dir.chdir dir_name do
            yield if block_given?
          end
        end
      end


      # Add an extension to the basename for a dataset based on the format.
      def filename_for_dataset id, format=nil
        basename = basename_for_dataset(id)
        format.nil? ? basename : [basename, format.to_s].join('.')
      end

      # Generate a unique and safe filename for a dataset. This may need to be improved to incorporate some kind of hash.
      # Hopefully there will be no collisions.
      def basename_for_dataset id
        return id.gsub(/[^a-zA-Z0-9\_]/, '_')
      end

      # Determines whether the basename for a cached dataset exists in some format or another.
      def basename_exists? id
        matches = Dir.glob("#{basename_for_dataset(id)}.*")
        return matches.first if matches.size >= 1
        return nil
      end

      # Store a given dataset in the .sciruby/data directory.
      def cache_dataset module_name, dataset_id, file_contents, format
        for_dataset_filename(module_name, dataset_id, format) do |dataset_filename|
          unless File.exists?(dataset_filename) || basename_exists?(dataset_id)
            File.open(dataset_filename, 'w') do |file|
              file.write file_contents
            end
          end
        end
      end

      # In the data source directory, do something with the dataset cache file. e.g.,
      #     for_dataset('Guardian', '963', :cvs) do |dataset_filename|
      #       File.open(dataset_filename, 'w') do |f|
      #         f.write "Hello, world!"
      #       end
      #     end
      #
      # It computes the block arg (here, +dataset_filename+) for you using Config::filename_for_dataset. It also puts
      # you in the correct directory.
      #
      # This function is used by Config::cache_dataset.
      def for_dataset_filename module_name, dataset_id, format, &block
        data_source_dir module_name do
          yield filename_for_dataset(dataset_id, format)
        end
      end

      def for_dataset_basename module_name, dataset_id, &block
        data_source_dir module_name do
          yield basename_for_dataset(dataset_id)
        end
      end

    end
  end
end