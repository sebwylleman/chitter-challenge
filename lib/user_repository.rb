require_relative 'database_connection'
require_relative 'user'
require 'bcrypt'

class UserRepository
  def all
    sql = 'SELECT * FROM users;'
    result_set = DatabaseConnection.exec_params(sql, [])

    users = []
    result_set.each do |row|
      user = User.new
      user.id = row['id']
      user.username = row['username']
      user.email = row['email']
      user.password = row['password']
      users << user
    end
    
    return users
  end

  def create(user)
    encrypted_password = BCrypt::Password.create(user.password)
  
    sql = '
      INSERT INTO users (username, email, password)
        VALUES($1, $2, $3)
        RETURNING id;
    '
    sql_params = [
      user.username,
      user.email,
      encrypted_password
    ]
    result_set = DatabaseConnection.exec_params(sql, sql_params)
    
    user.id = result_set[0]['id'].to_i
  
    return user
  end
  

  def find_by_email(email)
    sql = 'SELECT username FROM users WHERE email = $1;'
    params = [email]
    result = DatabaseConnection.exec_params(sql, params)
    
    if result.ntuples > 0
      record = result[0]
      user = User.new
      user.username = record['username']
      user.email = record['email']
      user.password = record['password']
      return user
    else
      fail 'No such user with given email.'
    end
  end
end
