Feature: Shipments

  Scenario: No shipments
    Given I am root
    And there are no shipments
    When I count all shipments
    Then I should have 0
    When I query all shipments
    And I should have an empty list

