require 'csv'

# Create new module Bank, which contains a standard Account class, several Account child classes, and an Owner class.
module Bank

  # Create standard Account class
  class Account

    attr_reader :account_id, :owner, :open_date, :min_balance
    attr_accessor :balance

    # Open class variable as blank Array to store instances of Account class.
    @@array_of_accounts = []

    # Initialize new bank account with account id, initila balance, open date, owner, withdrawal fee, and minimum balance
    def initialize(account_id, initial_balance, open_date = nil, owner = nil, withdrawal_fee = 0, min_balance = 0)

      # Store minimum balance as instance variables
      @min_balance = min_balance

      #if the initial balance is less than the minimum allowed balance raise the argument error that an opening balance cannot be negative.
      if initial_balance.to_i < @min_balance
        raise ArgumentError, "Opening balance can't be below account minimum"

      # Otherwise, store account information as instance variables, and shovel new Account instance into the array of Account instances.
      else
        @account_id = account_id.to_i
        @balance = initial_balance.to_i
        @open_date = open_date
        @owner = owner
        @withdrawal_fee = withdrawal_fee
        @@array_of_accounts << self
      end
    end


    # Define withdraw method
    def withdraw(amount)

      #If the current balance minus the withdrawal amount and the withdrawal fee will bring the account below the minimum allowed balance, display a message and return the original, unmodified balance.
      if @balance - (amount + @withdrawal_fee) < @min_balance
        puts "You do not have enough money in your account to withdraw that amount."
        @balance

      # Otherwise (if the withdrawal is allowable), deduct the amount from the balance and return the new balance.
      else
        @balance -= (amount + @withdrawal_fee)
        @balance
      end
    end


    # Define deposit method, which takes amount and adds it to the balance. Return the new balance.
    def deposit(amount)
      @balance += amount
      @balance
    end


    # Define add owner method, which takes an instance of the owner class and assigns it to the instance variable owner.
    def add_owner(owner) # should be instance of owner class
      if owner.class == Bank::Owner
        @owner = owner
      else
        puts "Owner should be an instance of the Bank::Owner class."
      end
    end


    # Define account status method, which simply puts information about the account (intended for testing purposes)
    def account_status
      puts "Account ID: #{@account_id}"
      puts "Balance is: $#{@balance}"
      if @owner == nil
        puts "Owner is: Unlisted"
      else
        puts "Owner is:\n#{@owner.puts_owner_address}"
      end
    end


    # Define method to associate accounts and account owners using a CSV import.
    def self.associate_owner_and_account_by_csv(file, first_import_line = 0, last_import_line = nil)

      # If the user does not specify and ending line to read from the CSV, determine the length of the CSV and set the length as the last line to read.
      if last_import_line == nil

        # Note that this method (.read) seems like an expensive way to get this information, as Ruby will import and store all of the data just to determine the length. Evaluate other methods if time allows.
        last_import_line = CSV.read(file).length
      end

      # Set counter to zero!
      counter = 0

      # Open specified CSV and iterate through each line of data (pulled in as arrays)
      CSV.open(file, "r").each do |line|

        # If the counter is within the lines specified by the user
        if counter >= first_import_line && counter <= last_import_line

          # Set account variable appropriate account instance using the account ID (first column of account_owners.csv)
          account = Bank::Account.find(line[0].to_i)

          # Set owner variable appropriate owner instance using the owner ID (second column of account_owners.csv)
          owner = Bank::Owner.find(line[1].to_i)

          # If the account number or owner id return
          # WHAT IS GOING ON HERE??????????????????? REVIEW .find methods
          if account == "Account ID not in system" && owner == "Owner ID not in system"
            puts "Account ID and Owner ID not in system"
          elsif account == "Account ID not in system"
            puts line[0].to_i
            puts account
          elsif owner == "Owner ID not in system"
            puts owner
          else
            account.add_owner(owner)
          end
        end

        # Increment counter
        counter += 1
      end

    end

    # Define method to create accounts from a CSV import
    def self.create_accounts_from_csv(file, first_import_line = 0, last_import_line = nil)

      # REVIEW: THESE LINES ARE REPEATED FROM ABOVE METHOD. HANDLE IN A NON-REPETITIVE WAY?
      # If the user does not specify and ending line to read from the CSV, determine the length of the CSV and set the length as the last line to read.
      if last_import_line == nil

        # Note that this method (.read) seems like an expensive way to get this information, as Ruby will import and store all of the data just to determine the length. Evaluate other methods if time allows.
        last_import_line = CSV.read(file).length
      end

      # Set counter to zero!
      counter = 0

      # Open a specified CSV and iterate through each line
      CSV.open(file, "r").each do |line|

        # If the counter is within the user specified values
        if counter >= first_import_line && counter <= last_import_line

          # Create a new account using account_id, opening balance, and opening date
          Account.new(line[0], line[1], line[2])

        end

        # Increment counter
        counter += 1
      end

    end

    # Define all method to return the array of Account instances
    def self.all
      @@array_of_accounts
    end

    # Define all ids method to puts each account id (used for testing purposes)
    def self.all_ids
      all.each do |item|
        puts item.account_id
      end
    end

    # Define class method find to locate an account instance with the specified account id.
    def self.find(id)

      # Iterate through the accounts contained in the class variable array of accounts.
      @@array_of_accounts.each do |account|

        # If the account matches the id provided by the method call, return the account
        if account.account_id == id.to_i

          # return the account instance
          return account
        end
      end

      # If the end of the account list is reached and an account is not located, return message that account id is not in the system.
      "Account ID not in system"

    end

    # Define method to save all data to new CSV file
    def self.save_all_data_to_csv

      # Open CSV and write to it. If this file already exists, this will write over any data for as many lines of data as are being written
      CSV.open("support/accounts_with_owners.csv", "w") do |file|

        # Iterate through each account in the array of account instances
        @@array_of_accounts.each do |account|

          # Grab the owner instance
          owner = account.owner

          # Output the following information line by line.
          output = [account.account_id, account.balance, account.open_date, owner.owner_id, owner.last_name, owner.first_name, owner.street1, owner.state, owner.city]

          # Shovel the output into into the file.
          file << output
        end
      end
    end

  end


  # A helpful interest rate method to be used by multiple classes.
  module InterestRate
    def add_interest(rate = 0.25)
      interest = @balance * rate / 100
      @balance += interest
      interest
    end
  end

  # Define a new account type (child of accont class) called Savings account
  class SavingsAccount < Account

    # Initialize the savings account using the parent initialize, replacing the default withdrawal fee to $2.00 and the minimum balance to $10.00
    def initialize(account_id, initial_balance, open_date = nil, owner = nil, withdrawal_fee = 200, min_balance = 1000)
      super
    end

    # Bring in the method add_interest from the InterestRate module.
    include InterestRate

  end

  # Define a new account type (child of accont class) called Checking account
  class CheckingAccount < Account

    attr_reader :checks_used

    # Initialize the savings account using the parent initialize, replacing the default withdrawal fee to $1.00. Add the instance variable checks_used and set it to 0
    def initialize(account_id, initial_balance, open_date = nil, owner = nil, withdrawal_fee = 100, min_balance = 0)
      super
      @checks_used = 0
      @max_neg_check_balance = -1000
    end

    # Define a method to withdraw using a check
    def withdraw_using_check(amount)

      # Store the minimum balance in a new variable to call back later
      non_check_min_balance = @min_balance

      # Reset the minimum balance to -$10.00 for the purpose of processing checks.
      @min_balance = @max_neg_check_balance

      # If the customer has not used three checks yet
      if @checks_used < 3

        # Withdraw the money and refund the withdrawal fee.
        withdraw(amount)
        @balance += @withdrawal_fee

      else
        # Otherwise, withdraw the money and charge a withdrawal fee.
        withdraw(amount)

      end

      # Increment checks used. REVIEW: Checks used increments if check bounces. Not fair to customer.
      @checks_used += 1

      # Reset minimum balance to standard minimum balance.
      @min_balance = non_check_min_balance
    end

    # Define method to reset checks
    def reset_checks
      @checks_used = 0
    end

    # Modify the inherited account status method, which simply puts information about the account (intended for testing purposes). Add the checks used data.
    def account_status
      super
      puts "Checks Used: #{@checks_used}"
      puts "**************"
    end
  end

  # Define a new account type (child of accont class) called Money Market account
  class MoneyMarketAccount < Account

    attr_reader :transactions_month_to_date

    # Initialize the savings account using the parent initialize, replacing the default withdrawal fee to $100.00 and the minimum account balance to $10,000. Add the instance variables transactions month to date, max monthly transactions and reset the minmum balance 0 (after using minimum balance to check against initial balance, since account does not actually have a minimum balance of $10,000).
    def initialize(account_id, initial_balance, open_date = nil, owner = nil, withdrawal_fee = 10000, min_balance = 1000000)
      super
      @transactions_month_to_date = 0
      @max_monthly_transactions = 6
      @feeless_balance = 1000000
      @min_balance = 0

    end

    # Define a method to check if transactions are currently allowed, which returns true of the transactions month to date is fewer than the maximum monthly transactions.
    def transactions_allowed?
      if @transactions_month_to_date < @max_monthly_transactions
        true
      else
        false
      end
    end

    # Modify the inherited withdrawal method.
    def withdraw(amount)

      # Verify if transactions are currently allowed, only proceed if true
      if transactions_allowed? == true

        #Increment the transactions this month to date
        @transactions_month_to_date += 1

        # If the result of this transaction will be less than the feeless balance, perform the parent withdrawal method but increment the transactions month to date enough to change the transactiosn allowed status to false.
        if @balance - amount < @feeless_balance
          @transactions_month_to_date += @max_monthly_transactions
          super
        else
          #Otherwise, perform the parent withdrawal method and refund the withdrawal fee
          super
          @balance += @withdrawal_fee
        end
      else
        # If the account is frozen, return the account frozen message.
        account_frozen
      end
    end

    # Modify the inherited deposit method.
    def deposit(amount)

      # If the current balance is less than the feeless balance
      if @balance < @feeless_balance

        #Perform the parent deposit method (no transaction penalty to bring account up to feeless balance)
        return super

      else

        if transactions_allowed? == true

          # Increment the transactions month to date and then peform the parent deposit method
          @transactions_month_to_date += 1
          return super

        else
          # If the account is frozen, return the account frozen message.
          account_frozen
        end

      end
    end

    # Bring in the method add_interest from the InterestRate module.
    include InterestRate


    # Define a method to return frozen account message.
    def account_frozen
      "Your account is frozen. Transaction cannot be processed."
    end

    # Reset the transactions month to date to zero
    def reset_transactions_count
      @transactions_month_to_date = 0
    end

    # Modify the inherited account status method, which simply puts information about the account (intended for testing purposes). Add the transactions used data.
    def account_status
      super
      puts "Transactions Used: #{@transactions_month_to_date}"
      puts "**************"
    end

  end


  # Define Owner class to hold information about owner
  class Owner

    attr_reader :owner_id, :last_name, :first_name, :street1, :city, :state

    # Open class variable as blank Array to store instances of Account class.
    @@array_of_owners = []

    # Define the initalize method to take in an owner hash and save the owner information to the appropriate instance variables. Shovel the new instance into the class variable array of owners.
    def initialize(owner_hash)
      @owner_id = owner_hash[:owner_id].to_i
      @last_name = owner_hash[:last_name]
      @first_name = owner_hash[:first_name]
      @street1 = owner_hash[:street1]
      @city = owner_hash[:city]
      @state = owner_hash[:state]
      @@array_of_owners << self
    end

    # Define method to return owner name and address. Mostly for testing purposes.
    def puts_owner_address
      "#{@last_name}, #{@first_name}\n#{@street1}\n#{@city}, #{@state}"
    end

    # Define a method to create owners from a CSV import
    def self.create_owners_from_csv(file, first_import_line = 0, last_import_line = nil)

      # HEY GIRL THIS IS THE THIRD TIME I'VE SEEN THIS CODE!
      if last_import_line == nil
        last_import_line = CSV.read(file).length
      end

      # Set counter to zero!
      counter = 0

      # Open a CSV file and iterate through each line
      CSV.open(file, "r").each do |line|

        # If the line is within the parameters set by the user
        if counter >= first_import_line && counter <= last_import_line

          # Create a new owner instance.
          Owner.new(owner_id: line[0], last_name: line[1], first_name: line[2], street1: line[3], city: line[4], state: line[5])
        end

        # Increment the counter
        counter += 1
      end

    end

    # Define class method to return the array of owners.
    def self.all
      @@array_of_owners
    end

    # Define class method to find an owner by the owner id.
    def self.find(id)

      # For each instance of owner in the array of owners
      @@array_of_owners.each do |owner|

        # If the owner id matches, return the owner instance
        if owner.owner_id == id.to_i
          return owner
        end
      end

      # Otherwise, return a message that the owner is not in the system.
      "Owner ID not in system"
    end

  end
end


# TEST ACCOUNT AND OWNER CREATION AND ASSOCIATION
Bank::Account.create_accounts_from_csv("support/accounts.csv")
Bank::Owner.create_owners_from_csv("support/owners.csv")
Bank::Account.associate_owner_and_account_by_csv("support/account_owners.csv")
Bank::Account.save_all_data_to_csv

# TEST ACCOUNT.FIND (TURN ON ACCOUNT AND OWNER CREATION ASN ASSOCIATION TESTS FIRST)
puts "Should return account instance:"
puts Bank::Account.find(1215)
puts "Should return Account ID not in system:"
puts Bank::Account.find(61239)

# TEST BASIC ACCOUNT - ALL VALID
test_basic = Bank::Account.new(1234,10000)
puts "Should return 9000:"
puts test_basic.withdraw(1000)
puts "Should return 11000:"
puts test_basic.deposit(2000)

# # TEST BASIC ACCOUNT - INVALID INITIAL BALANCE
# puts "Should raise Argument Error:"
# test_basic2 = Bank::SavingsAccount.new(1234,-10000)

# TEST SAVINGS ACCOUNT - INVALID WITHDRAWAL (TURN ON ALL VALID SAVINGS ACCOUNT TEST FIRST)
puts "Should return 'You do not have enough money in your account to withdraw that amount.' 11000"
puts test_basic.withdraw(20000)

# TEST SAVINGS ACCOUNT - ALL VALID
test_savings = Bank::SavingsAccount.new(1234,10000)
puts "Should return 8800:"
puts test_savings.withdraw(1000)
puts "Should return 22.0:"
puts test_savings.add_interest(0.25)

# TEST SAVINGS ACCOUNT - INVALID WITHDRAWAL (TURN ON ALL VALID SAVINGS ACCOUNT TEST FIRST)
puts "Should return 'You do not have enough money in your account to withdraw that amount.' 8822.0"
puts test_savings.withdraw(20000)

# # TEST SAVINGS ACCOUNT - INVALID INITIAL BALANCE
# puts "Should raise Argument Error:"
# test_savings2 = Bank::SavingsAccount.new(1234,-10000)

# TEST CHECKING ACCOUNT - ALL VALID
test_checking = Bank::CheckingAccount.new(1234,12000)
puts "Should return 9900:"
puts test_checking.withdraw(2000)

# TEST CHECKING ACCOUNT WITHDRAW USING CHECK (TURN ON ALL VALID CHECKING ACCOUNT TEST FIRST)
puts test_checking.withdraw_using_check(4900)
puts test_checking.account_status
puts test_checking.withdraw_using_check(1000)
puts test_checking.account_status
puts test_checking.withdraw_using_check(1000)
puts test_checking.account_status
puts "Four check should incur addtional 100 deduction"
puts test_checking.withdraw_using_check(1000)
puts test_checking.account_status
puts "Check withdrawal should allow negative balance up to 1000"
puts test_checking.withdraw_using_check(2800)
puts test_checking.account_status
puts "Check withdrawal should not allow negative balance beyond 1000"
puts test_checking.withdraw_using_check(1)
puts test_checking.account_status


# TEST RESET CHECKS (TURN ON VALID CHECKING AND WITHDRAW USING CHECKS FIRST)
puts test_checking.reset_checks
puts test_checking.checks_used

# TEST MONEY MARKET ACCOUNT - ALL VALID
test_money_market = Bank::MoneyMarketAccount.new(1234,2000000)
puts "Should return 1900000:"
puts test_money_market.withdraw(100000)
puts "Should return 2000000:"
puts test_money_market.deposit(100000)

# TEST MONEY MARKET ACCOUNT MAX TRANSACTIONS
puts test_money_market.account_status
puts test_money_market.deposit(1000)
puts test_money_market.account_status
puts test_money_market.deposit(1000)
puts test_money_market.account_status
puts test_money_market.deposit(1000)
puts test_money_market.account_status
puts test_money_market.deposit(1000)
puts test_money_market.account_status
puts "Should freeze account (6 transactions already completed):"
puts test_money_market.deposit(1000)
puts test_money_market.account_status

# TEST MONEY MARKET TRANSACTION COUNT RESET
test_money_market.reset_transactions_count
puts "Should return 0:"
puts test_money_market.transactions_month_to_date

# TEST MONEY MARKET WITHDRAWAL
puts "Should return 1004000:"
puts test_money_market.withdraw(1000000)
puts "Should return 984000:"
puts test_money_market.withdraw(10000)
puts "Should freeze account (Balance dropped below 100000)"
puts test_money_market.withdraw(10000)

# TEST MONEY MARKET DEPOSIT
puts test_money_market.reset_transactions_count
puts "Transactions month to date is:"
puts test_money_market.transactions_month_to_date
puts "Should return 994000"
puts test_money_market.deposit(10000)
puts "Transactions month to date should not have changed (Account balance below 100000):"
puts test_money_market.transactions_month_to_date
puts "Should return 104000:"
puts test_money_market.deposit(10000)
puts "Transactions month to date should not have changed (Account balance brought above 100000):"
puts test_money_market.transactions_month_to_date
puts "Should return 104000:"
puts test_money_market.deposit(10000)
puts "Transactions month to date should increment by 1:"
puts test_money_market.transactions_month_to_date

# TEST MONEY MARKET ADD INTEREST
puts test_money_market.add_interest(0.25)
