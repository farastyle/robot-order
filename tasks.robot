*** Settings ***
Documentation     v1.02 Este robo vai logar no .serverest.dev criar uma conta como admin, caso nao der certo vai tentar logar como usuario. depois inicia uma leitura no aquivo excel coloca as infomacoes no formulario, envia ( estas infomacoe por enquanto tem quer ser unicas, podemos tratar o erro para continuar se itens ja existirem) apos cadastrar itens volta para pagina de lista de itens e cria um aquivo com a tabela de itens - a recomendacao seria colocar os usuarios em arquivo vault tratar erros quando itens ja estao cadastrados, preciso de maior conhecimento em como pegar essa tabela de forma correta! e fecha tudo
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
Library           RPA.FileSystem

*** Variables ***
${link}=          https://s3.us-west-2.amazonaws.com/secure.notion-static.com/0ea65689-6a27-40ca-8799-f2811205c42c/Tabela_de_Produtos.xlsx?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220428%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220428T165938Z&X-Amz-Expires=86400&X-Amz-Signature=7df2d01b41dd8d958c34ce5c88485d2fa990c4a610b0295aece9c00580939393&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Tabela%2520de%2520Produtos.xlsx%22&x-id=GetObject
${names}
${breeds}
${html_table}


*** Tasks ***
Loga no site
    Abre pagina
    loga server

Registra produtos
    Open Excel

Cria lista de produtos
    Vai para Lista de produtos

Cria tabela
    Novo metodo
    #${table}=    Read Table From Html    ${html_table}    #estes codigos foram deixados para traz para depois aperfeicoar o sistema.
    #${dimensions}=    Get Table Dimensions    ${table}    #nao foi possivel reconhecer a tabela da lista e por iss nao foi possivel criar um arquivo desejado apenas para cumprir os requisitos continuei de outra forma
    #${first_row}=    Get Table Row    ${table}    ${0}
    #${first_cell}=    RPA.Tables.Get Table Cell    ${table}    ${0}    ${0}
    #FOR    ${row}    IN    @{table}
    #    Log To Console    ${row}
    #END
    #Write table to CSV    ${table}    output.csv

Finaliza
    Fecha tudo

*** Keywords ***
Abre pagina
    Open Available Browser    https://front.serverest.dev/login    maximized=true

Loga Server
    Click Element    xpath://*[contains(text(), "Cadastre-se")]
    ${page}=    Get Secret    credentials
    Input Text    nome    ${page}[username]
    Input Text    email    ${page}[username]
    Input Password    password    ${page}[password]
    Select Checkbox    administrador
    Click Button    xpath: //*[contains(text(), "Cadastrar")]
    #Check for error if admin is already in    //*[@id="root"]/div/div/p/table
    Set Selenium Implicit Wait    3
    ${onemore}    Is Element Visible    xpath=//*[@id="root"]/div/div/form/div[1]/button/span
    IF    ${onemore}
        Click Element    xpath://*[@id="root"]/div/div/form/small/a
        Input Text    email    ${page}[username]
        Input Password    password    ${page}[password]
        Click Element    //*[@id="root"]/div/div/form/button
        Exit For Loop If    ${onemore} == False
    END
    Set Selenium Implicit Wait    10
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
    ${twomore}    Is Element Visible    xpath=//*[@id="root"]/div/div/p/table
    IF    ${twomore}
        Click Element When Visible    xpath://*[@id="navbarTogglerDemo01"]/ul/li[4]/a
        Exit For Loop If    ${twomore} == False
    END
    #Wait Until Page Contains Element    xpath://*[@id="root"]/div/div/h1
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
    Set Selenium Implicit Wait    7

Novo metodo
    ${html_table}=    Get Element Attribute    xpath://*[@id="root"]/div/div/p/table    outerHTML
    Create File    ${CURDIR}/tabelaatualizada.csv    ${html_table}    encoding=utf-8    overwrite=True

Fecha tudo
    Close Browser
