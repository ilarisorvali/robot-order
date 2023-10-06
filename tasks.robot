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
Library    OperatingSystem

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Order robots
    
*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order    browser_selection=firefox
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
        Order single robot    ${robot_to_order}
        
    END
    Close the annoying modal

Order single robot
    [Arguments]    ${robot_to_order}
    Fill the order form    ${robot_to_order}
    Wait Until Keyword Succeeds    5x    2s    Submit the order
    ${scr}=    Take a screenshot of the robot    ${robot_to_order}[Order number]
    ${pdf}=    Store the receipt as a PDF file   ${robot_to_order}[Order number] 
    Embed the robot screenshot to the receipt PDF file    ${pdf}    ${scr}
    Close receipt

Submit the order
    Click Button    id:order
    Wait Until Page Contains Element    id:order-another

Take a screenshot of the robot
    [Arguments]    ${order_number}
    ${scr}=   Screenshot    id=robot-preview-image    ${OUTPUT_DIR}${/}screenshots/${order_number}.png
    RETURN    ${OUTPUT_DIR}${/}screenshots/${order_number}.png

Store the receipt as a PDF file
    [Arguments]    ${order_number}
    Wait Until Element Is Visible    id:receipt
    ${receipt}=    Get Element Attribute    id:receipt    outerHTML
    ${pdf}=    Html To Pdf    ${receipt}    ${OUTPUT_DIR}${/}receipts/${order_number}.pdf
    RETURN    ${OUTPUT_DIR}${/}receipts/${order_number}.pdf
    
    
Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${pdf}    ${scr}
    ${robot_image}=    Create list
    ...    ${scr}:align=center
    Add Files To Pdf    ${robot_image}    ${pdf}
    

Fill the order form
    [Arguments]    ${robot_to_order}
    Close the annoying modal
    Select From List By Value    head    ${robot_to_order}[Head]
    Click Button    id:id-body-${robot_to_order}[Body]
    Input Text    class:form-control  ${robot_to_order}[Legs]
    Input Text    id:address    ${robot_to_order}[Address]
    Wait Until Page Contains Element    id:order
    
    