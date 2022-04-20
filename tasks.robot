*** Settings ***
Documentation     Template robot main suite, robot for order robot at robotsparebin
Library           Collections
Library           MyLibrary
Resource          keywords.robot
Variables         MyVariables.py
Library           RPA.Browser.Selenium
Library           RPA.Tables
Library           RPA.HTTP
Library           RPA.PDF
Library           RPA.Robocorp.WorkItems
Library           RPA.PDF
Library           RPA.Archive
Library           RPA.Robocorp.Vault
Library           RPA.Dialogs

*** Tasks ***
Request question
    Open questionary

Order Robot from robotsparebin industries inc
    Download the CSV file
    Open website
    Fill the form using the data from CSV file

Archive all pdf
    Add all pdf to Archive

*** Variables ***
${results}=       robottasks

*** Keywords ***
Open questionary
    Add heading    Do you want zipfile on your name?    size=Large
    Add heading    Please enter your Name
    Add text input    message
    #Insert user information    ${result.Name}
    Add submit buttons    buttons=No,Yes    default=Yes
    ${result}=    Run dialog    timeout=60
    IF    $result.submit == "Yes"
        ${results}=    ${result.message}
    END

Download the CSV file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Open website
    ${page}=    Get Secret    robotorder
    Open Available Browser    ${page}[Link]
    Wait Until Page Contains Element    class:alert-buttons
    Click Button    xpath: //*[contains(text(), "OK")]

Fill and submit the form for one person
    [Arguments]    ${OrderNumber}
    Select From List By Index    id:head    ${OrderNumber}[Head]
    Select Radio Button    body    ${OrderNumber}[Body]
    Input Text    class:form-control    ${OrderNumber}[Head]
    Input Text    address    ${OrderNumber}[Address]
    Click Button    preview
    Wait Until Page Contains Element    robot-preview-image
    Click Button    order
    Check for error
    Screenshot    id:receipt    filename=${CURDIR}/output/print${OrderNumber}[Order number].png
    Screenshot    id:robot-preview-image    filename=${CURDIR}/output/robot${OrderNumber}[Order number].png
    ${receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt_html}    ${CURDIR}/output/receipts${OrderNumber}[Order number].pdf
    Open PDF    ${CURDIR}/output/receipts${OrderNumber}[Order number].pdf
    Add Watermark Image To PDF    image_path=${CURDIR}/output/robot${OrderNumber}[Order number].png    source_path=${CURDIR}/output/receipts${OrderNumber}[Order number].pdf    output_path=${CURDIR}/output/receipts${OrderNumber}[Order number].pdf
    Close Pdf
    Wait Until Element Is Visible    id:order-another
    Click Button    order-another
    Click Button    xpath: //*[contains(text(), "OK")]

Fill the form using the data from CSV file
    ${table}=    Read table from CSV    orders.csv    header=True
    FOR    ${OrderNumber}    IN    @{table}
        Fill and submit the form for one person    ${OrderNumber}
    END

Check for error
    FOR    ${onemore}    IN RANGE    10
        ${onemore}    Is Element Visible    xpath=//*[@id="order-another"]
        Exit For Loop If    ${onemore} == True
        Wait And Click Button    xpath=//*[@id="order"]
    END

Add all pdf to Archive
    Archive Folder With Zip    ${CURDIR}/output    ${CURDIR}/output/${results}.zip    include=*.pdf
