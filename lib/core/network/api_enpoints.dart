class ApiEndpoints {
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const refresh = '/auth/refresh';
  static const profile = '/auth/me';

  // loyalty
  static const loyalty = '/me/loyalty';
  
  // services
  static const serviceTypes = '/service-types';
  
  // vehicles
  static const myVehicles = '/me/vehicles';
  static const vehicleTypes = '/vehicle-types';
  
  // orders
  static const orders = '/me/orders';
  static const availableSlots = '/me/orders/available-slots';
  static const previewOrder = '/me/orders/preview';
  
  // vouchers
  static const myVouchers = '/me/vouchers';
  
  // tier configs
  static const tierConfigs = '/tier-configs';
}
