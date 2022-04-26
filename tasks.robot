*** Settings ***
Documentation     Template robot main suite, robot for order robot at robotsparebin
Library           Collections
Library           MyLibrary
Resource          keywords.robot
Variables         MyVariables.py
Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.Tables
Library           RPA.HTTP
Library           RPA.PDF
Library           RPA.Archive
Library           RPA.Robocorp.Vault
Library           RPA.Excel.Files
Library           RPA.Robocorp.WorkItems
Library           RPA.JSON
Library           RPA.Tables
Library           html_tables.py

*** Variables ***
${username}=      gilberto5@gilberto.com
${password}=      donpedro
${link}=          https://s3.us-west-2.amazonaws.com/secure.notion-static.com/0ea65689-6a27-40ca-8799-f2811205c42c/Tabela_de_Produtos.xlsx?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220426%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220426T103045Z&X-Amz-Expires=86400&X-Amz-Signature=0e6dc82c0c7e32b26c2289aee830b74d73a518edff2f8a0d098215c0b38fe468&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Tabela%2520de%2520Produtos.xlsx%22&x-id=GetObject
${names}
${breeds}

*** Tasks ***
Registra produtos
    Abre site
    loga server
    Open Excel

Cria lista de produtos
    Vai para Lista de produtos

*** Keywords ***
Abre site
    Open Available Browser    https://front.serverest.dev/login    maximized=true

Loga Server
    Click Element    xpath: //*[contains(text(), "Cadastre-se")]
    Input Text    nome    ${username}
    Input Text    email    ${username}
    Input Password    password    ${password}
    Select Checkbox    administrador
    Click Button    xpath: //*[contains(text(), "Cadastrar")]
    #Check for error
    Set Selenium Implicit Wait    3
    ${onemore}    Is Element Visible    xpath=//*[@id="root"]/div/div/form/div[1]/button/span
    IF    ${onemore}
        Click Element    xpath://*[@id="root"]/div/div/form/small/a
        Input Text    email    ${username}
        Input Password    password    ${password}
        Click Element    //*[@id="root"]/div/div/form/button
        Exit For Loop If    ${onemore} == False
    END
    Set Selenium Implicit Wait    20
    Click Element    xpath://*[@id="navbarTogglerDemo01"]/ul/li[4]/a
    Wait Until Page Contains Element    imagem

Cadastra produto
    [Arguments]    ${orderNumber}
    Wait Until Page Contains Element    xpath://*[@id="root"]/div/div/div/form/h1
    Input Text When Element Is Visible    id:nome    ${orderNumber}[Nome]
    Input Text When Element Is Visible    id:price    ${orderNumber}[Preço]
    Input Text When Element Is Visible    id:description    ${orderNumber}[Descrição]
    Input Text When Element Is Visible    id:quantity    ${orderNumber}[Quantidade]
    ${response}=    GET    https://api.thecatapi.com/v1/images/search
    ${json}=    Set Variable    ${response.json()}
    ${url}=    Get Value From Json    ${json}    $..url
    Download    ${url}    target_file=${orderNumber}[Nome].jpg    overwrite=True
    Choose File    id:imagem    ${CURDIR}/${orderNumber}[Nome].jpg
    Click Button    xpath: //*[contains(text(), "Cadastrar")]
    Wait Until Page Contains Element    xpath://*[@id="root"]/div/div/h1
    Click Element When Visible    xpath://*[@id="navbarTogglerDemo01"]/ul/li[4]/a

Open Excel
    Download    ${link}    overwrite=True
    Open Workbook    ${CURDIR}/Tabela_de_Produtos.xlsx
    ${orderNumbers}=    Read Worksheet As Table    header=True
    Close Workbook
    FOR    ${orderNumber}    IN    @{orderNumbers}
        Cadastra produto    ${orderNumber}
    END

Vai para Lista de produtos
    Click Element When Visible    xpath://*[@id="navbarTogglerDemo01"]/ul/li[5]/a
    Read HTML table as Table

Read HTML table as Table
    ${html_table}=    Get HTML table
    ${table}=    Read Table From Html    ${html_table}
    ${dimensions}=    Get Table Dimensions    ${table}
    ${first_row}=    Get Table Row    ${table}    ${0}
    ${first_cell}=    RPA.Tables.Get Table Cell    ${table}    ${0}    ${0}
    FOR    ${row}    IN    @{table}
        Log To Console    ${row}
    END
    Write table to CSV    ${html_table}    output.csv

Get HTML table
    ${html_table}=    Get Element Attribute    //*[@id="root"]/div/div/p/table    outerHTML
    [Return]    ${html_table}
