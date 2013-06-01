Feature: as User I should be able to inject new classes to the running project

  Background: We should prepare project for injection
    Given project from `InjectionProject` with  name `InjectionExample` is used
    And output directory setup to `/tmp/output2`
    And project build is configured to `InjectionExample.xcworkspace` workspace and `InjectionExample` scheme
    And project was successfully built

  @methods
  Scenario: Update on class injection
    Given I start project
    And Change its source file "InjectionExample/Classes/IEBase.m" with contents of file "InjectionExample/Classes/IEBaseUpdateOnClassInjection.m"
    And Inject inject new version of "InjectionExample/Classes/IEBase.m" with "<InjectedClass>" as test string
    Then I should see "<InjectedClass>" in running project output
    And I end project process

  @methods @class_methods
  Scenario: Class method injection
    Given I start project
    And Change its source file "InjectionExample/Classes/IEBase.m" with contents of file "InjectionExample/Classes/IEBaseClassMethodInjection.m"
    And Inject inject new version of "InjectionExample/Classes/IEBase.m" with "<InjectedClassMethod>" as test string
    Then I should see "<InjectedClassMethod>" in running project output
    And I end project process

  @methods @children
  Scenario: Call updateOnClass injection on child (successor) classes
    Given I start project
    And Change its source file "InjectionExample/Classes/IEBase.m" with contents of file "InjectionExample/Classes/IEBaseUpdateOnClassInjection.m"
    And Inject inject new version of "InjectionExample/Classes/IEBase.m" with "<InjectedClass>" as test string
    Then I should see "<IEBaseChild updateOnClassInjecton called>" in running project output
    And I end project process

  @strings
  Scenario: Localizable strings injection
    Given I start project
    And Change its source file "InjectionExample/Classes/IEBase.m" with contents of file "InjectionExample/Classes/IEBaseLocalizableStringInjection.m"
    And Inject inject new version of "InjectionExample/Classes/IEBase.m" with "" as test string
    And Inject inject new version of "InjectionExample/InjectionExample/Resources/Localizable.strings" with "<Injected localizable string>" as test string
    Then I should see "<Injected localizable string>" in running project output
    And I end project process

  @strings
  Scenario: Real Localizable strings injection (with .lproj)
    Given I start project
    And Change its source file "InjectionExample/Classes/IEBase.m" with contents of file "InjectionExample/Classes/IEBaseRealLocalizableStringInjection.m"
    And Inject inject new version of "InjectionExample/Classes/IEBase.m" with "" as test string
    And Inject inject new version of "InjectionExample/InjectionExample/Resources/en.lproj/ReallyLocalizable.strings" with "<Really Injected localizable string>" as test string
    Then I should see "<Really Injected localizable string>" in running project output
    And I end project process

