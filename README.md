# Billing_Calls
Billing system for National, International and Local Calls

**Operating System**: Fedora, unix version: 6.8.9-200.fc39.x86_64

**Ruby Version**: 3.2.4

## Assumptions

1. **Database Source**: It is assumed that phone calls, standard rate, and both international and domestic rates are sourced from a database and they are stored without errors.
2. **Phone Call Logs Format**:
    ```ruby
    phone_call = {
      origin_country_code: "1",
      origin_area_code: "606",
      origin_number: "1113537",
      dest_country_code: "1",
      dest_area_code: "204",
      dest_number: "9052034",
      start_full_date: DateTime.new(2024, 5, 13, 9, 0, 0),
      end_full_date: DateTime.new(2024, 5, 13, 9, 10, 0)
    }
    ```
3. **Rates**:
    - International Rate: 2.0 (modifiable)
    - Domestic Rate: 0.5 (modifiable)

## Thought Process

1. **Initialization**: A `Billing` class will be initialized to handle the billing process.
2. **Processing Phone Call Logs**: The class will receive and process phone call logs related to the client.
3. **Calculation**: 
    - After processing all the information, the `Billing` class will calculate the total cost for the desired month.
    - The total cost is obtained by iterating over an array of calls stored in the `Billing` class, which contains information about each call.
4. **Cost Breakdown**: 
    - The `Billing` class will maintain three different counters for Domestic, Local, and International total costs. This is useful for providing a detailed breakdown of the total cost, which is the sum of these three costs plus the standard rate (initialized as a variable).
    - Depending on the type of call, the partial total cost will be modified accordingly during each iteration:
        1. If `origin_country_code` is different from `dest_country_code`, it is an international call.
        2. If `origin_area_code` is different from `dest_area_code`, it is a domestic call.
        3. If both codes are equal, it is a local call.
5. **Subclass Delegation**:
    - For each type of call, a subclass of the parent `Call` class will be created.
    - The cost calculation function will be delegated to each subclass.
6. **Detailed Call Information**:
    - During each iteration, detailed information about the calls will be added to the corresponding list of detailed calls.
    - This is useful for providing a detailed summary of the calls.
    

