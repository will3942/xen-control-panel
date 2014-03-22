require 'bundler/setup'
require 'mongoid'
require 'twitter'
require './db'

def ask_question(q)
  print q + " "
  input = STDIN.gets.chomp
  if input == 'y' or input == 'yes' or input == 'YES' or input == 'Yes' or input == 'Y'
    return true
  else
    return false
  end
end

def get_input(str)
  print str + ": "
  input = STDIN.gets.chomp
  unless input == "" or input == " "
    return input
  else
    return false
  end
end

def get_id(username)
  client = Twitter::REST::Client.new do |config|
    config.consumer_key        = "OzEsEffe0sM5ZNeQYvSVQ"
    config.consumer_secret     = "yxy6pNGTMnI6NJNezwSM1dD92OPGBrRltZOobFFYc"
  end

  user = client.user(username).id
  return user
end

puts "Adding a new user to Defined Code Ltd VMs Management."

username = get_input("Enter the user's twitter username")
abort("Please enter a twitter username") unless username

id = "#{get_id(username)}"
user = User.where(:username => id).first

virtual_machines = user.virtual_machines
if ask_question("Would you like to add a VM?")
  ram = get_input("Enter the amount of RAM in MB")
  abort("Please enter an amount") unless ram

  hostname = get_input("Enter the hostname")
  abort("Please enter a hostname") unless hostname
  hostname = hostname.gsub('.', '-')

  cpu = get_input("Enter the number of CPUs")
  abort("Please enter a number") unless cpu

  ip = get_input("Enter the IP address")
  abort("Please enter an IP") unless ip

  hdd = get_input("Enter the HDD size in GB")
  abort("Please enter an amount") unless hdd

  swap = get_input("Enter the swap size in GB")
  abort("Please enter an amount") unless swap

  os = get_input("Enter the operating system (Ubuntu, Debian, CentOS, CoreOS)")
  abort("Please enter an operating system") unless os

  price = get_input("Enter the price in GBP/month")
  abort("Please enter the price") unless price

  virtual_machines[hostname] = {:ram => ram, :hdd => hdd, :cpu => cpu, :ip => ip, :swap => swap, :os => os, :hostname => hostname, :price => price}
end

user.update_attributes(virtual_machines: virtual_machines)
