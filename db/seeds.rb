# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Create test users for vulnerability testing
puts "Creating test users..."

User.create([
  { 
    email: 'admin@vulnerable.app', 
    password: 'admin123',
    password_digest: 'admin123', 
    admin: true 
  },
  { 
    email: 'user@vulnerable.app', 
    password: 'user123',
    password_digest: 'user123', 
    admin: false 
  },
  { 
    email: 'test@vulnerable.app', 
    password: 'test123',
    password_digest: 'test123', 
    admin: false 
  }
])

puts "Created #{User.count} users"
puts "Default credentials:"
puts "  Admin: admin@vulnerable.app / admin123"
puts "  User:  user@vulnerable.app / user123"
puts "  Test:  test@vulnerable.app / test123"

# Create some test posts
puts "\nCreating test posts..."

user = User.first
if user
  Post.create([
    { 
      title: 'Welcome to DVRA', 
      content: 'This is a Damn Vulnerable Ruby Application for security testing.'
    },
    { 
      title: '<script>alert("XSS")</script>', 
      content: 'This post has a malicious payload in the title.'
    },
    { 
      title: 'Test Post', 
      content: 'Just a regular test post.'
    }
  ])
  
  puts "Created #{Post.count} posts"
end

puts "\nSeeding complete!"
