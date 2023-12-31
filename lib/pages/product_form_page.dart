import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/product.dart';
import 'package:shop/models/product_list.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  // controller que vai buscar imagem na url
  final _imageUrlController = TextEditingController();

  // Aqui vai ser a chave referenciada dentro do Form, pra poder salvar ele quando
  // for chamada a função onSubmit.
  final _formKey = GlobalKey<FormState>();
  // Os dados do formulário vão ser jogados nesse mapping
  // ignore: prefer_collection_literals
  final _formData = Map<String, Object>();

  // Variavel pra ativar o progressive bar de carregando
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imageUrlController.addListener(updateImage);
  }

  // Limpar tudo que abri. Igual fechar meus SCANNER no java.
  @override
  void dispose() {
    super.dispose();
    _imageUrlController.removeListener(updateImage);
  }

  // Esse método vai preencher o formdata com o produto passado por argumento
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_formData.isEmpty) {
      // Se o formdata tiver vazio, vai pegar as dependencias do product
      final arg = ModalRoute.of(context)?.settings.arguments;

      if (arg != null) {
        // Se arg não for vazio, quer dizer que tou vindo pra tela de edição
        final product = arg as Product;
        _formData['id'] = product.id;
        _formData['name'] = product.name;
        _formData['price'] = product.price;
        _formData['description'] = product.description;
        _formData['imageUrl'] = product.imageUrl;

        _imageUrlController.text = product.imageUrl;
      }
    }
  }

  // Método que vai atualizar a imagem na FittedBox.
  // o setState vazio já é suficiente pra refreshar a imagem com a url
  void updateImage() {
    setState(() {});
  }

  // Vai salvar cada um dos campos do form chamando o onSaved de cada um
  Future<void> _submitForm() async {
    // Validação dos campos do formulario: Se tiver o que validar ele valida,
    //se não tiver nada pra validar manda false pois deu algum erro
    final isValid = _formKey.currentState?.validate() ?? false;
    // Se não for válido (isValid = false) ele vai fazer nada, vai acabar aqui
    if (!isValid) {
      return;
    }

    _formKey.currentState?.save();

    // Setar os isLoading igual a true, quer dizer que vai tar carregando a página
    setState(() => _isLoading = true);

    try {
      await Provider.of<ProductList>(
        // Pra não dar erro, vai ter que botar listen = false, pois está fora do build.
        context,
        listen: false,
      ).saveProduct(_formData);
      // Voltar pra tela anterior após realizar o save
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    } catch (error) {
      // Se der algum erro, vai abrir um AlertDialog e voltar pra página anterior se apertar OK
      // ignore: use_build_context_synchronously
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.red,
          title: const Text(
            'Ocorreu um erro',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            error.toString(),
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Ok',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } finally {
      // Independente do que aconteça ele executa o finally

      // Setar os isLoading igual a false, quer dizer que já carregou a página
      setState(() => _isLoading = false);
      // Espera primeiro processar para poder voltar pra tela anterior:
      // ignore: use_build_context_synchronously
      // Navigator.of(context).pop();
    }
  }

  bool isValidImageUrl(String url) {
    // Vai pegar o caminho absoluto da URL, se não tiver vai pegar false (não válido)
    bool isValidImageUrl = Uri.tryParse(url)?.hasAbsolutePath ?? false;
    bool endsWithFile = url.toLowerCase().endsWith('.png') ||
        url.toLowerCase().endsWith('.jpg') ||
        url.toLowerCase().endsWith('.jpeg');
    return isValidImageUrl && endsWithFile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar novo produto'),
        actions: [
          IconButton(
              onPressed: () {
                _submitForm();
              },
              icon: const Icon(Icons.save))
        ],
      ),
      body: _isLoading // Se tiver carregando vai mostrar uma barra circular
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Form(
                // Pra poder saber que é esse form que vai ser salvo
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _formData['name']?.toString(),
                      decoration: const InputDecoration(labelText: 'Nome'),
                      // Se clicar no ENTER do teclado vai pro próximo input do form
                      textInputAction: TextInputAction.next,
                      // Ao submitar o form, o formdata vai receber no campo name o valor
                      // do textfield, senão, se tiver vazio (??) vai receber '' (string vazia).
                      onSaved: (name) => _formData['name'] = name ?? '',
                      validator: (value) {
                        // a string name vai receber o valor, se for nulo recebe ''
                        final String name = value ?? '';

                        // Remover espaços em branco no início e no final da string
                        if (name.trim().isEmpty) {
                          return 'Nome não pode ser vazio';
                        }
                        // aqui o trim vai cortar pra ver quantas letras tem e remover todos
                        // espaços brancos com replaceall
                        if (name.replaceAll(' ', '').trim().length < 3) {
                          return 'Nome precisa ter pelo menos 3 letras';
                        }
                        // return null quer dizer que não teve erros
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _formData['price']?.toString(),
                      decoration: const InputDecoration(labelText: 'Preço'),
                      // Se clicar no ENTER do teclado vai pro próximo input do form
                      textInputAction: TextInputAction.next,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      // Ao submitar o form, o formdata vai receber no campo price o valor
                      // do textfield, senão, se tiver vazio (??) vai receber 0.
                      onSaved: (price) =>
                          _formData['price'] = double.parse(price ?? '0'),
                      validator: (value) {
                        final priceString = value ?? '';
                        // faz o parce da priceString, se não conseguir bota -1
                        final price = double.tryParse(priceString) ?? -1;

                        if (price <= 0) {
                          return 'Informe um preço válido';
                        }
                        // Se passar nas validações deu tudo certo
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _formData['description']?.toString(),
                      decoration: const InputDecoration(labelText: 'Descrição'),
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      // Ao submitar o form, o formdata vai receber no campo description o valor
                      // do textfield, senão, se tiver vazio (??) vai receber '' (string vazia).
                      onSaved: (description) =>
                          _formData['description'] = description ?? '',
                      validator: (value) {
                        // a string name vai receber o valor, se for nulo recebe ''
                        final String description = value ?? '';

                        // Remover espaços em branco no início e no final da string
                        if (description.trim().isEmpty) {
                          return 'Descrição não pode ser vazio';
                        }
                        // aqui o trim vai cortar pra ver quantas letras tem e remover todos
                        // espaços brancos com replaceall
                        if (description.replaceAll(' ', '').trim().length <
                            10) {
                          return 'Descrição precisa ter pelo menos 3 letras';
                        }
                        // return null quer dizer que não teve erros
                        return null;
                      },
                    ),
                    Row(
                      // Pra deixar o textfield e a box do container alinhados no chão
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Url da Imagem'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            // A partir do controller vamos acessar o texto pra poder
                            // mostrar o container com a imagem da url.
                            controller: _imageUrlController,
                            // Quando for submitado vai chamar o submitform
                            onFieldSubmitted: (_) => _submitForm(),
                            // Ao submitar o form, o formdata vai receber no campo imageUrl o valor
                            // do textfield, senão, se tiver vazio (??) vai receber '' (string vazia).
                            onSaved: (imageUrl) =>
                                _formData['imageUrl'] = imageUrl ?? '',
                            validator: (value) {
                              final String imageUrl = value ?? '';
                              return !isValidImageUrl(imageUrl)
                                  ? 'Informe uma URL válida'
                                  : null;
                            },
                          ),
                        ),
                        Container(
                          // Pra não ficar colado na de cima e no textfield
                          margin: const EdgeInsets.only(top: 10, left: 10),
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: _imageUrlController.text.isEmpty
                              ? const Text('Insira uma URL')
                              : Image.network(_imageUrlController.text),
                        )
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 100),
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _submitForm();
                        },
                        icon: const Icon(Icons.save),
                        label: const Text(
                          'SALVAR',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
