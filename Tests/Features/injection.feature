Feature: as User I should be able to inject new classes to the running project

  Background: We should prepare project for injection
    Given project from `InjectionProject` with  name `InjectionExample` is used
    And output directory setup to `/tmp/output2`
    And project build is configured to `InjectionExample.xcworkspace` workspace and `InjectionExample` scheme
    And project was successfully built

  Scenario: Update on class injection
    Given I start project
    And Change its source file "InjectionExample/Classes/IEBase.m" with contents of file "InjectionExample/Classes/IEBaseUpdateOnClassInjection.m"
    And Inject inject new version of "InjectionExample/Classes/IEBase.m" with "<Injected>" as test string
    Then I should see "<Injected>" in running project output
    And I end project process

  Scenario: Class method injection
    Given I start project
    And Change its source file "InjectionExample/Classes/IEBase.m" with contents of file "InjectionExample/Classes/IEBaseClassMethodInjection.m"
    And Inject inject new version of "InjectionExample/Classes/IEBase.m" with "<Injected>" as test string
    Then I should see "<Injected>" in running project output
    And I end project process

