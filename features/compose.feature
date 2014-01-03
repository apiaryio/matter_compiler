Feature: Compose

  Background:
    Given a file named "ast.yaml" with:
      """
      _version: 1.0
      metadata:
      name: My API
      description:
      resourceGroups:
      """
    And a file named "ast.json" with:
      """
      {
        "_version": "1.0",
        "metadata": {},
        "name": "My API",
        "description": "",
        "resourceGroups": []
      }
      """

  Scenario: Compose blueprint from an YAML stdin input
    When I run `matter_compiler --format yaml` interactively
    When I pipe in the file "ast.yaml"
    Then the output should contain:
      """
      # My API
      """

  Scenario: Compose blueprint from an YAML file
    When I run `matter_compiler tmp/aruba/ast.yaml`
    Then the output should contain:
      """
      # My API
      """      

  Scenario: Compose blueprint from a JSON stdin input
    When I run `matter_compiler --format json` interactively
    When I pipe in the file "ast.json"
    Then the output should contain:
      """
      # My API
      """

  Scenario: Compose blueprint from a JSON file
    When I run `matter_compiler tmp/aruba/ast.json`
    Then the output should contain:
      """
      # My API
      """
