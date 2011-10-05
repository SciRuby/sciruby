require "statsample"
require "statsample/converters"

class Statsample::Excel < Statsample::SpreadsheetBase
  class << self
    # Returns a dataset based on a string formatted as an XLS file would be.
    # USE:
    #     ds = Statsample::Excel.parse(File.read("test.xls"), :name => "test.xls")
    #
    # You should specify a name for the spreadsheet in the :name option if possible.
    def parse(content, opts={})
      read(StringIO.new(content), opts)
    end
  end
end