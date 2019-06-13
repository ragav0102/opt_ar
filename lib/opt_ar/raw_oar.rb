module OptAR
  # Raw content returning just the queried data in its naked form
  # Iterate through rows to get each record. `columns` has the info
  #   of the attributes and the order
  #
  # columns   : arrays of the requested attributes in order
  # rows      : array of arrays, each representing a row
  class RawOAR
    attr_reader :columns, :rows

    def initialize(columns, rows)
      @columns = columns
      @rows = rows
    end

    def results
      HashWithIndifferentAccess.new(
        columns: columns,
        rows: rows
      )
    end
  end
end
