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
      def data_source_dir module_name
        dir_name = module_name.split('::').tap{ |m| 2.times { m.shift } }.join('::').underscore
        STDERR.puts "dir_name = #{dir_name}; module_name = #{module_name}"
        data_dir do
          FileUtils.mkdir(dir_name) unless Dir.exists?(dir_name)
          Dir.chdir dir_name do
            yield if block_given?
          end
        end
      end

      # Generate a unique and safe filename for a dataset. This may need to be improved to incorporate some kind of hash.
      # Hopefully there will be no collisions.
      def filename_for_dataset id
        id.gsub(/[^a-zA-Z0-9\_]/, '_')
      end

      # Store a given dataset in the .sciruby/data directory.
      def cache_dataset module_name, dataset_id, file_contents
        for_dataset module_name, dataset_id do |dataset_filename|
          unless File.exists? dataset_filename
            File.open(dataset_filename, 'w') do |file|
              file.write file_contents
            end
          end
        end
      end

      # In the data source directory, do something with the dataset cache file. e.g.,
      #     for_dataset('Guardian', '963') do |dataset_filename|
      #       File.open(dataset_filename, 'w') do |f|
      #         f.write "Hello, world!"
      #       end
      #     end
      #
      # It computes the block arg (here, +dataset_filename+) for you using Config::filename_for_dataset. It also puts
      # you in the correct directory.
      #
      # This function is used by Config::cache_dataset.
      def for_dataset module_name, dataset_id, &block
        data_source_dir module_name do
          yield filename_for_dataset(dataset_id)
        end
      end

    end
  end
end