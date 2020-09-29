Feature: Shipments

  Background:
    Given I am root
    And there are no groups
    And there are no addresses
    And there are no shipments
    And a "pickup" group
    And a "delivery" group
    And a "pickup" address
    And a "delivery" address
    And a shipment from pickup to delivery

  @current
  Scenario: Single shipment
    Given I am root
    When I count all shipments
    Then I should have 1
    When I query all shipments
    Then I should have a list
    And it should have length 1

  Scenario: No shipments
    Given I am root
    And there are no shipments
    When I count all shipments
    Then I should have 0
    When I query all shipments
    Then I should have a list
    And it should have length 0


  Scenario: Update shipment with an unknown address
    Given an unknown shipment pickup address
    When I update that shipment
    Then it should not be successful
    And it should have user message "pickup address not found"

  Scenario: Update shipment with an invalid status
    Given shipment status "unknown"
    When I update that shipment
    Then it should not be successful
    And it should have user message "is invalid"

  Scenario: Update pickup address
    Given a "new pickup" group
    And a "new pickup" address
    And that's the shipment pickup address
    When I update that shipment
    Then it should be successful

