  Feature: Compose

  Background:
    Given a file named "blueprint.md" with:
      """
      # My API
      Description of *My API*.

      # Group Red
      Description of *Red* Group.

      """

    And a file named "ast.yaml" with:
      """
      _version: 1.0
      metadata:
      name: My API
      description: "Description of *My API*.\n\n"
      resourceGroups:
      - name: Red
        description: "Description of *Red* Group.\n"
        resources:
      """

    And a file named "ast.json" with:
      """
      {
        "_version": "1.0",
        "metadata": {},
        "name": "My API",
        "description": "Description of *My API*.\n\n",
        "resourceGroups": [
          {
            "name": "Red",
            "description": "Description of *Red* Group.\n",
            "resources": []
          }
        ]
      }
      """

  Scenario: Compose blueprint from an YAML stdin input
    When I run `matter_compiler --format yaml` interactively
    When I pipe in the file "ast.yaml"
    Then the output should match the content file "blueprint.md"

  Scenario: Compose blueprint from an YAML file
    When I run `matter_compiler ast.yaml`
    Then the output should match the content file "blueprint.md"    

  Scenario: Compose blueprint from a JSON stdin input
    When I run `matter_compiler --format json` interactively
    When I pipe in the file "ast.json"
    Then the output should match the content file "blueprint.md"

  Scenario: Compose blueprint from a JSON file
    When I run `matter_compiler ast.json`
    Then the output should match the content file "blueprint.md"
