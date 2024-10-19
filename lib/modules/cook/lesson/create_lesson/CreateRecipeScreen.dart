import 'package:cooking_app/modules/user/lesson/LessonDetailsModel.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/BaseFormBodyUnsafe.dart';
import 'package:cooking_app/utils/ValidationUtils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateRecipeScreen extends StatefulWidget {
  
  final RecipeModel recipe;

  CreateRecipeScreen({this.recipe});
  
  @override
  State<StatefulWidget> createState() => CreateRecipeScreenState();
}

class CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

   static const int MINIMUM_INGREDIENTS_COUNT = 2;

  String _recipeName;
  String _recipeInstructions;
  String _recipeUtensils;

  FocusNode _focusName;
  FocusNode _focusInstructions;
  FocusNode _focusUtensils;

  var _editControllerName = TextEditingController();
  var _editControllerInstructions = TextEditingController();
  var _editControllerUtensils = TextEditingController();

  ValueNotifier<int> _ingredientListCount = ValueNotifier(MINIMUM_INGREDIENTS_COUNT);
  List<IngredientModel> _ingredientList = <IngredientModel>[];

  @override
  void initState() {
    if(widget.recipe != null){
      _editControllerName.text = widget.recipe.name;
      _editControllerInstructions.text = widget.recipe.instruction;
      _editControllerUtensils.text = widget.recipe.utensils;
      _ingredientList.addAll(widget.recipe.ingredients);
    }else{
      _ingredientList = <IngredientModel>[IngredientModel(), IngredientModel()];
    }

    super.initState();

    _focusName = FocusNode();
    _focusInstructions = FocusNode();
    _focusUtensils = FocusNode();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.createRecipe),
      ),
      body: BaseFormBodyUnsafe(
          child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: AppDimensions.maxPadding,
                      left: AppDimensions.generalPadding,
                      right: AppDimensions.generalPadding,
                      bottom: AppDimensions.generalPadding),
                  child: Column(
                    children: [

                      ///Name
                      Container(
                        child: TextFormField(
                          controller: _editControllerName,
                          decoration: InputDecoration(labelText: AppStrings.recipeName),
                          maxLines: 1,
                          autofocus: false,
                          focusNode: _focusName,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          onFieldSubmitted:
                              ValidationUtils.fieldNext(context, _focusInstructions),
                          validator: ValidationUtils.getEmptyValidator(
                              context, AppStrings.enterRecipeName),
                          onSaved: (value) => _recipeName = value,
                        ),
                      ),

                      ///Insturctions
                      Container(
                        margin: EdgeInsets.only(top: AppDimensions.generalPadding),
                        child: TextFormField(
                          controller: _editControllerInstructions,
                          decoration:
                              InputDecoration(labelText: AppStrings.preparations),
                          maxLines: 6,
                          autofocus: false,
                          focusNode: _focusInstructions,
                          keyboardType: TextInputType.multiline,
                          //textInputAction: TextInputAction.multiline,
                          textCapitalization: TextCapitalization.sentences,
                          onFieldSubmitted: ValidationUtils.fieldNext(context, _focusUtensils),
                          validator: ValidationUtils.getEmptyValidator(
                              context, AppStrings.enterPreparations),
                          onSaved: (value) => _recipeInstructions = value,
                        ),
                      ),

                      /// Utensiles
                      Container(
                        margin: EdgeInsets.only(top: AppDimensions.generalPadding),
                        child: TextFormField(
                          controller: _editControllerUtensils,
                          decoration:
                              InputDecoration(labelText: AppStrings.recipeUtensils),
                          maxLines: 6,
                          autofocus: false,
                          //textInputAction: TextInputAction.multiline,
                          keyboardType: TextInputType.multiline,
                          textCapitalization: TextCapitalization.sentences,
                          focusNode: _focusUtensils,
                          validator: ValidationUtils.getEmptyValidator(
                              context, AppStrings.enterUtensils),
                          onSaved: (value) => _recipeUtensils = value,
                        ),
                      ),


                      SizedBox(height: AppDimensions.generalPadding,),

                      Row(crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(child: Text(AppStrings.ingredientList, style: Theme.of(context).textTheme.headline5,)),

                        ],
                      ),

                      ValueListenableProvider<int>.value(value: _ingredientListCount,
                        child: Consumer<int>(builder: (context, count, child){
                          return (count == 0) ? Container()
                            : ListView.builder(
                            primary: false,
                            shrinkWrap: true,
                            padding: EdgeInsets.only(top: AppDimensions.generalTopPadding),
                            itemCount: count,
                            itemBuilder: (context, index){
                              return IngredientItemWidget(index, _ingredientList[index],
                                      (int indexValue){
                                    _ingredientList.removeAt(indexValue);
                                    _ingredientListCount.value = _ingredientList.length ?? 0;
                                  });
                            });
                      }),),

                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Row(children: [
                          Expanded(child: Container()),
                          IconButton(icon: Icon(Icons.add_circle, color: AppColors.colorAccent, size: 30,), onPressed: (){
                            _addIngredientItemWidget();
                          })
                        ],),
                      ),

                      SizedBox(height: AppDimensions.maxPadding,),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _processForm(),
                              child: Text((widget.recipe != null) ? AppStrings.saveLabel : AppStrings.addLabel,),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
        ),
      ))),
    );
  }

  @override
  void dispose(){
     _focusName.dispose();
    _focusInstructions.dispose();
     _focusUtensils.dispose();
     super.dispose();
  }

  _addIngredientItemWidget(){
    _ingredientList.add(IngredientModel());
    _ingredientListCount.value = _ingredientList.length ?? 0;
  }

  _processForm(){
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      var recipe = RecipeModel(name: _recipeName, instruction: _recipeInstructions, utensils: _recipeUtensils, ingredients: _ingredientList);
      if(widget.recipe != null){
        recipe.id = widget.recipe.id;
      }
      Navigator.of(context).pop(recipe);
    }
  }

}

typedef RemoveIngredient(int index);

class IngredientItemWidget extends StatefulWidget{

  final int index;
  final IngredientModel ingredientModel;
  final RemoveIngredient onRemoveIngredient;

  IngredientItemWidget(this.index, this.ingredientModel, this.onRemoveIngredient);

  @override
  State<StatefulWidget> createState() => IngredientItemWidgetState();
}

class IngredientItemWidgetState extends State<IngredientItemWidget>{

  TextEditingController _editControllerIngredient;
  TextEditingController _editControllerQuantity;

  @override
  Widget build(BuildContext context) {
    _editControllerIngredient = TextEditingController();
    _editControllerQuantity = TextEditingController();
    _editControllerIngredient.text = widget.ingredientModel?.ingredient ?? "";
    _editControllerQuantity.text = widget.ingredientModel?.quantity ?? "";
    _editControllerIngredient.addListener(() {
      widget.ingredientModel.ingredient = _editControllerIngredient.text;
    });
    _editControllerQuantity.addListener(() {
      widget.ingredientModel.quantity = _editControllerQuantity.text;
    });

    return Padding(
      padding: const EdgeInsets.only(top: AppDimensions.generalTopPadding, bottom: AppDimensions.generalTopPadding),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _editControllerIngredient,
              decoration: InputDecoration(labelText: AppStrings.ingredient),
              maxLines: 2,
              minLines: 1,
              autofocus: false,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: ValidationUtils.getEmptyValidator(
                  context, AppStrings.enterIngredient),
            ),
          ),
          SizedBox(width: AppDimensions.generalTopPadding,),
          Expanded(
            child: TextFormField(
              controller: _editControllerQuantity,
              decoration: InputDecoration(labelText: AppStrings.quantity),
              maxLines: 2,
              minLines: 1,
              autofocus: false,
              textInputAction: TextInputAction.next,
              validator: ValidationUtils.getEmptyValidator(
                  context, AppStrings.enterQuantity),
            ),
          ),

          Offstage(
            offstage: ((widget.index == 0 || widget.index == 1)),
            child: IconButton(
              icon: Icon(Icons.cancel), color: AppColors.colorAccent, onPressed: (){
              widget.onRemoveIngredient(widget.index);
            },),
          ),
        ],
      ),
    );
  }

}
