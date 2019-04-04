# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

#Create an Admin
admin = User.where(email: 'admin@test.com').first_or_create do |user|
  user.password = 'welcome1'
  user.password_confirmation = 'welcome1'
  user.first_name = "Delete"
  user.last_name = "Me"
  puts 'Creating Default Admin User (Change these settings)'
  puts 'email: ' + user.email
  puts 'password: '+ 'welcome1'
end

# Create OTP Types
Type.all.destroy_all
#Type.connection.execute('ALTER SEQUENCE type_id_seq RESTART WITH 1')
Type.create(:name => 'Plan', :description => 'Plan')
Type.create(:name => 'Nearby', :description => 'Nearby')
Type.create(:name => 'Collector', :description => 'Collector')
