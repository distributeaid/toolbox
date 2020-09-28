Feature: Addresses

  Scenario: Shipment attributes
    Given I am root
    And there are no groups
    And there are no addresses
    And a sender group
    And a sender address
    When I get that address
    Then it should be successful
    And it should have a opening_hour
    And it should have a closing_hour
    And it should have a type
    And it should have a has_loading_equipment
    And it should have a has_unloading_equipment
    And it should have a needs_appointment