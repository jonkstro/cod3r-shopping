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

### Componente Formulário!!!
- Criado página ProductFormPage, vai ser Statefull pois vai ser preciso gerenciamento de estados e validações. Adicionado no AppRoutes e no Main.
- A página ProductFormPage terá um widget Form que irá ter os TextFormFields dos campos necessários para cadastrar um novo produto
- Criado ícone novo nas actions de ProductPage para adicionar produto, onde vai navegar para a pagina ProductFormPage.
- Nessa página foi feito validação dos campos usando validate do form e submit usando onSaved do form.