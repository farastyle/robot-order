*** Settings ***
Documentation     Este robo vai logar no .serverest.dev criar uma conta como admin, caso nao der certo vai tentar logar como usuario. depois inicia uma leitura no aquivo excel coloca as infomacoes no formulario, envia ( estas infomacoe por enquanto tem quer ser unicas, podemos tratar o erro para continuar se itens ja existirem) apos cadastrar itens volta para pagina de lista de itens e cria um aquivo com a tabela de itens - a recomendacao seria colocar os usuarios em arquivo vault tratar erros quando itens ja estao cadastrados, preciso de maior conhecimento em como pegar essa tabela de forma correta!
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
${username}=      gilberto5@gilberto.com
${password}=      donpedro
${link}=          https://doc-0s-3o-docs.googleusercontent.com/docs/securesc/kiaj3932uatpq3enb5ml3jjc88kg64vn/pre6ld1khss1rl8fm70thuk9haf84ddc/1651165725000/05215736671936011431/05215736671936011431/1YnuYJ01cPmEzB-NTmn6G_3NB7u1xThuP?e=download&ax=ACxEAsZdcqA9aZ-Ig1EUt1CRFtVWdj9gjEYhhumsutjRXohfmjpcJPwN_lyX_eDNDi6jmV3wO6dmQ0t96_c20pfq4Dk7jJqnc8wLY0DvYPF1MrXiRdBsW_dX2VX0hZa6Zx6Cb8rZeMugEMvD74slUaww42zhUR7ILFTJXChpNtgF1977YWegOr9_xwa3ZvxxrPMDHLjs6abiabRSf4QO_ohfS4SsxWYuco5RRV2yDNR2RkfWgZivjTW3pYivbTF162A_D-uY77vloBK7PrDYLwmabhSnBSGlCNOt-3jEDeOp2ZjuDKcPHUj6Z3P2B4PiGYcUMoBBUa4qsEzbb3wVr8qy0PV5oolAWbg5Uz2-T412DAc687ntRFIxppf1gSFQjDfc0rZDf-gWo4Jvhlgj1I1mxrKpkbwCpi5z_5xEv1dqbz6gtpkHDIs71Tl1oY9RgXjkqy49aS0ZD-_WxPyjlchC0e58zQFLK5zH0r1G-LwYxJZG7BJhJP0SXUvWGgAH97vnbcogn3RkoX20Gx9Qzsdzlmz6KZh4ZHUMtjctie1WUygMhxCb8723izJGB5Hy2MwTIS1DBvSItS33XeHKuMsBGu77SqfZcxQhf_09GD8ANpKtwn4XuMykZ0VaQcCRDIyrdYkMM7P0i-8HYcNjbsNFM_Vyc_a1-AvCI1lsRQkz6gJyj5NTeAD3fSPuQUUoOQD753fbhQyOf1RZL9utCKcvqVd621zEiE73uI9-SeMXunrmEJO-wgup&authuser=1&nonce=kgft3jp9rtoha&user=05215736671936011431&hash=6hqr33st77461slkubal4fp4f28lbo0u
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

*** Keywords ***
Abre pagina
    Open Available Browser    https://front.serverest.dev/login    maximized=true

Loga Server
    Click Element    xpath: //*[contains(text(), "Cadastre-se")]
    Input Text    nome    ${username}
    Input Text    email    ${username}
    Input Password    password    ${password}
    Select Checkbox    administrador
    Click Button    xpath: //*[contains(text(), "Cadastrar")]
    #Check for error if admin is already in
    Set Selenium Implicit Wait    3
    ${onemore}    Is Element Visible    xpath=//*[@id="root"]/div/div/form/div[1]/button/span
    IF    ${onemore}
        Click Element    xpath://*[@id="root"]/div/div/form/small/a
        Input Text    email    ${username}
        Input Password    password    ${password}
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
    Set Selenium Implicit Wait    7

Novo metodo
    ${html_table}=    Get Element Attribute    //*[@id="root"]/div/div/p/table    outerHTML
    Create File    ${CURDIR}/tabelaatualizada.csv    ${html_table}    encoding=utf-8    overwrite=True
