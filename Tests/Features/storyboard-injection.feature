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
