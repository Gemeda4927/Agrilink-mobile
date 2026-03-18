import 'package:agrilink/features/product/domain/entities/product_entities.dart'
    show ProductEntity;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_products.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts getProducts;

  List<ProductEntity> products = [];

  ProductBloc(this.getProducts) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    try {
      final products = await getProducts();

      var productBloc = this;
      productBloc.products = products.cast<ProductEntity>();

      emit(ProductLoaded(products.cast<ProductEntity>()));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}
