import 'package:agrilink/features/cart/presentation/bloc/cart_event.dart';
import 'package:agrilink/features/cart/presentation/bloc/cart_state.dart';
import 'package:agrilink/features/domain/payment/domain/usecases/checkout_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:agrilink/features/cart/domain/entity/cart_item.dart';
import 'package:agrilink/features/cart/domain/usecases/cart_usecases.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartUseCase getCartUseCase;
  final AddToCartUseCase addToCartUseCase;
  final UpdateCartUseCase updateCartUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;
  final ProcessCheckoutUseCase processCheckoutUseCase;

  CartBloc({
    required this.getCartUseCase,
    required this.addToCartUseCase,
    required this.updateCartUseCase,
    required this.removeFromCartUseCase,
    required this.processCheckoutUseCase,
  }) : super(CartInitial()) {
    on<LoadCart>(_onLoadCart);
    on<AddToCart>(_onAddToCart);
    on<UpdateCartItem>(_onUpdateCartItem);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<ClearCart>(_onClearCart);
    on<ProcessCheckout>(_onProcessCheckout);
  }

  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    try {
      emit(CartLoading());
      final cartItems = await getCartUseCase();
      final totalPrice = _calculateTotalPrice(cartItems);
      final totalItems = _calculateTotalItems(cartItems);
      emit(
        CartLoaded(
          cartItems: cartItems,
          totalPrice: totalPrice,
          totalItems: totalItems,
        ),
      );
    } catch (e) {
      emit(CartError(message: 'Failed to load cart: $e'));
    }
  }

  Future<void> _onAddToCart(AddToCart event, Emitter<CartState> emit) async {
    try {
      emit(CartLoading());
      await addToCartUseCase(productId: event.productId, amount: event.amount);
      add(LoadCart());
    } catch (e) {
      emit(CartError(message: 'Failed to add item: $e'));
    }
  }

  Future<void> _onUpdateCartItem(
    UpdateCartItem event,
    Emitter<CartState> emit,
  ) async {
    try {
      emit(CartLoading());
      await updateCartUseCase(productId: event.productId, amount: event.amount);
      add(LoadCart());
    } catch (e) {
      emit(CartError(message: 'Failed to update cart: $e'));
    }
  }

  Future<void> _onRemoveFromCart(
    RemoveFromCart event,
    Emitter<CartState> emit,
  ) async {
    try {
      emit(CartLoading());
      await removeFromCartUseCase(event.productId);
      add(LoadCart());
    } catch (e) {
      emit(CartError(message: 'Failed to remove item: $e'));
    }
  }

  Future<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    try {
      emit(CartLoading());
      final cartItems = await getCartUseCase();
      for (final item in cartItems) {
        await removeFromCartUseCase(item.productId);
      }
      add(LoadCart());
    } catch (e) {
      emit(CartError(message: 'Failed to clear cart: $e'));
    }
  }

  Future<void> _onProcessCheckout(
    ProcessCheckout event,
    Emitter<CartState> emit,
  ) async {
    try {
      emit(CartProcessing(message: 'Processing checkout...'));

      final result = await processCheckoutUseCase.execute();

      // Debug: Print the actual result
      print('=====================================');
      print('ORDER ID: ${result.orderId}');
      print('PAYMENT URL: ${result.paymentUrl}');
      print('PAYMENT URL LENGTH: ${result.paymentUrl.length}');
      print('=====================================');

      // Clear cart after successful checkout
      final cartItems = await getCartUseCase();
      for (final item in cartItems) {
        await removeFromCartUseCase(item.productId);
      }

      emit(
        CartCheckoutSuccess(
          orderId: result.orderId,
          paymentUrl: result.paymentUrl,
        ),
      );
    } catch (e) {
      print('ERROR DURING CHECKOUT: $e');
      emit(CartError(message: 'Checkout failed: ${e.toString()}'));
    }
  }

  double _calculateTotalPrice(List<CartItem> cartItems) {
    double total = 0.0;
    for (final item in cartItems) {
      final price = double.tryParse(item.product.price) ?? 0.0;
      total += price * item.amount;
    }
    return total;
  }

  int _calculateTotalItems(List<CartItem> cartItems) {
    int total = 0;
    for (final item in cartItems) {
      total += item.amount;
    }
    return total;
  }
}
