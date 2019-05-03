require 'mysql2'
require 'active_record'

require 'active_record/connection_adapters/mysql2_adapter'

module OptARTestDB
  TEST_TABLE = 'employee'.freeze

  class << self
    def init
      establish_connection
      db = ActiveRecord::Base.connection

      if db.data_source_exists?(TEST_TABLE)
        p 'Test table already exists'
        return
      end
      create_test_table(db)
      import_data(db)
    end

    def import_data(db)
      p 'Inserting test data'

      file_path = File.dirname(__FILE__) + '/../data/test_table_dump.sql'
      sql = File.open(file_path, 'r')
      db.execute(sql.read)
    end

    def establish_connection
      ActiveRecord::Base.establish_connection(
        adapter: 'mysql2',
        database: 'optar_test',
        host: 'localhost',
        username: 'root',
        password: '',
        pool: 5
      )
    end

    def create_test_table(db)
      db.execute(%{ CREATE TABLE `#{TEST_TABLE}` (
          emp_id      INT             NOT NULL,
          birth_date  DATE            NOT NULL,
          first_name  VARCHAR(16)     NOT NULL,
          last_name   VARCHAR(16)     NOT NULL,
          gender      TINYINT         NOT NULL,
          hire_date   DATE            NOT NULL,
          PRIMARY KEY (emp_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
      })
    end
  end
end

OptARTestDB.init
