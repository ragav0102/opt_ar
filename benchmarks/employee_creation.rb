10_000.times do |n|
  time = (n % 3_000).days.ago
  time1 = ((n + rand(32)) % 3_000).days.ago
  e = Employee.new(
    emp_id: (13_001 + n),
    first_name: (0...6).map { ('a'..'z').to_a[rand(26)] }.join,
    last_name: (0...6).map { ('a'..'z').to_a[rand(26)] }.join,
    birth_date: time1.to_date,
    hire_date: time.to_date,
    created_at: time,
    updated_at: time + 1000,
    gender: n % 2,
    password: (0...9).map { ('a'..'z').to_a[rand(26)] }.join
  )
  e.save
end
