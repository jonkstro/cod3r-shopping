import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shop/models/product.dart';

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
  final _formData = Map<String, Object>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _imageUrlController.addListener(updateImage);
  }

  // Limpar tudo que abri. Igual fechar meus SCANNER no java.
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _imageUrlController.removeListener(updateImage);
  }

  // Método que vai atualizar a imagem na FittedBox.
  // o setState vazio já é suficiente pra refreshar a imagem com a url
  void updateImage() {
    setState(() {});
  }

  // Vai salvar cada um dos campos do form chamando o onSaved de cada um
  void _submitForm() {
    // Validação dos campos do formulario: Se tiver o que validar ele valida,
    //se não tiver nada pra validar manda false pois deu algum erro
    final isValid = _formKey.currentState?.validate() ?? false;
    // Se não for válido (isValid = false) ele vai fazer nada, vai acabar aqui
    if (!isValid) {
      return;
    }

    _formKey.currentState?.save();
    // print('valores: ' + _formData.values.toString());
    final newProduct = Product(
      id: Random().nextDouble().toString(),
      name: _formData['name'] as String,
      description: _formData['description'] as String,
      price: _formData['price'] as double,
      imageUrl: _formData['imageUrl'] as String,
    );
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
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          // Pra poder saber que é esse form que vai ser salvo
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
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
                  if (description.replaceAll(' ', '').trim().length < 10) {
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
                      decoration:
                          const InputDecoration(labelText: 'Url da Imagem'),
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
                        : FittedBox(
                            fit: BoxFit.cover,
                            child: Image.network(_imageUrlController.text),
                          ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
