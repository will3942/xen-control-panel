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

if ask_question("Would you like to create a new Rank?")
  name = get_input("Enter the the rank's name")
  abort("Please enter a name") unless name

  create_vms = false
  if ask_question("Can the user create VMs?")
    create_vms = true
  end

  free_upgrades = false
  if ask_question("Does the user have free upgrades?")
    free_upgrades = true
  end

  Rank.create!(
    name: name,
    create_vms: create_vms,
    free_upgrades: free_upgrades
  )
end

rank = get_input("Enter the user's rank")
abort("Please enter a rank") unless rank

rank = Rank.where(name: rank)

print "Saving user #{username}...."
user = rank.user.new(
  username: "#{get_id(username)}",
  virtual_machines: virtual_machines
)
if user.save
  puts "User saved successfully!"
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

    vm = user.vms.new(:ram => ram, :hdd => hdd, :cpu => cpu, :ip => ip, :swap => swap, :os => os, :hostname => hostname, :price => price)

    if vm.save
      puts "VM saved successfully!"
    else
      puts "Failed to save vm, please email the following to mail@definedcode.com"
      p user.errors.full_messages
    end
  end
else
  puts "Failed to save user, please email the following to mail@definedcode.com"
  p user.errors.full_messages
end
