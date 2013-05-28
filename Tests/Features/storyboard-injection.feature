Feature: as User I should be able to inject new classes to the running project

  Background: We should prepare project for injection
    Given project from `InjectionProject` with  name `StoryboardInjectionExample` is used
    And output directory setup to `/tmp/output2`
    And project build is configured to `InjectionExample.xcworkspace` workspace and `StoryboardInjectionExample` scheme
    And project was successfully built

  Scenario: Update storyboard layout
    Given I start project
    And Change its source file "StoryboardInjectionExample/StoryboardInjectionExample/en.lproj/MainStoryboard.storyboard" with contents of file "StoryboardInjectionExample/StoryboardInjectionExample/Injections/ButtonFrame/MainStoryboard.storyboard"
    And Inject inject new version of "StoryboardInjectionExample/StoryboardInjectionExample/en.lproj/MainStoryboard.storyboard" with "<Injected>" as test string
    Then I should see "Start button frame : {{0, 0}, {100, 100}}" in running project output
    And I end project process

#  Scenario: Class method injection
#    Given I start project
#    And Change its source file "InjectionExample/Classes/IEBase.m" with contents of file "InjectionExample/Classes/IEBaseClassMethodInjection.m"
#    And Inject inject new version of "InjectionExample/Classes/IEBase.m" with "<Injected>" as test string
#    Then I should see "<Injected>" in running project output
#    And I end project process
#
#  Scenario: Localizable strings injection
#    Given I start project
#    And Change its source file "InjectionExample/Classes/IEBase.m" with contents of file "InjectionExample/Classes/IEBaseLocalizableStringInjection.m"
#    And Inject inject new version of "InjectionExample/Classes/IEBase.m" with "" as test string
#    And Inject inject new version of "InjectionExample/InjectionExample/Resources/Localizable.strings" with "<Injected localizable string>" as test string
#    Then I should see "<Injected localizable string>" in running project output
#    And I end project process
#
#  Scenario: Real Localizable strings injection (with .lproj)
#    Given I start project
#    And Change its source file "InjectionExample/Classes/IEBase.m" with contents of file "InjectionExample/Classes/IEBaseRealLocalizableStringInjection.m"
#    And Inject inject new version of "InjectionExample/Classes/IEBase.m" with "" as test string
#    And Inject inject new version of "InjectionExample/InjectionExample/Resources/en.lproj/ReallyLocalizable.strings" with "<Really Injected localizable string>" as test string
#    Then I should see "<Really Injected localizable string>" in running project output
#    And I end project process

