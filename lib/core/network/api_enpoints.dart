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

  // washer work-orders
  static const workOrders = '/me/work-orders';
  // detail/start/finish: '$workOrders/$id', '$workOrders/$id/start', '$workOrders/$id/finish'

  // upload (Cloudinary) → trả về { url } / { urls: [...] }
  static const uploadImage = '/upload/image';
  static const uploadImages = '/upload/images';
}
