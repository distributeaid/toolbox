Feature: Needs Lists

  Background:
    Given I am root
    And a "default" group
    And a "default" project

  Scenario:
    Given a "from" date
    Given a "to" date in 30 days
    When I create a "default" needs list
    Then it should be successful