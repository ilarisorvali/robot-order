*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library    RPA.Browser.Selenium    auto_close=${FALSE}
Library    RPA.PDF
Library    RPA.HTTP
Library    RPA.Tables

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Close the annoying modal


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    Wait Until Page Contains Element    id:order
    Log robots

Get robot orders
    Download    https://robotsparebinindustries.com/orders.csv  overwrite=True
    ${table}=    Read table from CSV    orders.csv
    
    RETURN    ${table}
Close the annoying modal
    Click Button    class:btn-dark

Log robots
    ${orders}=    Get robot orders
    FOR    ${robot}    IN    @{orders}
        Log    ${robot}
    END

Fill and submit the form for one robot order
    [Arguments]    ${robot_to_order}
    Close the annoying modal
    Select From List By Value    head    ${robot_to_order}[Head]
    Input Text    firstname    ${robot_to_order}[First Name]
    Input Text    lastname    ${robot_to_order}[Last Name]
    Input Text    salesresult    ${robot_to_order}[Sales]
    Select From List By Value    head    ${robot_to_order}[Head]
    Click Button    id:order
    Wait Until Page Contains Element    id:order
    