Feature: When User installs dyci, it should be correctly installed

  Background:
    Given an empty file named "clang-location/clang"
    And a file named "xcrun" with:
    """
    #!/bin/bash
    echo `pwd`/clang-location/clang
    exit 0
    """
    And I run `chmod +x xcrun`
    And I double `xcrun` to local implementation


  Scenario: I should be able to fake some parts of dyci
            To correctly run fake installation
    When I run `xcrun -find clang`
    Then the stderr should not contain anything
    Then the output should contain "clang-location/clang"


 Scenario: When dyci installed, original clang file should be backed up
   When I install dyci
   Then a file named "clang-location/clang.backup" should exist
   And a file named "clang-location/clang-real" should exist
   And a file named "clang-location/clang-real++" should exist
   And a file named "clang-location/clangParams.py" should exist
   And the file "clang-location/clang" should contain "== CLANG_PROXY =="

   And a file named "clang-location/clang.backup" should exist
   And the file "clang-location/clang.backup" should not contain "== CLANG_PROXY =="


  Scenario: In case if original clang backup was wiped down, we shouldn't make backup of clang proxy
    When I install dyci
    And I remove the file "clang-location/clang.backup"
    And I reinstall dyci
    Then a file named "clang-location/clang.backup" should not exist



