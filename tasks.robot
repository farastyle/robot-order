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
Library           RPA.Desktop.Windows

*** Tasks ***
Request question
    Open questionary



*** Variables ***


*** Keywords ***
Open questionary
    ${a}=    Process Exists    Battle.net.exe    bool=True
    
    ${b}=    Process Exists    uganda    bool=True
    Log To Console    mock state > uganda > open ? ${b}
    IF     ${b} = false    
            Log To Console    mock state > uganda > open ? ${b}
    END
    IF     ${a} = false
    Log To Console    \nBattle.net > open ? ${a}
    END