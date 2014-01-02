Feature: Compose

  Scenario: Compose blueprint from YAML AST input
    Given a file named "ast.yaml" with:
      """
      _version: 1.0
      metadata:
      name: My API
      description:
      resourceGroups:
      """
    When I run `matter_compiler compose` interactively
    When I pipe in the file "ast.yaml"
    Then the output should contain:
      """
      # My API
      """
