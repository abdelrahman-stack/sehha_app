enum AccountType {
  maleCustomer,
  maleBarber,
  femaleCustomer,
  femaleBarber,
  serviceCenter,
}
class AccountConfig {
  static const Map<String, int> storeTabIndex = {
    'MaleCustomerView': 2,
    'FemaleCustomerView': 2,
    'BarberView': 2,
    'CawferView': 2,
    'SalonCenterView': 2,
    // … أكمل باقي الحسابات
  };
}
