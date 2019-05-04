require 'mysql2'
require 'active_record'

require 'active_record/connection_adapters/mysql2_adapter'

# DB bootstrapper for running tests
module OptARTestDB
  EMPLOYEE_TABLE = 'employee'.freeze
  SAMPLE_AR_TABLE = 'sample_ar'.freeze

  class << self
    def init
      establish_connection
      db = ActiveRecord::Base.connection

      create_test_tables(db)
    end

    def import_data(db)
      OptAR::Logger.log('Inserting test data')

      file_path = File.dirname(__FILE__) + '/../data/employee_table_dump.sql'
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

    def create_test_tables(db)
      unless db.data_source_exists?(EMPLOYEE_TABLE)
        create_employee_table(db)
        import_data(db)
      end
      create_sample_ar_table(db) unless db.data_source_exists?(SAMPLE_AR_TABLE)
      OptAR::Logger.log('Test DB bootstrapped')
    end

    def create_employee_table(db)
      db.execute(%{ CREATE TABLE `#{EMPLOYEE_TABLE}` (
          emp_id INT NOT NULL, birth_date DATE NOT NULL,
          first_name VARCHAR(16) NOT NULL, last_name VARCHAR(16) NOT NULL,
          gender TINYINT NOT NULL, hire_date DATE NOT NULL,
          password VARCHAR(16) NOT NULL, created_at DATETIME NOT NULL,
          updated_at DATETIME NOT NULL, PRIMARY KEY (emp_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8; })
    end

    def create_sample_ar_table(db)
      db.execute(%{ CREATE TABLE `#{SAMPLE_AR_TABLE}` (
          sample_id INT NOT NULL,
          PRIMARY KEY (sample_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8; })
      OptAR::Logger.log('Created test tables')
    end
  end
end

OptARTestDB.init
