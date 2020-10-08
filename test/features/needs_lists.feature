Feature: Needs Lists

  Background:
    Given I am root
    And a "default" group
    And a "default" project
    Given a "from" date
    Given a "to" date in 30 days
    And a "default" needs lists

  Scenario: Overlapping needs lists
    And a "from" date in 2 days
    When I create a "default" needs list
    Then it should not be successful
    And it should have user message "needs lists for the same project cannot overlap dates"

  Scenario: Modified needs lists
    And a "from" date in 4 days
    When I update the "default" needs list
    Then it should be successful
    And it should have a from
    And field "from" should be in 4 days