require 'csv'


module Bank
  class Bank

    attr_reader :array_of_accounts

    def initialize
      @array_of_accounts = []
      puts "I did this!"
    end

    def add_accounts_from_csv(file, first_import_line = 0, last_import_line = nil)

      if last_import_line == nil
        last_import_line = CSV.read("#{file}").length
      end

      counter = 0

      CSV.open("#{file}", "r").each do |line|
        if counter >= first_import_line && counter <= last_import_line
          @array_of_accounts << Account.new(line[0], line[1], line[2], nil)
        end
        counter += 1
      end
    end

    def all
      @array_of_accounts.each do |account|
        puts account
      end
    end
  end

  class Account

    attr_reader :account_id, :owner, :open_date
    attr_accessor :balance

    def initialize(account_id, initial_balance, open_date = nil, owner = nil)
      if initial_balance.to_i < 0
        raise ArgumentError
      else
        @account_id = account_id
        @balance = initial_balance
        @open_date = open_date
        @owner = owner
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
  end



  class Owner

    attr_reader :first_name, :last_name, :street1, :street2, :city, :state, :zip, :ssn, :dob

    def initialize(owner_hash = {})
      @first_name = owner_hash[:first_name]
      @last_name = owner_hash[:last_name]
      @street1 = owner_hash[:street1]
      @street2 = owner_hash[:street2]
      @city = owner_hash[:city]
      @state = owner_hash[:state]
      @zip = owner_hash[:zip]
      @ssn = owner_hash[:ssn]
      @dob = owner_hash[:dob]
    end

    def puts_owner_address
      return "#{@last_name}, #{@first_name}\n#{@street1}\n#{@street2}\n#{@city}, #{@state} #{@zip}"
    end
  end
end

new_tester = Bank::Bank.new

new_tester.add_accounts_from_csv("support/accounts.csv")

new_tester.all



# account1 = Bank::Account.new(1235, 100)
# puts account1.puts_account_info
#
#
# owner1 = Bank::Owner.new(first_name: "Alyssa", last_name: "Hursh", street1: "1620 E Fir St", city: "Seattle", state: "WA", zip: 98122, ssn: "XXX-XX-XXXX", dob: "12/25/1985")
#
# account1.add_owner(owner1)
#
# puts account1.puts_account_info
