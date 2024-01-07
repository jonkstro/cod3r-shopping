# SEÇÃO 9 - Formulários
### Snackbar
SnackBar vai mostrar que o produto foi adicionado, e vai permitir desfazer tbm
- Alterado o componente ProductItem para ProductGridItem
- Criado método na model Carrinho removeSingleItem para remover só 1 item ao clicar em 'DESFAZER' no snackbar.
- Criado SnackBar no onPressed do ícone de carrinho do ProductGridItem.

### Confirmação com Dialog
Vamos adicionar um Dialog no Dismissable do CartItemWidget pra ter que confirmar antes de deletar o item do carrinho
- Vai ser adicionado um confirmDismis no Dismissed com o widget AlertDialog que vai retornar um future com true (pra confirmar que quer remover o item do carrinho) ou false (pra cancelar a remoção do item do carrinho)


## Tela de Produtos
### Componente Gerenciamento de Produtos
- Criado pagina ProductPage e adicionado no AppRoutes e nas routes do Main
- Adicionado no componente AppDrawer o icone de ir pra página ProductPage
- Adicionado getter ItensCount na model ProductList
- Criado componente ProductItem que vai servir de ListTile para o ProductPage exibir no seu ListView.builder. Ele vai receber os produtos como parâmetro e o ProductPage vai enviar pro seu construtor
- Esse componente ProductItem vai ter no ListTile no leading um Widget NetworkImage dentro do CircleAvatar para adicionar no background do CircleAvatar uma imagem

### Página de Formulário!!!
- Criado página ProductFormPage, vai ser Statefull pois vai ser preciso gerenciamento de estados e validações. Adicionado no AppRoutes e no Main.
- A página ProductFormPage terá um widget Form que irá ter os TextFormFields dos campos necessários para cadastrar um novo produto
- Criado ícone novo nas actions de ProductPage para adicionar produto, onde vai navegar para a pagina ProductFormPage.
- Nessa página foi feito validação dos campos usando validate do form e submit usando onSaved do form.

### CRUD - Ainda na página de formulário ProductFormPage
- CREATE - Foi criado o método saveProduct na model ProductList que vai receber o formData da página ProductFormPage e vai adicionar na lista dos produtos. Posteriormente esse método pode ser alterado para salvar em um banco de dados ou fazer uma chamada de API.

- UPDATE - Foi criado o método updateProduct que vai ser chamado no saveProduct no provider ProductList, pra, quando identificar que o produto tem um ID, ele chamar o método de updateProduct ao invés de addProduct. Além disso foi adicionado no icone de edição no componente do ProductItem para ir para a mesma página ProductFormPage, só que passando como argumento o produto que vai editar.

- DELETE - Foi criado o método removeProduct na model ProductList que vai ser chamado no componente ProductItemWidget onde foi colocado tbm um showDialog. Se apertar o showDialog em SIM ele vai chamar o removeProduct no Provider de ProductList.


# SEÇÃO 10 - Requisições HTTP usando FIREBASE

### Configurações do FIREBASE
1 - Entrar no console do firebase e apertar em criar projeto
2 - Após criar o projeto entrar no dashboard do projeto e selecionar criação -> realtime database [vai criar api rest pra acessar o BD]
3 - Apertar em criar banco de dados e modo de teste e ativar.
4 - após criado, ele dá a URL do banco de dados pra poder interagir com o BD

### Enviando as requisições:
1 - Adicionar no pubspec o http: ^0.13.3
2 - Dentro da model ProductList vamos mandar a informação do formulário com POST request na URL do Firebase.
3 - Alterar os métodos saveProduct, addProduct e updateProduct (deixar todo mundo Future e adicionar os verbos http correspondentes).
4 - Adicionar _isLoading na página de formulário, pra página "ficar pensando" enquanto tá fazendo as requisições http.


# SEÇÃO 11 - Autenticação com Firebase
Iremos realizar a autenticação dos usuários com Firebase, onde irá retornar um Token de autenticação que iremos armazenar localmente no dispositivo para as próximas validações.

### Configurações no Firebase
1 - Entrar no console do projeto e acessar o realtime database
2 - Entrar em "Regras" e escrever:
    {
        "rules": {
            ".read": "auth != null",  
            ".write": "auth != null",  
        }
    }

3 - Sair do Realtime Database e entrar em "Autenticação" (tá lá em Criação)
4 - Clicar em Provedores: Email/Senha e clicar em ativar e salvar.

Agora que tem essas configurações, não conseguiremos acessar os dados do Firebase, pois será preciso realizar a autenticação para poder acessar os dados.


### Tela de autenticação
1 - Criar arquivo AuthPage dentro de pages e adicionar no AppRoutes e no Main
2 - Criar model auth que vai ser usada no componente AuthForm. Essa model terá que adicionar o provider no Main (create deve ser o primeiro, pois o provider de produtos e pedidos vão depender dele para exibir as informações) e no AuthForm(context só) que irá executar. 
Terá também que alterar os providers de pedidos e produtos de ChangeNotifierProvider para ChangeNotifierProxyProvider pois vai depender do provider de auth. 
3 - Criar o componente AuthForm e jogar dentro da tela de AuthPage.
4 - Criado o AuthOrHomePage que vai exibir a plataforma se o user já tiver autenticado ou a pagina de autenticação se não tiver autenticado

### "Avisando" o Firebase que fiz o login
1 - Dentro de loadProducts, vamos ter que enviar o token do login para o firebase, pois senão ele não irá exibir as listas de produtos. Do mesmo modo para as listas de pedidos
2 - Dentro de ProductList, vamos precisar receber o token no construtor. Foi alterado também o loadProducts para passar o token quando fizer o GET no Firebase


### Persistindo o login com Shared Preferences
- Adicionar nas dependências do pubspec: shared_preferences: ^2.0.6
Vamos isolar a persistencia dentro de outra classe para separar as responsabilidades
- Criar arquivo dentro de data: store.dart
- Criar método tryAutoLogin no auth que vai pegar os dados armazenados e passar pras variaveis de auth
- Chamar no AuthOrHomePage o metodo dentro de um FutureBuilder


## ***ATUALIZANDO AS REGRAS DO REALTIMEDATABASE***
- Dentro de pedidos: a variável $uid quer dizer que só vai poder ler ou escrever em pedidos se o user logado (auth.uid) for igual o uid que tá os pedidos salvos pois lá tá: pedidos/uid/idpedido/pedido
- Dentro de userFavorite: tá do mesmo jeito, um user com um uid não vai poder acessar os dados de outro uid.
- Dentro de produtos: qualquer user autenticado pode ler, mas escrever só com email cadastrado do admin. podemos mudar depois pra tipo de permissão.
{
  "rules": {
    "pedidos": {
      "$uid": {
        ".write": "$uid === auth.uid",
        ".read": "$uid === auth.uid",
      },
    },
    "userFavorite": {
    	"$uid": {
      	".write": "$uid === auth.uid",
        ".read": "$uid === auth.uid",
      },
    },
    "produtos": {
        // Só vai criar se for email igual jon@teste.com
        ".write": "auth.email === 'jon@teste.com'",
        ".read": "auth != null",
    }
  }
}