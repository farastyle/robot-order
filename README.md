# README for the robot
Este robo vai logar no .serverest.dev criar uma conta como admin, caso nao der certo vai tentar logar como usuario. depois inicia uma leitura no aquivo excel coloca as infomacoes no formulario, envia ( estas infomacoe por enquanto tem quer ser unicas, podemos tratar o erro para continuar se itens ja existirem) apos cadastrar itens volta para pagina de lista de itens e cria um aquivo com a tabela de itens - a recomendacao seria colocar os usuarios em arquivo vault tratar erros quando itens ja estao cadastrados, preciso de maior conhecimento em como pegar essa tabela de forma correta!

explicao das acoes usadas:

Tarefas Abre a Pagina, usando o metodo Open Available Brower na forma maximizada, pois quando abre a pagine e modo restaurado ele nao ve o elemento disponivel para clicar dos menus em opcoes mais pra frente. Loga servidor, segue no link cadastrar e espera 3 segundos pra dar tempo do servidor carregar tudo, pois durante os testes do codigo eu percebia que o banco estava sendo resetado, e pra facilitar nao ter que ficar cadastrando e logando coloquei para tentar fazer o cadastro primeiro, verifica com um If se o elemento da proxima pagina foi exibido. caso nao tenha sido exibidovai direto pra opcao de logar como usuario normal. clica na opcao cadastrar produtos Apos essa opcao espera 10 segundos para ver se o elemento de enviar a image aparaceu assim nao tem esse elemento em nenhuma outra parte da pagina

Nisso vamos para a tarefa Registra produto basicamente consiste em carregar o arquivo do Excel que foi fornecido, usando a funcao download, poe essas informacoes num workbook e joga para variavel $orderNumbers, nessa parte ele roda um for para qual chama a funcao cadastra produto na qual pra cada campo ele preenche conforme cada qual. eu coloquei o elemento Input Text when element is Visible porque estava dando erro no comeco pois alguns campos nao estavam mostrando. para cadastrar a imagem nos usamos a funcao Http Get na linha 82 apos receber a informacao joga pra Json e extrai somente a chave URL usando isso para fazer o download da imagen que modifica o nome para o nome do produto apos todos os dados preenchidos espera o download terminar ( isso as vezes leva alguns segundos) e coloca o nome da imagem como o nome do produto, assim facilitando controlar o nome do arquivo para enviar.

Vamos para a tarefa Cria lista de tabela. Apos e todos os objetos cadastrados vamos para parte de criar a tabela. para extrair a informacao da tabela usei esse metodo, https://robocorp.com/portal/robot/robocorp/example-html-table-robot na qual ejuda a separar as informacoes porem neste momento eu estava tendo um erro me retornava toda vez a variavel ${html_table} sem nenhuma coluna , testei varias opcoes, recorri ao forum do Robocorp para ver se achava a solucao, eles nao conseguiram extrair a tabela tambem, entao decidir que no desafio falava para "salve o conteúdo da tabela mostrada em um arquivo excel criado pelo seu robô." para nao ficar sem cumprir eu passei o melhor conteudo que a ${html_table} trazia fiz alguns testes e inseri esse conteudo em um arquivo csv

antes de pensar em parar tentei jogar toda a pagina com a informacao num arquivo csv e ver se conseguia algun resultado, e nem assim foi possivel. resolvi que ja tinha 24horas que o Thiago tinha me passado o teste, seria melhor mandar assim do que nao mandar,


Atualizacoes feitas:
login funcionando de forma segura
verifica se o iten foi cadastrado mensagem apareceu, e continua operacao sem dar erro.
fecha janelas no final!!

A melhorar e acrescentar. 
{html_table} continua pegando so a primeira linha por uma razao que eu desconheco.
Arrumar essa parte de pegar a tabela,

Sei que estava proximo da solucao, mas apos exaustivos testes achei prudente finalizar o projeto.