*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library    RPA.Browser.Selenium    auto_close=${True}
Library    RPA.PDF
Library    RPA.HTTP
Library    RPA.Tables

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Order robots
    
*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    Wait Until Page Contains Element    id:order
    

Get robot orders
    Download    https://robotsparebinindustries.com/orders.csv  overwrite=True
    ${table}=    Read table from CSV    orders.csv
    
    RETURN    ${table}
Close the annoying modal
    Click Button    class:btn-dark

Close receipt
    Wait And Click Button    id:order-another
    Wait Until Page Contains Element   id:order

Order robots
    ${orders}=    Get robot orders
    FOR    ${robot_to_order}    IN    @{orders}
        Fill the order form    ${robot_to_order}
        Wait Until Keyword Succeeds   5x    2s    Submit the order
        Close receipt
    END

Submit the order
    Click Button    id:order
    Wait Until Page Contains Element    id:order-another
    

Preview the robot
    Click Button    id:preview

Fill the order form
    [Arguments]    ${robot_to_order}
    Close the annoying modal
    Select From List By Value    head    ${robot_to_order}[Head]
    Click Button    id:id-body-${robot_to_order}[Body]
    Input Text    class:form-control  ${robot_to_order}[Legs]
    Input Text    id:address    ${robot_to_order}[Address]
    Wait Until Page Contains Element    id:order
    
    