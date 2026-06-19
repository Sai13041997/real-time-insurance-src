import xmltodict
import database_handler
import request_handler
import response_handler


def lambda_handler(event, context):

    # Handle the incoming SOAP request and extract necessary information
    vin, verification_date, tracking_number, policy_key = request_handler.handle_request(event)

    # Query the database for unit information based on the VIN number
    unit_info = database_handler.query_policy_info_by_vin(vin, verification_date)

    # Process the database query result and determine the neccessary values for the SOAP response
    policy_key, unit_added_date, response_code, unconfirmed_reason_code = response_handler.build_response_values(unit_info)

    # Create the SOAP response
    soap_response = response_handler.soap_response_template(tracking_number, policy_key, verification_date, response_code, unconfirmed_reason_code)

    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'text/xml'
        },
        'body': xmltodict.unparse(soap_response)
    }
