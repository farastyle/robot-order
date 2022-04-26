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
Library           RPA.Excel.Application

*** Variables ***
${username}=      gilberto5@gilberto.com
${password}=      donpedro
${link}=          https://s3.us-west-2.amazonaws.com/secure.notion-static.com/0ea65689-6a27-40ca-8799-f2811205c42c/Tabela_de_Produtos.xlsx?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220425%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220425T164047Z&X-Amz-Expires=86400&X-Amz-Signature=abf2bb2416e6b1be695dcc63451dabd7f8a419e252bf57bbad19864b97296825&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Tabela%2520de%2520Produtos.xlsx%22&x-id=GetObject
${names}
${breeds}

*** Tasks ***
Registra produtos
    Abre site
    loga server
    Open Excel

Cria lista de produtos


*** Keywords ***
Abre site
    Open Available Browser    https://front.serverest.dev/login

Loga Server
    Click Element    xpath: //*[contains(text(), "Cadastre-se")]
    Input Text    nome    ${username}
    Input Text    email    ${username}
    Input Password    password    ${password}
    Select Checkbox    administrador
    Click Button    xpath: //*[contains(text(), "Cadastrar")]
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
    #${before}=    Http Get    https://api.thecatapi.com/v1/images/search    ###infomation saved for later
    #${json}=    Convert string to JSON    ${before}
    #@{link}=    Get values from JSON    ${names}    ${breeds}[*].url
    Choose File    id:imagem    ${CURDIR}/nMBCPd7pu.jpg
    Click Button    xpath: //*[contains(text(), "Cadastrar")]
    Wait Until Page Contains Element    xpath://*[@id="root"]/div/div/h1
    Click Element When Visible    xpath://*[@id="navbarTogglerDemo01"]/ul/li[4]/a

Open Excel
    Download    ${link}    overwrite=True
    Open Workbook    Tabela_de_Produtos.xlsx
    ${orderNumbers}=    Read Worksheet As Table    header=True
    Close Workbook
    FOR    ${orderNumber}    IN    @{orderNumbers}
        Cadastra produto    ${orderNumber}
    END

Cria Lista produtos
    Click Element When Visible    xpath://*[@id="navbarTogglerDemo01"]/ul/li[5]/a
    #Get table cell    xpath://*[@id="root"]/div/div/p/table
