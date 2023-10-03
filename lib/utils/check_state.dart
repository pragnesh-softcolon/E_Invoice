class CheckState {

  List<Map<String, dynamic>> indianStates = [
    {'State': 'Andhra Pradesh', 'StateCode': 37, 'shortName': 'AD'},
    {'State': 'Arunachal Pradesh', 'StateCode': 12, 'shortName': 'AR'},
    {'State': 'Assam', 'StateCode': 18, 'shortName': 'AS'},
    {'State': 'Bihar', 'StateCode': 10, 'shortName': 'BR'},
    {'State': 'Chattisgarh', 'StateCode': 22, 'shortName': 'CG'},
    {'State': 'Delhi', 'StateCode': 7, 'shortName': 'DL'},
    {'State': 'Goa', 'StateCode': 30, 'shortName': 'GA'},
    {'State': 'Gujarat', 'StateCode': 24, 'shortName': 'GJ'},
    {'State': 'Haryana', 'StateCode': 6, 'shortName': 'HR'},
    {'State': 'Himachal Pradesh', 'StateCode': 2, 'shortName': 'HP'},
    {'State': 'Jammu and Kashmir', 'StateCode': 1, 'shortName': 'JK'},
    {'State': 'Jharkhand', 'StateCode': 20, 'shortName': 'JH'},
    {'State': 'Karnataka', 'StateCode': 29, 'shortName': 'KA'},
    {'State': 'Kerala', 'StateCode': 32, 'shortName': 'KL'},
    {'State': 'Lakshadweep Islands', 'StateCode': 31, 'shortName': 'LD'},
    {'State': 'Madhya Pradesh', 'StateCode': 23, 'shortName': 'MP'},
    {'State': 'Maharashtra', 'StateCode': 27, 'shortName': 'MH'},
    {'State': 'Manipur', 'StateCode': 14, 'shortName': 'MN'},
    {'State': 'Meghalaya', 'StateCode': 17, 'shortName': 'ML'},
    {'State': 'Mizoram', 'StateCode': 15, 'shortName': 'MZ'},
    {'State': 'Nagaland', 'StateCode': 13, 'shortName': 'NL'},
    {'State': 'Odisha', 'StateCode': 21, 'shortName': 'OD'},
    {'State': 'Pondicherry', 'StateCode': 34, 'shortName': 'PY'},
    {'State': 'Punjab', 'StateCode': 3, 'shortName': 'PB'},
    {'State': 'Rajasthan', 'StateCode': 8, 'shortName': 'RJ'},
    {'State': 'Sikkim', 'StateCode': 11, 'shortName': 'SK'},
    {'State': 'Tamil Nadu', 'StateCode': 33, 'shortName': 'TN'},
    {'State': 'Telangana', 'StateCode': 36, 'shortName': 'TS'},
    {'State': 'Tripura', 'StateCode': 16, 'shortName': 'TR'},
    {'State': 'Uttar Pradesh', 'StateCode': 9, 'shortName': 'UP'},
    {'State': 'Uttarakhand', 'StateCode': 5, 'shortName': 'UK'},
    {'State': 'West Bengal', 'StateCode': 19, 'shortName': 'WB'},
    {'State': 'Andaman and Nicobar Islands', 'StateCode': 35, 'shortName': 'AN'},
    {'State': 'Chandigarh', 'StateCode': 4, 'shortName': 'CH'},
    {'State': 'Dadra & Nagar Haveli and Daman & Diu', 'StateCode': 26, 'shortName': 'DNHDD'},
    {'State': 'Ladakh', 'StateCode': 38, 'shortName': 'LA'},
    {'State': 'Other Territory', 'StateCode': 97, 'shortName': 'OT'},
  ];

  Map<String, dynamic> findStateByCode(int stateCode) {
    for (var state in indianStates) {
      if (state['StateCode'] == stateCode) {
        return {
          'State': state['State'],
          'shortName': state['shortName'],
          'StateCode': state['StateCode'],
        };
      }
    }
    return {
      'State': 'Invalid GST Number',
      'shortName': 'Invalid GST Number',
      'StateCode': 'nuInvalid GST Number',
    };
  }
}