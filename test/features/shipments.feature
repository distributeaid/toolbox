Feature: Shipments

  Scenario: No shipments
    Given I am root
    And there are no shipments
    When I count all shipments
    Then I should have 0
    When I query all shipments
    Then I should have a list
    And it should have length 0

  Scenario: Single shipment
    Given I am root
    And there are no groups
    And there are no addresses
    And there are no shipments
    And a sender group
    And a receiver group
    And a sender address
    And a receiver address
    And a shipment from sender to receiver
    When I count all shipments
    Then I should have 1
    When I query all shipments
    Then I should have a list
    And it should have length 1