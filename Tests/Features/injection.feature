Feature: as User I should be able to inject new classes to the running project

  Background:
    Given I have prepared xcode-project at "fixtures/InjectionProject" for injection at "tmp/project-dir"
    And build directory is setup to "/tmp/output2"
    And project at "InjectionProject" with workspace "InjectionExample.xcworkspace" was successfully build with "InjectionExample" scheme

  Scenario:
    Given I start project at with name "InjectionExample"
    And Change its source file "InjectionExample/Classes/IEBase.m" with contents of file "InjectionExample/Classes/IEBaseUpdateOnClassInjection.m"
    And Inject inject new version of "InjectionExample/Classes/IEBase.m" with ":)))))" as test string
    Then I should see ":)))))" in running project output
    And I end project process
