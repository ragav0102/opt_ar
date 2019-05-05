# OptAR

Generates memory-optimal immutable ActiveRecord dupes that are easily serializable and behaves much like ARs. Request attributes that will be read before-hand, and use them later just as you would on an AR, for better memory optimization.

Ideally, suitable in place of caching AR objects with cache stores like Memcached, where serialization and de-serialization are memory-hungry

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'opt_ar'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install opt_ar

## Usage

Declare OptAR scopes for an ActiveRecord model like below

```ruby
class Employee < ActiveRecord::Base
  self.table_name =  'employee'.freeze
  self.primary_key = 'emp_id'.freeze


  scope :male_employees, lambda {
    where(gender: 1)
  }

  show_as :male_names,
          scope: :male_employees,
          req_attributes: %i[emp_id first_name last_name]

  show_as :emp_birth_dates
          req_attributes: %i[birth_date]

  show_as :all_emp_ids
end
```

  * **scope**          - You can use a predefined scope/association.

If not given, gets the default scope for the model


  * **req_attributes** - Request attributes that will be read later. Reading unrequested attributes is an **anti-pattern**.

If not given, stores only the primary key
   
```ruby
 > emp = Employee.male_names
 # [#<OptAR::OAR:0x007fe5d1dc1dd8 @attributes={:emp_id=>10082, :first_name=>"Parviz", :last_name=>"Lortz"}, @klass_name="Employee">, #<OptAR::OAR:0x007fe5d1dc1810 @attributes={:emp_id=>10096, :first_name=>"Jayson", :last_name=>"Mandell"}, @klass_name="Employee">,..]

 > emp.first.first_name
 # => "Parviz"
 
 > emp.first.birth_date
 # WARNING :: Trying to access attr that was not requested :: birth_date
 # Employee Load (1.1ms)  SELECT  `employee`.* FROM `employee` WHERE emp_id=10082 LIMIT 1
 # => Mon, 09 Sep 1963
```

---


#### All OAR objects are immutable. Trying to write or change it will raise exceptions



Again,
###  OARs are read-optimized AR dupes



##### Utilize it better for querying/caching, by defining attributes, only that are required


---


Use them on _AR relations/ Array of ARs_ as well

```ruby
 > rel = Employee.all
 
 > rel.opt_ar_objects
 # => [#<OptAR::OAR:0x007fe5d11f2b88 @attributes={:emp_id=>10082}, @klass_name="Employee">, #<OptAR::OAR:0x007fe5d11f25c0 @attributes={:emp_id=>10096}, @klass_name="Employee">,..]
 
 > arr = rel.to_a
 # => [#<OptAR::OAR:0x007fe5d11885f8 @attributes={:emp_id=>10082}, @klass_name="Employee">, #<OptAR::OAR:0x007fe5d11939a8  @attributes={:emp_id=>10096}, @klass_name="Employee">,..]

 > arr.opt_ar_objects(req_attributes: [:first_name])
 # => [#<OptAR::OAR:0x007fe5d0953400 @attributes={:first_name=>"Parviz", :emp_id=>10082}, @klass_name="Employee">, #<OptAR::OAR:0x007fe5d09530b8 @attributes={:first_name=>"Jayson", :emp_id=>10096}, @klass_name="Employee">,..]
 
```

---


On an ActiveRecord,

```ruby

> emp = Employee.first

> emp.opt_ar_object(req_attributes: [:last_name, :birth_date])
# => #<OptAR::OAR:0x007fe5d096d558 @attributes={:last_name=>"Lortz", :birth_date=>Mon, 09 Sep 1963, :emp_id=>10082}, @klass_name="Employee">

```
---


_created_at_ and _updated_at_ fields are by default considered to be Time objects. Override them using the _const_,

```ruby
    DATE_TIME_ATTRIBUTES = %i[last_login_time]
```
in your model.


 * Why do I need to do this?

  Beleive me, this will spare some memory for you.
  
---


Restrict storing sensitive/PII info outside, by blacklisting them. Simply add this _const_ to your model

```ruby
    BLACKLISTED_ATTRIBUTES = %i[password persist_token]
```

---

Will add benchmarking results soon.




## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ragav0102/opt_ar. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the OptAR project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ragav0102/opt_ar/blob/master/CODE_OF_CONDUCT.md).



Available at https://rubygems.org/gems/opt_ar
