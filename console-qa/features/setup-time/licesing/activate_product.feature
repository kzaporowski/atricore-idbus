Feature: Activate EE Product Distribution
    In Order to activate my EE product
    As a System Administrator
    I Want to setup the EE product distribution with a license

Scenario: Successfull Activation of JOSSO EE Distribution for the firs time with a PRODUCTION License
   Given I am on the startup screen of EE product
   And I am seeing the 'Activate JOSSO EE' form
   When I upload the license file
   And I confirm the Activation process
   Then I should be able to login to the console for the first time

Scenario: Successfull Activate JOSSO EE Distribution for the firs time with a TRIAL License
   Given I am on the startup screen of EE product
   And I am seeing the 'Activate JOSSO EE' form
   When I upload the license file
   And I confirm the Activation process
   Then I should be able to login to the console for the first time


Scenario: Unsuccessfull Activation of JOSSO EE Distribution for the firs time with a PRODUCTION License
   Given I am on the startup screen of EE product
   And I am seeing the 'Activate JOSSO EE' form
   When I upload the license file
   And I confirm the Activation process
   Then I should see a message regarding the License problem and be able to upload a different file.
