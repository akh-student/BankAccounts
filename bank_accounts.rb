require 'csv'


module Bank

  class Account

    attr_reader :account_id, :owner, :open_date
    attr_accessor :balance

    @@array_of_accounts = []

    def initialize(account_id, initial_balance, open_date = nil, owner = nil)
      if initial_balance.to_i < 0
        raise ArgumentError
      else
        @account_id = account_id.to_i
        @balance = initial_balance.to_i
        @open_date = open_date
        @owner = owner
        @@array_of_accounts << self
      end
    end

    def withdraw(amount)
      if @balance - amount < 0
        puts "You do not have enough money in your account to withdraw that amount."
        @balance
      else
        @balance -= amount
        @balance
      end
    end

    def deposit(amount)
      @balance += amount
      @balance
    end

    def add_owner(owner) #should be instance of owner class
      @owner = owner
    end

    def puts_account_info
      puts "Account ID: #{@account_id}"
      puts "Balance is: $#{@balance}"
      if @owner == nil
        puts "Account has no owner"
      else
        puts "Owner is:\n#{@owner.puts_owner_address}"
      end
    end

    def self.associate_owner_and_account_by_csv(file, first_import_line = 0, last_import_line = nil)

      if last_import_line == nil
        last_import_line = CSV.read("#{file}").length
      end

      counter = 0

      CSV.open("#{file}", "r").each do |line|
        if counter >= first_import_line && counter <= last_import_line
          account = Bank::Account.find(line[0].to_i)
          owner = Bank::Owner.find(line[1].to_i)
          if account == "Account ID not in system" && owner == "Owner ID not in system"
            puts "Account ID and Owner ID not in system"
          elsif account == "Account ID not in system"
            puts account
          elsif owner == "Owner ID not in system"
            puts owner
          else
            account.add_owner(owner)
          end
        end
        counter += 1
      end

    end


    def self.create_accounts_from_csv(file, first_import_line = 0, last_import_line = nil)

      if last_import_line == nil
        last_import_line = CSV.read("#{file}").length
      end

      counter = 0

      CSV.open("#{file}", "r").each do |line|
        if counter >= first_import_line && counter <= last_import_line
          Account.new(line[0], line[1], line[2], nil)
        end
        counter += 1
      end

    end

    def self.all
      return @@array_of_accounts
    end

    def self.find(id)
      @@array_of_accounts.each do |account|
        if account.account_id == id
          return account
        end
      end
      return "Account ID not in system"
    end

  end



  class Owner

    attr_reader :owner_id, :last_name, :first_name, :street1, :city, :state

    @@array_of_owners = []

    def initialize(owner_hash = {})
      @owner_id = owner_hash[:owner_id].to_i
      @last_name = owner_hash[:last_name]
      @first_name = owner_hash[:first_name]
      @street1 = owner_hash[:street1]
      @city = owner_hash[:city]
      @state = owner_hash[:state]
      @@array_of_owners << self
    end

    def puts_owner_address
      return "#{@last_name}, #{@first_name}\n#{@street1}\n#{@city}, #{@state}"
    end

    def self.create_owners_from_csv(file, first_import_line = 0, last_import_line = nil)

      if last_import_line == nil
        last_import_line = CSV.read("#{file}").length
      end

      counter = 0

      CSV.open("#{file}", "r").each do |line|
        if counter >= first_import_line && counter <= last_import_line
          Owner.new(owner_id: line[0], last_name: line[1], first_name: line[2], street1: line[3], city: line[4], state: line[5])
        end
        counter += 1
      end

    end

    def self.all
      return @@array_of_owners
    end

    def self.find(id)
      @@array_of_owners.each do |owner|
        if owner.owner_id == id
          return owner
        end
      end
      return "Owner ID not in system"
    end


  end
end

Bank::Account.create_accounts_from_csv("support/accounts.csv")
Bank::Owner.create_owners_from_csv("support/owners.csv")
Bank::Account.associate_owner_and_account_by_csv("support/account_owners.csv")
puts Bank::Account.all



# account1 = Bank::Account.new(1235, 100)
# puts account1.puts_account_info
#
#
# owner1 = Bank::Owner.new(first_name: "Alyssa", last_name: "Hursh", street1: "1620 E Fir St", city: "Seattle", state: "WA", zip: 98122, ssn: "XXX-XX-XXXX", dob: "12/25/1985")
#
# account1.add_owner(owner1)
#
# puts account1.puts_account_info
