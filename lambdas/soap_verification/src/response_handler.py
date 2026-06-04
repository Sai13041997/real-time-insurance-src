

def build_response_values(unit_info):
    print(f"Unit Info: {unit_info}")
    
    if unit_info is None:
        response_code = "UNCONFIRMED"
        policy_key = "UNKNOWN"
        unit_added_date = None
        unconfirmed_reason_code = None
        
        return policy_key, unit_added_date, response_code, unconfirmed_reason_code

    else:
        
        policy_key = unit_info['policy_number']

        if policy_key is None:
            policy_key = "UNKNOWN"
            unconfirmed_reason_code = None
         
         # Extract the policy effective date
        unit_added_date = f"{unit_info['unit_added_date']}T00:00:00.000"

        if unit_added_date is None:
            response_code = "UNCONFIRMED"
            unconfirmed_reason_code = None
        else:
            response_code = "CONFIRMED"
            unconfirmed_reason_code = None


    return policy_key, unit_added_date, response_code, unconfirmed_reason_code




def soap_response_template(tracking_number, policy_key, verification_date, response_code, unconfirmed_reason_code):

    return {
        'SOAP-ENV:Envelope': {
            '@xmlns:SOAP-ENV': 'http://schemas.xmlsoap.org/soap/envelope/',
            '@xmlns:xsd': 'http://www.w3.org/2001/XMLSchema',
            '@xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance',

            'SOAP-ENV:Body': {
                'CoverageResponse': {
                    '@xmlns': 'http://www.iicmva.com/CoverageVerification/',

                    'Detail': {
                        'PolicyInformation': {

                            'CoverageStatus': {
                                'ResponseDetails': {
                                    'ResponseCode': response_code,
                                    'UnconfirmedReasonCode': unconfirmed_reason_code
                                }
                            },

                            'OrganizationDetails': {
                                'NAIC': '12345'
                            },

                            'PolicyDetails': {
                                'VerificationDate': verification_date,
                                'PolicyKey': policy_key,
                                'PolicyState': 'KY'
                            }

                        }
                    }

                }
            }
        }
    }


    
